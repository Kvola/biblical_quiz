#!/usr/bin/env python3
"""Affiche un passage dans les deux traductions.

    python3 scripts/verse.py 43:3:16 1:1:1-5 19:23:1-23:6
"""
import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from refs import parse_ref, expand  # noqa: E402

ROOT = pathlib.Path(__file__).resolve().parent.parent


def load(name):
    verses = json.loads((ROOT / "data" / name).read_text(encoding="utf-8"))["verses"]
    return {(v["book"], v["chapter"], v["verse"]): v["text"].replace("¶", "").strip() for v in verses}


def main():
    lsg, kjv = load("segond_1910.json"), load("kjv_1769.json")
    for arg in sys.argv[1:]:
        print(f"== {arg}")
        for key in expand(parse_ref(arg), lsg):
            print(f"{key[1]}:{key[2]}  FR  {lsg[key]}")
            print(f"{' ' * len(f'{key[1]}:{key[2]}')}  EN  {kjv[key]}")


if __name__ == "__main__":
    main()
