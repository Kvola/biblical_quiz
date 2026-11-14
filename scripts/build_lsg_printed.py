#!/usr/bin/env python3
"""Construit la table « numérotation des Segond imprimées » (assets/bible/lsg_printed.json).

Le texte Segond embarqué (data/segond_1910.json) suit la numérotation de la
King James, pour que les deux Bibles partagent les mêmes références. Les
Segond imprimées suivent par endroits la numérotation hébraïque : dans les
Psaumes, le titre compte souvent comme verset 1 (Ps 19:7 ici = Ps 19:8 sur
papier) ; Joël, Jonas, Malachie… ont quelques chapitres découpés autrement.

    python3 scripts/build_lsg_printed.py <ls1910.json>

<ls1910.json> : une Segond 1910 à la numérotation d'origine, au format de
https://api.getbible.net/v2/ls1910.json (fichier non versionné, ~10 Mo).

Les deux textes sont alignés mot à mot, livre par livre (ils ne diffèrent que
par la typographie), ce qui donne pour chaque verset embarqué le ou les versets
imprimés qui portent son texte. On n'écrit que les chapitres où la
numérotation diffère, sous forme de plages :

    {"19:51": [[1, 1, 51, 1, 51, 3], [2, 19, 51, 4, 51, 21]], …}
    [premier verset, dernier verset, chapitre imprimé, verset imprimé,
     chapitre imprimé de fin, verset imprimé de fin]

Une plage de plusieurs versets avance d'un verset imprimé par verset (même
décalage) ; une plage d'un seul verset peut couvrir plusieurs versets imprimés.
Quand les éditions coupent un verset un ou deux mots plus tôt ou plus tard, on
garde le verset imprimé qui porte la majorité des mots (pas de faux décalage).
"""
import difflib
import json
import pathlib
import re
import sys
import unicodedata

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "bible" / "lsg_printed.json"

# Chapitres où la source découpe autrement que la Segond 1910 imprimée (vérifié) :
# on ne signale rien plutôt que d'afficher un numéro faux.
IGNORE = {
    "41:9",  # Marc 9 : la source scinde le v. 50 en deux (51 versets) ; la Segond en a 50.
}


def words(text):
    t = unicodedata.normalize("NFKD", text.replace("œ", "oe").replace("Œ", "OE").replace("æ", "ae"))
    t = "".join(ch for ch in t if not unicodedata.combining(ch)).lower()
    return re.findall(r"[a-z0-9]+", t)


def stream(verses):
    """verses : liste ordonnée de ((chapitre, verset), texte) -> (mots, verset de chaque mot)."""
    ws, owner = [], []
    for key, text in verses:
        for w in words(text):
            ws.append(w)
            owner.append(key)
    return ws, owner


def main(src):
    ours = {}
    for v in json.loads((ROOT / "data" / "segond_1910.json").read_text(encoding="utf-8"))["verses"]:
        ours.setdefault(v["book"], []).append(((v["chapter"], v["verse"]), v["text"].replace("¶", "")))
    printed = {}
    for b in json.loads(pathlib.Path(src).read_text(encoding="utf-8"))["books"]:
        printed[b["nr"]] = [((v["chapter"], v["verse"]), v["text"]) for c in b["chapters"] for v in c["verses"]]

    table, worst = {}, []
    for book in range(1, 67):
        a_w, a_own = stream(sorted(ours[book]))
        b_w, b_own = stream(printed[book])
        sm = difflib.SequenceMatcher(None, a_w, b_w, autojunk=False)
        match = [None] * len(a_w)
        for blk in sm.get_matching_blocks():
            for k in range(blk.size):
                match[blk.a + k] = blk.b + k
        ratio = sum(1 for m in match if m is not None) / max(1, len(a_w))
        worst.append((ratio, book))
        # Pour chaque verset embarqué, les versets imprimés qui portent ses mots. Les
        # éditions coupent parfois un verset un ou deux mots plus tôt ou plus tard :
        # on retient le verset imprimé qui porte la majorité de ses mots, sauf s'il
        # contient en entier plusieurs versets imprimés (titre d'un psaume compté à
        # part) : on retient alors toute la plage.
        printed_size = {}
        for key in b_own:
            printed_size[key] = printed_size.get(key, 0) + 1
        counts = {}
        for i, key in enumerate(a_own):
            if match[i] is not None:
                c = counts.setdefault(key, {})
                p = b_own[match[i]]
                c[p] = c.get(p, 0) + 1
        span = {}
        for key, _ in ours[book]:
            c = counts.get(key)
            if not c:
                sys.exit(f"livre {book} {key} : aucun mot apparié — alignement à vérifier")
            full = sorted(p for p, n in c.items() if n == printed_size[p])
            if len(full) >= 2:
                span[key] = [full[0], full[-1]]
            else:
                best = max(c.items(), key=lambda kv: (kv[1], kv[0] == key))[0]
                span[key] = [best, best]
        rows = {}
        for key, _ in sorted(ours[book]):
            rows.setdefault(key[0], []).append((key[1], *span[key][0], *span[key][1]))
        for chap, vs in rows.items():
            if all((c1, v1, c2, v2) == (chap, v, chap, v) for v, c1, v1, c2, v2 in vs):
                continue
            runs, linear = [], []
            for v, c1, v1, c2, v2 in vs:
                single = (c1, v1) == (c2, v2)
                last = runs[-1] if runs else None
                if (last and single and linear[-1] and last[1] == v - 1
                        and last[2] == c1 and last[3] + (v - last[0]) == v1):
                    last[1] = v
                    last[4], last[5] = c1, v1
                else:
                    runs.append([v, v, c1, v1, c2, v2])
                    linear.append(single)
            if f"{book}:{chap}" not in IGNORE:
                table[f"{book}:{chap}"] = runs
    worst.sort()
    print("alignement le plus faible (part des mots appariés) :",
          ", ".join(f"livre {b} {r:.3f}" for r, b in worst[:5]))
    OUT.write_text(json.dumps(table, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
    print(f"{OUT.relative_to(ROOT)} : {len(table)} chapitres numérotés autrement")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
