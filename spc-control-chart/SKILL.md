---
name: spc-control-chart
description: 以繁體中文進行 SPC 統計製程管制圖分析（Xbar–R、Xbar–S、I–MR、p、np、c、u、EWMA、CUSUM、自相關資料的 AR(1) 殘差圖），依資料結構自動選圖、檢查假設、以 exclusions.csv 記錄 Phase I 失控原因，交付含逐段 R 程式碼的 Quarto qmd 與 HTML 報告（統計背景版與一般讀者版）。企業／非公開資料只詢問資料結構與製程背景、不碰任何數值，產出可在本機讀檔執行的 qmd 範本。使用者提到管制圖、SPC、製程是否穩定、失控點、管制界限、品質監測、不良率監測時使用。
---

# SPC 管制圖分析

方法、公式與判讀規則一律依 `references/textbook.qmd`（使用者提供的《SPC 管制圖技能教科書》）。與教材衝突時以教材為準。

## 檔案

| 路徑 | 用途 |
|---|---|
| `assets/spc_functions.R` | 共用 R 函式，以 `## ---- block: 名稱 ----` 分段（計算用 base R，畫圖用 ggplot2） |
| `assets/template_stat.qmd` | 統計背景版範本（兩條分支共用） |
| `assets/template_general.qmd` | 一般讀者版範本（只用於分支 1） |
| `assets/config_private_template.R` | 分支 2 設定區範本 |
| `scripts/assemble_report.py` | 把設定與各段函式插入範本的對應段落，產生自成一體的 qmd |
| `references/intake-questions.md` | 事前問答腳本、問答與 `cfg` 欄位的對應、分支 2 隱私原則、失控點詢問方式 |
| `references/config-reference.md` | 全部 `cfg` 欄位與資料格式 |
| `references/report-spec-statistical.md`／`report-spec-general.md` | 兩個版本的報告規格（改寫自使用者規格） |
| `references/textbook.qmd` | 教材全文：選圖表、假設檢查表、公式、常見錯誤 |

## 不可違反的規則（出自教材）

1. 界限只用 Phase I 中未剔除的點估計；Phase II 固定界限，不重估。
2. Phase I 只有在找到可歸屬原因、且不屬於未來基準機制時才剔除，並記錄原因；查無原因的點保留。決定由使用者做，Claude 不自行判定原因。
3. WECO 4 條規則只用於位置圖（$\bar X$、$I$、殘差圖）；$R$／$S$／$\mathrm{MR}$、計數圖、EWMA／CUSUM 只判斷是否超界。
4. 先看穩定性，再看分布；不為通過常態檢定任意轉換資料。偏態個別值依製程知識改用 `lognormal`，或在基準點數很多時用 `empirical` 分位數界限。
5. 計數圖：期望數小時用精確分位數界限；檢查過度／不足離散，不直接放寬界限。基準期零事件時停止，不視為真實比例為 0。
6. 自相關個別值：先判斷是正常慣性還是可移除的異常；正常慣性才用 AR(1) 殘差圖（訓練／校準切分、固定參數）。
7. 不做製程能力，不以規格界限代替管制界限。
8. 警報＝調查線索，不寫成原因已證實；沒有警報≠已證明穩定；預設 EWMA／CUSUM 參數不保證 $ARL_0=370$。

## 流程

### 第 0 步：分流

用 AskUserQuestion 先問：「資料可以上傳分析，還是屬於企業／非公開資料？」（`references/intake-questions.md` §0）。使用者已附檔但表示是機密時，不開啟該檔，改走分支 2。

### 分支 1：公開資料（Claude 直接分析）

1. **準備環境**（雲端工作區）：確認 `Rscript`、`quarto` 與 R 套件 ggplot2、knitr、rmarkdown；缺少時安裝（例如 `apt-get install -y r-base-core r-cran-ggplot2 r-cran-knitr r-cran-rmarkdown`，Quarto 用官方 .deb）。執行前設定 `LANG=C.UTF-8 LC_ALL=C.UTF-8`。
2. **讀資料、辨識結構**：看欄位、型態、子群大小、時間欄、Phase 標記。只問程式判斷不了的事（不良品還是缺點、Phase 切分、偏移大小 δ、製程背景、OCAP 角色）；問題見 intake §1–3。
3. **寫設定檔** `cfg.R`（`cfg <- list(...)`，欄位見 config-reference）。把資料檔與 `cfg.R` 放在同一個工作資料夾。
4. **第一次執行**：
   ```bash
   python3 <skill_dir>/scripts/assemble_report.py --template stat --config cfg.R --title "<標題>" --out report_stat.qmd
   quarto render report_stat.qmd
   ```
   讀 `exclusions.csv`：`decision` 空白的點是 Phase I 待查警報。
5. **逐點詢問失控原因**（intake §5），把 `exclude`／`keep` 與 `reason` 寫回 `exclusions.csv`（可用 `spc_read_exclusions()`／`spc_write_exclusions()`），再 render；新出現的警報會附加為下一輪。重複到沒有待查點。
6. **檢查假設結果**：第 5 章若建議替代做法（`residual_chart`、`limit_method`），向使用者說明並詢問是否採用；採用後修改 `cfg.R` 重新產生。
7. **補寫敘述**：只在 `<!-- 分析者補充 -->` 處依實際結果補寫（研究問題、現場意義、建議），不改動自動產生的數字；公開資料若有文獻記載的背景可引用並註明。
8. **一般讀者版**：用同一個 `cfg.R` 與 `exclusions.csv`
   ```bash
   python3 <skill_dir>/scripts/assemble_report.py --template general --config cfg.R --title "<標題>" --out report_general.qmd
   quarto render report_general.qmd
   ```
9. **驗證**（見下方檢查清單），交付 `report_stat.qmd`、`report_stat.html`、`report_general.qmd`、`report_general.html`、`exclusions.csv`（以及 `cfg.R` 若使用者需要）。

### 分支 2：非公開資料（只產出本機範本）

1. **事前問答**：只問結構與背景（intake §1–4）。遵守隱私原則：不問、不接受任何數值、規格、既有界限、產品名稱、真實欄位名稱或結果。
2. **填設定區**：複製 `assets/config_private_template.R`，把 `{{DATA_TYPE}}`、`{{CHARACTERISTIC}}`、`{{PURPOSE}}`、`{{DELTA}}`、`{{DECLARED}}`、`{{PROCESS}}`、`{{OCAP}}` 換成問答結果（R 語法，例如 `{{DELTA}}` → `0.5` 或 `NULL`；`{{DECLARED}}` → `list(n = 5, n_fixed = TRUE, m1 = 25)`）。依資料型態，把必要的欄位設成提示字串（例如 `col_subgroup = "★ 請填寫：子群編號欄名"`），不需要的保持 `NULL`；Phase 切分依問答保留對應的那一種。
3. **組合範本**：`assemble_report.py --template stat --config <填好的設定檔> --title "<標題>" --out <名稱>.qmd`（只給統計版）。
4. **自我測試（不可省略）**：在雲端工作區另建測試資料夾，依申報的結構產生**模擬資料**（只用結構，不含任何使用者數值），複製一份範本並把設定區改成模擬資料的欄位，render 一次 → 在 `exclusions.csv` 填一筆 `exclude` → 再 render 一次，確認兩次都成功、剔除後界限有重算。交付的是未改動的範本（保留 ★ 提示），不是測試副本。
5. **交付** `<名稱>.qmd`，並用三到五句說明本機使用方式：需要 R（含 ggplot2、knitr、rmarkdown）與 Quarto；填設定區 → `quarto render` → 填 `exclusions.csv` → 再 render 到第 6 章顯示基準已定案。告知結果不需要傳回。

## 驗證清單

- render 無錯誤；報告各章都有內容或明確寫「本次不適用」。
- 選圖與資料結構一致；公式章的估計值與界限表一致。
- Phase I 待查點為 0（分支 1 交付前），或摘要已標示「暫定」。
- 統計版與一般版的數字、首次警報與結論一致。
- 截圖檢查主要圖表（Playwright，deviceScaleFactor 1 自查即可），確認圖例、Phase 分隔線、剔除點標記正確。
- 交付檔案是 qmd 與 HTML，不產生 PDF、不另交付 R 腳本（程式碼都在報告各段落中）。

## 常見處理

- **寬格式子群資料**（一列一組）：先在 R 轉成長格式（一列一個量測值＋子群編號），再設定 `col_subgroup`／`col_value`。
- **子群大小不固定**：自動用合併組內變異的 $\bar X$–$S$ 圖，界限逐點依 $n_i$。
- **CSV 是 Big5**：程式自動改用 CP950；exclusions.csv 以 UTF-8 BOM 寫出，Excel 可正確顯示中文，使用者用 Excel 存檔成 Big5 也能讀回。
- **render 中途停止**：錯誤訊息為繁中，指出缺少的欄位、非數值、分母為 0 或基準退化；依訊息修正設定或資料。
