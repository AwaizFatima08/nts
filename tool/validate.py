#!/usr/bin/env python3
"""Checks every file in content/bank against the schema in docs/content-schema.md.

  python3 tool/validate.py                 whole bank, plus coverage against the blueprint
  python3 tool/validate.py --files a b     only those files (repo-wide duplicate check still runs)
Exit 1 if any error is found.
"""
import argparse, collections, json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BP = json.loads((ROOT / "content/blueprint.json").read_text())
TOPICS = {(s["key"], t["key"]): t for s in BP["sections"] for t in s["topics"]}
BANNED = re.compile(r"all of the above|none of the above|both a and b|both \(?[a-d]\)?\b", re.I)
LATEX = re.compile(r"\\\(|\\\[|\\frac|\$[^ ]")
SET_TOPICS = {("verbal", "comprehension"), ("analytical", "scenario")}


def norm(s):
    return re.sub(r"[^a-z0-9]+", " ", s.lower()).strip()


def load(path, errors):
    rows = []
    for n, line in enumerate(path.read_text().splitlines(), 1):
        if not line.strip():
            continue
        try:
            rows.append((n, json.loads(line)))
        except json.JSONDecodeError as e:
            errors.append(f"{path.name}:{n}: bad JSON: {e}")
    return rows


def check_question(q, where, section, topic, errors):
    def err(msg):
        errors.append(f"{where} {q.get('id', '?')}: {msg}")

    for field in ("id", "pool", "level", "stem", "options", "answer", "explanation"):
        if field not in q:
            err(f"missing {field}")
            return
    meta = TOPICS.get((section, topic))
    if not meta:
        err(f"unknown section/topic {section}/{topic}")
        return
    pool = q["pool"]
    if pool not in ("test", "practice"):
        err("pool must be test or practice")
    if not re.fullmatch(rf"{meta['prefix']}-{'t' if pool == 'test' else 'p'}\d{{4}}", q["id"]):
        err(f"id must look like {meta['prefix']}-t0001 / {meta['prefix']}-p0001")
    if q["level"] not in (1, 2, 3):
        err("level must be 1, 2 or 3")
    opts = q["options"]
    if not (isinstance(opts, list) and len(opts) == 4 and all(isinstance(o, str) and o.strip() for o in opts)):
        err("needs exactly 4 non-empty options")
        return
    if len({re.sub(r"\s+", "", o.lower()) for o in opts}) != 4:
        err("options are not all different")
    if not (isinstance(q["answer"], int) and 0 <= q["answer"] <= 3):
        err("answer must be 0..3")
    if len(q["explanation"]) < 30:
        err("explanation too short")
    if len(q["stem"]) > 700:
        err("stem too long (passages belong in a set)")
    text = " ".join([q["stem"], q["explanation"], *opts])
    if BANNED.search(text):
        err("uses an all/none-of-the-above style option")
    if LATEX.search(text):
        err("LaTeX found; use plain Unicode maths")
    if (section, topic) in SET_TOPICS and "set" not in q:
        err("this topic needs a set id")
    table = q.get("table")
    if table is not None and not (isinstance(table, list) and table and all(isinstance(r, list) and len(r) == len(table[0]) for r in table)):
        err("table must be a list of equal-length rows")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--files", nargs="*")
    args = ap.parse_args()
    errors, warns = [], []
    all_files = sorted((ROOT / "content/bank").glob("*/*.jsonl"))
    only = {Path(f).resolve() for f in args.files} if args.files else None
    ids, stems, sets, used_sets = {}, {}, {}, []
    counts = collections.Counter()
    keys = collections.Counter()
    levels = collections.Counter()
    longest = wordy = 0
    for path in all_files:
        section = path.parent.name
        topic = re.sub(r"-\d+$", "", path.stem)
        report = only is None or path.resolve() in only
        sink = errors if report else []
        for n, row in load(path, sink):
            where = f"{section}/{path.name}:{n}"
            if row.get("type") == "set":
                sid = row.get("id", "")
                if sid in sets:
                    sink.append(f"{where}: duplicate set {sid}")
                sets[sid] = row
                if len(row.get("text", "")) < 60:
                    sink.append(f"{where}: set text too short")
                continue
            check_question(row, where, section, topic, sink)
            qid = row.get("id", "?")
            if qid in ids:
                sink.append(f"{where}: duplicate id {qid} (also {ids[qid]})")
            ids[qid] = where
            sid = row.get("set")
            if sid:
                used_sets.append((where, qid, sid, sink))
            key = (norm(row.get("stem", "")), sid or "")
            if key in stems and topic not in ("synonym", "antonym"):
                sink.append(f"{where}: same stem as {stems[key]}")
            if topic in ("synonym", "antonym") and key in stems:
                sink.append(f"{where}: same stem as {stems[key]}")
            stems[key] = qid
            counts[(section, topic, row.get("pool"))] += 1
            if report and isinstance(row.get("answer"), int):
                keys[row["answer"]] += 1
                opts = row.get("options", [])
                if len(opts) == 4:
                    lengths = [len(o) for o in opts]
                    if lengths[row["answer"]] == max(lengths) and lengths.count(max(lengths)) == 1 and max(lengths) >= 20:
                        longest += 1
                    if max(lengths) >= 20:
                        wordy += 1
                levels[row.get("level")] += 1
    for where, qid, sid, sink in used_sets:
        if sid not in sets:
            sink.append(f"{where} {qid}: set {sid} not found")
    for e in errors[:200]:
        print("ERROR", e)
    total = sum(keys.values())
    if total:
        print("answer keys", {k: round(v / total, 2) for k, v in sorted(keys.items())}, "levels", dict(sorted(levels.items())))
        if wordy >= 20:
            share = longest / wordy
            print(f"correct option is the longest in {share:.0%} of {wordy} wordy questions (chance 25%)")
            if share > 0.40:
                print("WARN correct answers stand out by length; rebalance the options")
        if min(keys.get(i, 0) for i in range(4)) < total * 0.15 and total >= 40:
            print("WARN answer keys unevenly spread")
    if only is None:
        short = 0
        for (s, t), meta in TOPICS.items():
            for pool in ("test", "practice"):
                have, want = counts[(s, t, pool)], meta[pool]
                if have < want:
                    short += want - have
        print(f"coverage: {sum(counts.values())} questions, {short} still to write")
    print(f"{len(errors)} errors")
    sys.exit(1 if errors else 0)


main()
