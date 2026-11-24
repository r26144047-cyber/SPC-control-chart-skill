# =====================================================================
# 設定區（請在本機填寫；本檔內容不需要、也不應傳給任何外部服務）
# 標示「★ 請填寫」的項目由你填入；其餘已依事前問答的結構資訊預先設定。
# 欄位名稱請照資料檔第一列的實際名稱填寫（大小寫、空白都要一致）。
# =====================================================================
cfg <- list(
  private = TRUE,                      # 非公開資料模式：報告開頭顯示本機執行說明

  # ---- 資料檔 ----------------------------------------------------------
  data_file = "★ 請填寫：資料檔路徑，例如 data.csv",   # 相對路徑以本 qmd 所在資料夾為準
  data_file_phase2 = NULL,             # 若 Phase II（監測）資料在另一個檔案，填入其路徑
  encoding = "UTF-8-BOM",              # CSV 若由 Excel 存成 Big5，程式會自動改用 CP950
  sheet = 1,                           # Excel 檔的工作表

  # ---- 資料型態（依事前問答設定）---------------------------------------
  data_type = "{{DATA_TYPE}}",         # variable＝計量值；nonconforming＝不良品數；defects＝缺點數
  chart = "auto",                      # auto＝程式依實際資料選圖；也可指定 xbar_r／xbar_s／i_mr／p／np／c／u

  # ---- 欄位名稱（★ 請填寫；不使用的欄位保持 NULL）-----------------------
  col_time = NULL,                     # 時間欄位（建議提供，程式會依時間排序）
  col_subgroup = NULL,                 # 子群編號欄位（計量值且每組多筆時）
  col_value = NULL,                    # 量測值欄位（計量值）
  col_id = NULL,                       # 每期編號欄位（個別值或計數資料，可省略）
  col_count = NULL,                    # 不良品數或缺點數欄位（計數資料）
  col_size = NULL,                     # 檢查件數或暴露量欄位（計數資料；缺點數且機會固定時可省略）

  # ---- Phase I／II 切分（三擇一；都不填＝全部視為 Phase I）----------------
  col_phase = NULL, phase1_label = "I", phase2_label = "II",   # 用欄位標記
  phase1_end = NULL,                   # 或：基準期最後一個子群／資料點的編號

  # ---- 描述（只用於報告文字，可用代稱）----------------------------------
  characteristic = "{{CHARACTERISTIC}}",
  unit = "",                           # ★ 量測單位，例如 "mm"
  purpose = "{{PURPOSE}}",

  # ---- 小偏移偵測（依事前問答設定）--------------------------------------
  delta = {{DELTA}},                   # 想偵測的偏移，以個體標準差 σ 為單位；NULL＝不設定
  ewma_lambda = 0.2, ewma_L = 3, cusum_k = 0.5, cusum_h = 5,

  # ---- 判讀與界限 ---------------------------------------------------------
  weco = TRUE,                         # 位置圖使用 WECO 4 條規則
  limit_method = "normal",             # I 圖：normal／lognormal／empirical（看到第 5 章建議後再決定）
  count_limits = "auto",               # 計數圖：auto（期望數 < 5 時用精確界限）／sigma3／exact
  residual_chart = FALSE,              # 個別值有自相關、且判斷為正常慣性時改為 TRUE

  # ---- Phase I 調查紀錄 ---------------------------------------------------
  exclusions_file = "exclusions.csv",

  # ---- 事前申報的結構（程式會與實際資料比對並提出警告）--------------------
  declared = {{DECLARED}},

  # ---- 製程背景（用於合理分組建議與 OCAP；依事前問答設定）-----------------
  process = {{PROCESS}},
  ocap = {{OCAP}}
)
