#!/usr/bin/env python3
"""Construit les Bibles embarquées à partir des sources JSON de data/.

    python3 scripts/build_bible.py

Sorties : assets/bible/lsg.tsv.gz et assets/bible/kjv.tsv.gz, une ligne par
verset, triées dans l'ordre canonique :

    livre \t chapitre \t verset \t paragraphe(0|1) \t texte

Le format est volontairement plat : il se lit en un passage, sans
dépendance, dans un isolat Dart. Le script refuse de produire quoi que ce
soit si les deux traductions n'ont pas exactement les mêmes versets — c'est
ce qui permet d'afficher un même passage dans les deux langues.
"""
import gzip
import hashlib
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SOURCES = {
    "lsg": ROOT / "data" / "segond_1910.json",
    "kjv": ROOT / "data" / "kjv_1769.json",
}
OUT = ROOT / "assets" / "bible"
EXPECTED_VERSES = 31102


def clean(text: str) -> tuple[bool, str]:
    paragraph = text.lstrip().startswith("¶")
    text = text.replace("¶", "").replace("\xa0", " ")
    text = re.sub(r"\s+([,.;:!?])", r"\1", text)  # « troupe [x] , car » -> « troupe [x], car »
    text = re.sub(r"\s+", " ", text).strip()
    if "\t" in text or "\n" in text:
        raise ValueError(f"caractère interdit dans : {text!r}")
    return paragraph, text


def load(path: pathlib.Path) -> dict:
    verses = json.loads(path.read_text(encoding="utf-8"))["verses"]
    out = {}
    for v in verses:
        key = (int(v["book"]), int(v["chapter"]), int(v["verse"]))
        if key in out:
            raise ValueError(f"{path.name} : verset en double {key}")
        if not v["text"].strip():
            raise ValueError(f"{path.name} : verset vide {key}")
        out[key] = clean(v["text"])
    return out


def main() -> int:
    bibles = {code: load(p) for code, p in SOURCES.items()}
    keys = {code: set(b) for code, b in bibles.items()}
    if keys["lsg"] != keys["kjv"]:
        print("Les deux traductions n'ont pas les mêmes versets :", file=sys.stderr)
        print("  seulement LSG :", sorted(keys["lsg"] - keys["kjv"])[:20], file=sys.stderr)
        print("  seulement KJV :", sorted(keys["kjv"] - keys["lsg"])[:20], file=sys.stderr)
        return 1
    for code, b in bibles.items():
        if len(b) != EXPECTED_VERSES:
            print(f"{code} : {len(b)} versets au lieu de {EXPECTED_VERSES}", file=sys.stderr)
            return 1
        if {k[0] for k in b} != set(range(1, 67)):
            print(f"{code} : il manque des livres", file=sys.stderr)
            return 1

    OUT.mkdir(parents=True, exist_ok=True)
    for code, b in bibles.items():
        lines = [f"{k[0]}\t{k[1]}\t{k[2]}\t{int(p)}\t{t}" for k, (p, t) in sorted(b.items())]
        data = ("\n".join(lines) + "\n").encode("utf-8")
        # mtime=0 : un fichier identique à chaque construction (pas de faux diff Git).
        target = OUT / f"{code}.tsv.gz"
        with open(target, "wb") as raw, gzip.GzipFile(fileobj=raw, mode="wb", mtime=0, compresslevel=9) as gz:
            gz.write(data)
        print(f"{target.relative_to(ROOT)} : {len(lines)} versets, "
              f"{target.stat().st_size // 1024} Ko, sha256 {hashlib.sha256(data).hexdigest()[:12]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
