#!/usr/bin/env python3
"""Copie vers le backend Odoo (biblical_quiz_backend/data/content/) ce dont le
serveur a besoin pour fabriquer lui-même les questions des matchs :

- les deux Bibles (lsg.tsv.gz, kjv.tsv.gz), telles quelles ;
- questions.json : les questions RELUES à choix multiple (parcours + fiches des
  livres), sous forme compacte, triées par id (sortie stable).

Vérifie aussi que la table des livres du backend (game/books.py) est identique
à scripts/books.py.

Usage : python3 scripts/sync_backend_content.py [chemin/du/backend]
"""
import importlib.util
import json
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
from books import BOOKS  # noqa: E402
from refs import parse_ref  # noqa: E402

DEFAULT_BACKEND = ROOT.parent / "biblical_quiz_backend"


def curated_questions():
    """Questions à choix multiple du contenu, par id (les vrai/faux sont écartés)."""
    sources = sorted((ROOT / "assets/content/paths").glob("*.json"))
    found = {}

    def add(q, where):
        if q.get("kind") != "choice":
            return
        qid = q["id"]
        if qid in found:
            raise SystemExit(f"id en double : {qid} ({where})")
        parse_ref(q["ref"])  # lève si la référence est mal formée
        fr, en = q["choices"]["fr"], q["choices"]["en"]
        if len(fr) != len(en) or not 2 <= len(fr) <= 4 or not 0 <= q["answer"] < len(fr):
            raise SystemExit(f"{qid} : propositions incohérentes")
        found[qid] = {
            "id": qid,
            "ref": q["ref"],
            "q": {"fr": q["q"]["fr"], "en": q["q"]["en"]},
            "explain": {"fr": q["explain"]["fr"], "en": q["explain"]["en"]},
            "choices": {"fr": fr, "en": en},
            "answer": q["answer"],
        }

    for f in sources:
        data = json.loads(f.read_text(encoding="utf-8"))
        for lesson in data["lessons"]:
            for q in lesson.get("questions", []):
                add(q, f.name)
    for book in json.loads((ROOT / "assets/content/books.json").read_text(encoding="utf-8")):
        for q in book.get("questions", []):
            add(q, "books.json")
    return [found[k] for k in sorted(found)]


def check_books(backend):
    """La table du backend doit rester celle de scripts/books.py."""
    spec = importlib.util.spec_from_file_location("backend_books", backend / "game/books.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    if [tuple(b) for b in mod.BOOKS] != [tuple(b) for b in BOOKS]:
        raise SystemExit("game/books.py diffère de scripts/books.py : recopier la table")


def main():
    backend = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else DEFAULT_BACKEND
    out = backend / "data/content"
    out.mkdir(parents=True, exist_ok=True)
    for name in ("lsg.tsv.gz", "kjv.tsv.gz"):
        shutil.copyfile(ROOT / "assets/bible" / name, out / name)
    questions = curated_questions()
    text = json.dumps(questions, ensure_ascii=False, separators=(",", ":"))
    (out / "questions.json").write_text(text + "\n", encoding="utf-8")
    if (backend / "game/books.py").exists():
        check_books(backend)
    size = sum(p.stat().st_size for p in out.iterdir() if p.is_file())
    print(f"{len(questions)} questions relues -> {out} ({size / 1e6:.2f} Mo au total)")


if __name__ == "__main__":
    main()
