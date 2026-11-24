# `cfg` 設定欄位

所有欄位都有預設值（`spc_defaults()`）；只需設定與資料有關的欄位。

## 資料

| 欄位 | 說明 | 預設 |
|---|---|---|
| `data_file` | 資料檔路徑（CSV／xlsx；相對於 qmd 所在資料夾） | 必填 |
| `data_file_phase2` | Phase II 另一個檔案 | `NULL` |
| `encoding` | CSV 編碼；讀取失敗或非 UTF-8 時自動改用 CP950（Big5） | `"UTF-8-BOM"` |
| `sheet` | Excel 工作表（需要 readxl） | `1` |
| `data_type` | `variable`／`nonconforming`／`defects` | `"variable"` |
| `chart` | `auto` 或指定 `xbar_r`／`xbar_s`／`i_mr`／`p`／`np`／`c`／`u`（不符合結構會停止並說明） | `"auto"` |

## 欄位對應

| 欄位 | 用途 |
|---|---|
| `col_time` | 時間；可辨識格式會依時間排序 |
| `col_subgroup` | 子群編號（計量值，每組多筆，長格式：一列一個量測值） |
| `col_value` | 量測值 |
| `col_id` | 每期編號（個別值或計數資料；不設則用列序號） |
| `col_count` | 不良品數或缺點數（非負整數） |
| `col_size` | 檢查件數 $n_i$ 或暴露量 $e_i$（> 0）；c 圖可省略 |
| `col_phase` + `phase1_label`／`phase2_label` | 以欄位標記 Phase |
| `phase1_end` | 基準期最後一點的編號（子群編號或 id） |

## 描述（只用於報告文字）

`characteristic`（品質特性名稱）、`unit`（單位）、`purpose`（統計版問題敘述）、`purpose_plain`（一般版問題敘述，可省略）、`private`（`TRUE` 時顯示本機執行說明）。

## 方法

| 欄位 | 說明 | 預設 |
|---|---|---|
| `delta` | 想偵測的偏移（個體 σ 單位）；$\delta\sqrt n<1.5$ 時加畫 EWMA／CUSUM | `NULL` |
| `small_shift` | `"auto"`／`TRUE`／`FALSE` | `"auto"` |
| `ewma_lambda`, `ewma_L` | EWMA 參數 | `0.2`, `3` |
| `cusum_k`, `cusum_h` | CUSUM 參數（標準化單位） | `0.5`, `5` |
| `weco` | 位置圖是否用 WECO 4 條規則 | `TRUE` |
| `limit_method` | I 圖：`normal`／`lognormal`（依製程知識，所有值 > 0；I 與 MR 都在對數尺度）／`empirical`（基準經驗分位數，需大量基準點，只判斷超界） | `"normal"` |
| `count_limits` | 計數圖：`auto`（最小期望數 < 5 改用精確分位數界限）／`sigma3`／`exact` | `"auto"` |
| `residual_chart` | 個別值改用 AR(1) 一步預測殘差圖判讀（Phase I ≥ 50 點） | `FALSE` |
| `residual_train_frac` | Phase I 中訓練期比例 | `0.6` |

## 紀錄與背景

| 欄位 | 說明 |
|---|---|
| `exclusions_file`, `write_exclusions` | Phase I 調查紀錄 CSV 與是否寫出（預設 `exclusions.csv`、`TRUE`） |
| `declared` | 分支 2 事前申報的結構：`list(n=, n_fixed=, size_fixed=, m1=)`，與實際資料不一致時發出警告 |
| `process` | `list(sampling=, sources=, sources_mixed=, msa=, resolution=, interval=)` |
| `ocap` | `list(roles = list(first=, investigate=, decide=), causes = c(...))` |
| `arl_reps`, `seed` | ARL 模擬次數與亂數種子（預設 400、20261116） |

## 資料格式

- 子群計量值：長格式，一列一個量測值，含子群編號欄；寬格式（一列一組）請先轉為長格式。
- 個別值：一列一筆。
- 計數：一列一期，含計數與分母（或暴露量）；不要只留比例。
- 暴露量為 0 的期別要先移出並另外記錄，不可當成 0 缺點率。
