#!/usr/bin/env python3
"""把 spc_functions.R 的各段程式與設定檔插入報告範本，產生可直接 render 的 qmd。

用法：
  python3 assemble_report.py --template stat|general --config cfg.R --title "標題" --out report.qmd

範本中的 `# <<SPC:名稱>>` 會換成 spc_functions.R 中 `## ---- block: 名稱 ----` 那一段；
`# <<SPC:config>>` 換成設定檔內容；`{{TITLE}}` 換成標題。產出的 qmd 自成一體，不需要另外的 R 檔。
"""
import argparse, re, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent.parent / "assets"

def blocks(src: str) -> dict:
    out, cur, buf = {}, None, []
    for line in src.splitlines():
        m = re.match(r"^## ---- block: (\w+) ----\s*$", line)
        if m:
            if cur: out[cur] = "\n".join(buf).strip("\n")
            cur, buf = m.group(1), []
        elif cur:
            buf.append(line)
    if cur: out[cur] = "\n".join(buf).strip("\n")
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--template", required=True, choices=["stat", "general"])
    ap.add_argument("--config", required=True)
    ap.add_argument("--title", required=True)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    tpl = (HERE / f"template_{a.template}.qmd").read_text(encoding="utf-8")
    b = blocks((HERE / "spc_functions.R").read_text(encoding="utf-8"))
    b["config"] = Path(a.config).read_text(encoding="utf-8").strip("\n")
    missing = []
    def rep(m):
        k = m.group(1)
        if k not in b: missing.append(k); return m.group(0)
        return b[k]
    tpl = re.sub(r"^# <<SPC:(\w+)>>\s*$", rep, tpl, flags=re.M)
    if missing: sys.exit(f"找不到程式段落：{missing}")
    tpl = tpl.replace("{{TITLE}}", a.title.replace('"', '\\"'))
    Path(a.out).write_text(tpl, encoding="utf-8")
    print(f"已產生 {a.out}")

if __name__ == "__main__":
    main()
