#!/usr/bin/env python3
"""Finds questions where two options have the same numeric value (59 : 51 and 118 : 102, 1/2 and 0.5, √16 and 4)."""
import glob, json, re
from fractions import Fraction

SUP = str.maketrans("²³", "  ")


def value(text):
    t = text.replace(",", "").replace("Rs", "").strip().rstrip("%").strip()
    t = re.sub(r"\s*(cm|km|m|kg|g|N|J|V|W|s|Hz|m/s|cm²|m²|cm³|m³|km/h|days|hours|minutes)$", "", t).strip()
    if m := re.fullmatch(r"(-?\d+(?:\.\d+)?)\s*:\s*(\d+(?:\.\d+)?)", t):
        return ("ratio", Fraction(m[1]) / Fraction(m[2]) if float(m[2]) else None)
    if m := re.fullmatch(r"√(\d+)", t):
        root = int(m[1]) ** 0.5
        return ("n", Fraction(int(root)) if root == int(root) else None)
    if m := re.fullmatch(r"(-?\d+)/(\d+)", t.replace("−", "-")):
        return ("n", Fraction(int(m[1]), int(m[2])) if int(m[2]) else None)
    if re.fullmatch(r"-?\d+(\.\d+)?", t.replace("−", "-")):
        return ("n", Fraction(t.replace("−", "-")))
    if m := re.fullmatch(r"(-?\d+)\s*(\d+)/(\d+)", t):
        return ("n", int(m[1]) + Fraction(int(m[2]), int(m[3])))
    return None


found = 0
for path in sorted(glob.glob("content/bank/*/*.jsonl")):
    for line in open(path):
        q = json.loads(line)
        if "options" not in q:
            continue
        values = [value(o) for o in q["options"]]
        seen = [v for v in values if v and v[1] is not None]
        if len(seen) != len(set(seen)):
            found += 1
            print(q["id"], q["options"], "key", q["answer"])
print(found, "questions with equal options")
