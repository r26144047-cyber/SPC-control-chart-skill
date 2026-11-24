## 範例：公開資料分析（分支 1）—— 飛機底漆黏度 I–MR 管制圖

### 資料說明

| 項目 | 內容 |
|---|---|
| 檔案 | `viscosity.csv` |
| 筆數 | 35 批，每批 1 個量測值 |
| 欄位 | `batch`：批號（1–35）<br>`viscosity`：黏度量測值<br>`trial`：是否為初步樣本（`TRUE`／`FALSE`） |
| 結構 | `trial = TRUE` 有 20 批（第 1–20 批），作為基準期（Phase I）<br>`trial = FALSE` 有 15 批（第 21–35 批），作為監測期（Phase II） |

飛機底漆（aircraft primer paint）的黏度是重要的品質特性。這種產品是分批生產的，每一批要做好幾個小時，生產速度太慢，沒辦法每次抽好幾個樣本組成子群。所以每批只有一個量測值，適合用個別值–移動全距圖（I–MR 圖）來監測。

### 本資料夾檔案

| 檔案 | 說明 |
|---|---|
| `viscosity.csv` | 原始資料（35 批） |
| `report_stat.qmd`／`report_stat.html` | 統計背景版報告：公式、假設檢查、EWMA／CUSUM、ARL 模擬與完整 R 程式碼 |
| `report_general.qmd`／`report_general.html` | 一般讀者版報告 |
| `exclusions.csv` | Phase I 失控點調查紀錄（第 4 批：查無原因 → `keep`） |

HTML 報告已內嵌圖表，下載後用瀏覽器直接開啟即可。要重新產生，在本資料夾執行 `quarto render report_stat.qmd`（需要 R 與 Quarto）。

### 資料出處

- R 套件 **qcc** 內建資料集 `viscosity`（作者 Luca Scrucca）：<https://luca-scr.github.io/qcc/reference/viscosity.html>
- 原始資料：Montgomery, D. C. (2005). *Introduction to Statistical Quality Control* (5th ed.). New York: John Wiley & Sons, pp. 232–235.

在 R 中取得資料：

```r
library(qcc)
data(viscosity)
write.csv(viscosity, "viscosity.csv", row.names = FALSE)
```

---

### 使用 skill 分析的紀錄

以下是使用者與 Claude 的實際對話問答紀錄。

---

**使用者：**

> @viscosity.csv /spc-control-chart 幫我分析這筆資料

---

**Claude：** 我先看一下分析流程需要確認的問題，然後一次問你。

**Claude 提問（3 題）：**

**Q1. 資料性質**：這份黏度資料（35 批，trial 欄 TRUE 20 批／FALSE 15 批）可以上傳讓我直接分析，還是屬於企業／非公開資料？
- 公開資料，直接分析 (Recommended)：看起來像 R qcc 套件的 viscosity 範例（Montgomery 教科書）；我直接算並交付報告
- 企業／非公開資料：我不使用數值，只產出你在本機執行的 qmd 範本

**Q2. Phase 切分**：我打算把 trial=TRUE 的 20 批當基準期（Phase I）建立界限、trial=FALSE 的 15 批當監測期（Phase II），每批 1 筆用個別值–移動全距（I–MR）圖。這樣切分對嗎？
- 對，TRUE=基準、FALSE=監測 (Recommended)
- 35 批全部當基準期

**Q3. 偏移大小**：想偵測多大的黏度均值偏移？（以製程標準差 σ 為單位；小偏移會加畫 EWMA／CUSUM）
- 不確定 (Recommended)：用預設設定，由報告說明
- 約 0.5σ
- 約 1σ
- 1.5σ 以上

**使用者回答：**
- Q1 → 公開資料，直接分析 (Recommended)
- Q2 → 對，TRUE=基準、FALSE=監測 (Recommended)
- Q3 → 約 0.5σ

---

**Claude：** Phase I 有一個警報點：第 4 批（35.96），在 I 圖與 MR 圖都超出上界。

**Claude 提問：**

**第 4 批**：Phase I 第 4 批（黏度 35.96，I 圖與 MR 圖都超出上界，偏高）：有沒有找到可歸屬原因？公開範例本身沒有記載這批的原因，決定由你做。
- 查無原因 → 保留：依教材規則，查無原因的點留在基準中，界限不重算
- 有原因且非正常狀態 → 剔除：請在備註寫原因（例如配方錯誤、量測失誤）；剔除後重算界限
- 還不確定，先標待查：報告會標示基準為「暫定」

**使用者回答：** 查無原因 → 保留

---

**Claude 提問：**

**界限方法**：假設檢查：Phase I 的 20 個黏度值偏離常態（Shapiro–Wilk p = 0.003，偏態 1.62），但這主要是第 4 批（35.96）單一點造成的；無自相關（lag-1 = 0.05）。報告建議可改用對數常態（lognormal）界限（20 點太少，經驗分位數不適用）。要採用嗎？
- 維持常態 3σ 界限 (Recommended)：偏態來自單一異常點而非分布本質，無製程知識支持對數常態；報告會標明此限制
- 改用 lognormal 界限：若你認為黏度本質上右偏（全為正值）

**使用者回答：** 維持常態 3σ 界限 (Recommended)

---

**Claude：**

兩份報告都做好了。主要發現是：大約從第 25 批起，黏度持續偏高。

**基準期（第 1–20 批）**
- 每批只有一個量測值，所以用 I–MR 圖（個別值圖＋相鄰兩批差距的移動全距圖）。
- 正常範圍：中心線 34.09，I 圖界限 32.56–35.61，MR 圖上界 1.87。
- 第 4 批（35.96）在 I 圖和 MR 圖都超出上界。依你的決定，查無原因所以保留在基準裡，已記錄在 `exclusions.csv`。
- 前 20 批的分布不對稱，但主要是第 4 批這一點造成的。依你的選擇維持一般的 3σ 界限（以標準差計），報告中有註明這個限制。資料沒有自相關（前後批之間沒有連帶關係）。

**監測期（第 21–35 批）**
- 沒有任何一批超出界限，MR 圖也沒有警報，表示批與批之間的波動沒有變大。
- 但第 25 批起連續 11 批都在中心線之上，平均約 34.71，比基準高約 1.2σ。
- 三種方法都偵測到同一方向的偏高：
  - I 圖從第 29 批開始出現「多點偏同一側」的警報，共 5 點。
  - 上側 CUSUM 在第 30 批發出警報。
  - EWMA 在第 35 批發出警報。
- 這看起來像是均值持續小幅往上移，而不是個別批次突然出錯。不過警報只是調查線索，原因還要到現場確認。

**限制**
保留第 4 批會讓界限稍微變寬，對小偏移的偵測比較保守。基準也只有 20 批。

**建議**
回查第 24、25 批前後有沒有換原料、改配方、調整設備或換量具。如果偏高是刻意的製程變更，應該用變更後的資料重新建立基準。

要交付的檔案：
- `report_stat.html`：統計背景版，含公式、假設檢查、EWMA／CUSUM 和完整 R 程式碼
- `report_general.html`：一般讀者版
- 兩份對應的 `.qmd`：可以重新 render
- `exclusions.csv`：Phase I 失控點調查紀錄
