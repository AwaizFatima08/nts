#!/usr/bin/env python3
"""Applies reviewed corrections to the bank: python3 tool/patch.py fixes.json
fixes.json: {"<question id>": {"stem": "...", "options": [...], "answer": 1, "explanation": "..."}}. Only the fields given change."""
import json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
fixes = json.loads(Path(sys.argv[1]).read_text())
left = set(fixes)
for path in sorted((ROOT / "content/bank").glob("*/*.jsonl")):
    lines = path.read_text().splitlines()
    changed = False
    for i, line in enumerate(lines):
        if not line.strip():
            continue
        row = json.loads(line)
        if row.get("id") in fixes:
            row.update(fixes[row["id"]])
            left.discard(row["id"])
            lines[i] = json.dumps(row, ensure_ascii=False)
            changed = True
    if changed:
        path.write_text("\n".join(lines) + "\n")
print(f"{len(fixes) - len(left)} patched", "NOT FOUND: " + ", ".join(sorted(left)) if left else "")
