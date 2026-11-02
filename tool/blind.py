#!/usr/bin/env python3
"""Answer-free copy of bank files for a blind solver, and the comparison afterwards.

  python3 tool/blind.py export <out.jsonl> file1.jsonl file2.jsonl ...
  python3 tool/blind.py compare <solver.jsonl> file1.jsonl file2.jsonl ...
Solver lines: {"id": "...", "answer": 0-3, "note": "optional doubt"}. Options are unchanged in order.
"""
import json, sys
from pathlib import Path


def rows(files):
    for f in files:
        for line in Path(f).read_text().splitlines():
            if line.strip():
                yield json.loads(line)


cmd, out, *files = sys.argv[1:]
if cmd == "export":
    with open(out, "w") as fh:
        for r in rows(files):
            r.pop("answer", None)
            r.pop("explanation", None)
            fh.write(json.dumps(r, ensure_ascii=False) + "\n")
else:
    solved = {r["id"]: r for r in rows([out])}
    bad = missing = ok = 0
    for r in rows(files):
        if r.get("type") == "set":
            continue
        s = solved.get(r["id"])
        if s is None:
            missing += 1
            print("MISSING", r["id"])
        elif s.get("answer") != r["answer"] or s.get("note"):
            bad += 1
            print(f"CHECK {r['id']}: key {r['answer']}, solver {s.get('answer')}. {s.get('note', '')}\n  {r['stem'][:160]}\n  {r['options']}")
        else:
            ok += 1
    print(f"{ok} agree, {bad} to check, {missing} missing")
