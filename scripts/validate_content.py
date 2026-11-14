#!/usr/bin/env python3
"""Valide le contenu du quiz (voir CONTENT.md).

    python3 scripts/validate_content.py                 # tout
    python3 scripts/validate_content.py paths/story.json # un fichier (relatif à assets/content)

Code de sortie 0 si tout est valide, 1 sinon (toutes les erreurs sont listées).
"""
import json
import pathlib
import re
import sys
import unicodedata

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from books import BOOKS  # noqa: E402
from refs import RefError, expand, parse_ref  # noqa: E402

ROOT = HERE.parent
CONTENT = ROOT / "assets" / "content"
LANGS = ("fr", "en")
ID_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
MIN_VERSES, MAX_VERSES = 5, 50


def known_icons():
    """Noms d'icônes reconnus par pathIcon() (lib/core/theme.dart) : un nom absent
    afficherait silencieusement l'icône par défaut."""
    src = (ROOT / "lib" / "core" / "theme.dart").read_text(encoding="utf-8")
    body = src.split("IconData pathIcon(", 1)[1].split("};", 1)[0]
    return set(re.findall(r"'([a-z0-9_]+)'\s*=>", body))


ICONS = known_icons()


def known_groups():
    try:
        return {g.get("id") for g in json.loads((CONTENT / "groups.json").read_text(encoding="utf-8"))
                if isinstance(g, dict)}
    except (OSError, json.JSONDecodeError):
        return set()


GROUPS = known_groups()


def load_bible(name):
    verses = json.loads((ROOT / "data" / name).read_text(encoding="utf-8"))["verses"]
    return {(v["book"], v["chapter"], v["verse"]) for v in verses}


def norm(s):
    """Forme de comparaison des citations : casse, ligatures, apostrophes et ponctuation ignorées."""
    s = unicodedata.normalize("NFC", s).lower().replace("’", "'").replace("œ", "oe").replace("æ", "ae")
    return re.sub(r"\s+", " ", re.sub(r"[^\w']+", " ", s)).strip()


def bible_text(name):
    verses = json.loads((ROOT / "data" / name).read_text(encoding="utf-8"))["verses"]
    return norm(" ".join(v["text"].replace("¶", "") for v in verses))


# Citations : « … » en français, "…" ou “…” en anglais. Les coupures (… ou [ ])
# découpent la citation en segments vérifiés séparément.
QUOTE_RE = {"fr": re.compile(r"«\s*([^»]+?)\s*»"), "en": re.compile(r"[“\"]([^”\"]+)[”\"]")}
MIN_QUOTE = 12


class Checker:
    def __init__(self):
        lsg, kjv = load_bible("segond_1910.json"), load_bible("kjv_1769.json")
        assert lsg == kjv, "les deux Bibles doivent avoir les mêmes versets"
        self.bible = lsg
        self.texts = {"fr": bible_text("segond_1910.json"), "en": bible_text("kjv_1769.json")}
        self.errors = []
        self.ids = {}

    def err(self, where, msg):
        self.errors.append(f"{where} : {msg}")

    # -- briques ---------------------------------------------------------
    def text(self, where, value, field, min_len=1):
        if not isinstance(value, dict):
            self.err(where, f"« {field} » doit être un objet {{fr, en}}")
            return
        for lang in LANGS:
            v = value.get(lang)
            if not isinstance(v, str) or len(v.strip()) < min_len:
                self.err(where, f"« {field}.{lang} » manquant ou trop court")
            elif v != v.strip() or "  " in v:
                self.err(where, f"« {field}.{lang} » : espaces superflus")
        extra = set(value) - set(LANGS)
        if extra:
            self.err(where, f"« {field} » : clés inattendues {sorted(extra)}")

    def quotes(self, where, value, field):
        """Toute citation d'un texte affirmé vrai doit exister mot pour mot dans la traduction de sa langue.

        Les propositions fausses (distracteurs) ne sont pas vérifiées : elles peuvent être inventées.
        Un nom propre ou un titre (Sermon sur la montagne) s'écrit sans guillemets.
        """
        if not isinstance(value, dict):
            return
        for lang in LANGS:
            text = value.get(lang)
            if not isinstance(text, str):
                continue
            for m in QUOTE_RE[lang].finditer(text):
                for seg in re.split(r"…|\.\.\.|\[[^\]]*\]", m.group(1)):
                    k = norm(seg)
                    if len(k) >= MIN_QUOTE and k not in self.texts[lang]:
                        self.err(where, f"{field}.{lang} : citation introuvable dans la Bible : « {seg.strip()[:80]} »")

    def ref(self, where, value):
        """Renvoie l'ensemble des versets couverts, ou un ensemble vide en cas d'erreur."""
        if not isinstance(value, str):
            self.err(where, f"référence attendue, trouvé {value!r}")
            return set()
        try:
            return set(expand(parse_ref(value), self.bible))
        except RefError as e:
            self.err(where, str(e))
            return set()

    def unique_id(self, where, value):
        if not isinstance(value, str) or not ID_RE.match(value):
            self.err(where, f"id invalide {value!r} (minuscules, chiffres, tirets)")
            return
        if value in self.ids:
            self.err(where, f"id « {value} » déjà utilisé dans {self.ids[value]}")
        self.ids[value] = where

    def question(self, where, q, allowed_verses, id_prefix):
        if not isinstance(q, dict):
            self.err(where, "question : objet attendu")
            return None
        qid = q.get("id")
        w = f"{where} › {qid}"
        self.unique_id(w, qid)
        if isinstance(qid, str) and not qid.startswith(id_prefix + "-"):
            self.err(w, f"l'id doit commencer par « {id_prefix}- »")
        self.text(w, q.get("q"), "q", 8)
        self.text(w, q.get("explain"), "explain", 15)
        self.quotes(w, q.get("explain"), "explain")
        verses = self.ref(w, q.get("ref"))
        if verses and allowed_verses is not None and not verses <= allowed_verses:
            self.err(w, f"ref {q.get('ref')} hors des passages lus")
        kind = q.get("kind")
        if kind == "choice":
            choices = q.get("choices")
            if not isinstance(choices, dict) or set(choices) != set(LANGS):
                self.err(w, "« choices » doit avoir fr et en")
                return kind
            counts = set()
            for lang in LANGS:
                c = choices[lang]
                if not isinstance(c, list) or not all(isinstance(x, str) and x.strip() for x in c):
                    self.err(w, f"choices.{lang} : liste de textes non vides attendue")
                    continue
                counts.add(len(c))
                if len({x.strip().lower() for x in c}) != len(c):
                    self.err(w, f"choices.{lang} : propositions en double")
            if len(counts) > 1:
                self.err(w, "nombre de propositions différent entre fr et en")
            n = counts.pop() if len(counts) == 1 else 0
            if n and not 3 <= n <= 4:
                self.err(w, "3 ou 4 propositions attendues")
            a = q.get("answer")
            if not isinstance(a, int) or isinstance(a, bool) or not (0 <= a < max(n, 1)):
                self.err(w, f"answer {a!r} hors des propositions")
            elif all(isinstance(choices.get(l), list) and len(choices[l]) > a for l in LANGS):
                self.quotes(w, {l: choices[l][a] for l in LANGS}, "bonne réponse")
        elif kind == "truefalse":
            if not isinstance(q.get("answer"), bool):
                self.err(w, "answer doit être true ou false")
            if "choices" in q:
                self.err(w, "un vrai/faux n'a pas de « choices »")
        else:
            self.err(w, f"kind inconnu {kind!r}")
        allowed = {"id", "kind", "q", "choices", "answer", "explain", "ref"}
        if set(q) - allowed:
            self.err(w, f"clés inattendues {sorted(set(q) - allowed)}")
        return kind

    def questions(self, where, qs, allowed, prefix, lo, hi):
        if not isinstance(qs, list) or not lo <= len(qs) <= hi:
            self.err(where, f"{lo} à {hi} questions attendues")
            return
        kinds = [self.question(where, q, allowed, prefix) for q in qs]
        if kinds.count("truefalse") > 2:
            self.err(where, "au plus 2 vrai/faux")

    # -- fichiers --------------------------------------------------------
    def path_file(self, path):
        where = path.relative_to(CONTENT).as_posix()
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            self.err(where, f"JSON invalide : {e}")
            return
        pid = data.get("id")
        self.unique_id(where, pid)
        if pid != path.stem:
            self.err(where, f"l'id « {pid} » doit être le nom du fichier « {path.stem} »")
        if not isinstance(data.get("order"), int):
            self.err(where, "« order » entier attendu")
        if not isinstance(data.get("icon"), str) or not re.match(r"^[a-z0-9_]+$", data.get("icon") or ""):
            self.err(where, "« icon » : nom d'icône Material attendu")
        elif data["icon"] not in ICONS:
            self.err(where, f"« icon » : « {data['icon']} » absent de pathIcon() (lib/core/theme.dart)")
        if data.get("group") not in GROUPS:
            self.err(where, f"« group » : « {data.get('group')} » absent de groups.json ({', '.join(sorted(GROUPS))})")
        extra = set(data) - {"id", "order", "icon", "group", "title", "description", "lessons"}
        if extra:
            self.err(where, f"clés inattendues {sorted(extra)}")
        self.text(where, data.get("title"), "title", 3)
        self.text(where, data.get("description"), "description", 20)
        lessons = data.get("lessons")
        if not isinstance(lessons, list) or not lessons:
            self.err(where, "« lessons » : liste non vide attendue")
            return
        for i, lesson in enumerate(lessons):
            lid = lesson.get("id") if isinstance(lesson, dict) else None
            w = f"{where} › {lid or f'leçon {i + 1}'}"
            if not isinstance(lesson, dict):
                self.err(w, "objet attendu")
                continue
            self.unique_id(w, lid)
            if isinstance(lid, str) and isinstance(pid, str) and not lid.startswith(pid + "-"):
                self.err(w, f"l'id doit commencer par « {pid}- »")
            self.text(w, lesson.get("title"), "title", 3)
            self.text(w, lesson.get("intro"), "intro", 20)
            self.text(w, lesson.get("takeaway"), "takeaway", 20)
            self.quotes(w, lesson.get("intro"), "intro")
            self.quotes(w, lesson.get("takeaway"), "takeaway")
            passages = lesson.get("passages")
            verses = set()
            if not isinstance(passages, list) or not passages:
                self.err(w, "« passages » : liste non vide attendue")
            else:
                for p in passages:
                    covered = self.ref(w, p)
                    if covered & verses:
                        self.err(w, f"passage {p} recoupe un autre passage")
                    verses |= covered
                if verses and not MIN_VERSES <= len(verses) <= MAX_VERSES:
                    self.err(w, f"{len(verses)} versets à lire (attendu {MIN_VERSES} à {MAX_VERSES})")
            kv = self.ref(w, lesson.get("keyVerse"))
            if kv and verses and not kv <= verses:
                self.err(w, "keyVerse hors des passages")
            self.questions(w, lesson.get("questions"), verses or None, lid or "?", 4, 6)
            allowed = {"id", "title", "passages", "intro", "keyVerse", "takeaway", "questions"}
            if set(lesson) - allowed:
                self.err(w, f"clés inattendues {sorted(set(lesson) - allowed)}")

    def books_file(self, path):
        where = path.name
        partial = path.name != "books.json"  # brouillon books_*.json : un sous-ensemble suivi
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            self.err(where, f"JSON invalide : {e}")
            return
        ids = [b.get("id") for b in data] if isinstance(data, list) else []
        first = ids[0] if ids and isinstance(ids[0], int) else 1
        expected = list(range(first, first + len(ids))) if partial else list(range(1, 67))
        if not ids or ids != expected or not 1 <= first <= ids[-1] <= 66:
            self.err(where, "livres attendus dans l'ordre, ids consécutifs (1 à 66 pour books.json)")
            return
        for book, ref in zip(data, BOOKS[first - 1:]):
            num, fr_name, fr_abbr, en_name, en_abbr, _ = ref
            w = f"{where} › {num} {fr_name}"
            book_verses = {k for k in self.bible if k[0] == num}
            for lang, name, abbr in (("fr", fr_name, fr_abbr), ("en", en_name, en_abbr)):
                block = book.get(lang)
                if not isinstance(block, dict):
                    self.err(w, f"bloc « {lang} » manquant")
                    continue
                if block.get("name") != name or block.get("abbr") != abbr:
                    self.err(w, f"{lang} : nom/abréviation attendus « {name} » / « {abbr} »")
                for f, n in (("author", 3), ("period", 3), ("summary", 60)):
                    v = block.get(f)
                    if not isinstance(v, str) or len(v.strip()) < n:
                        self.err(w, f"{lang}.{f} manquant ou trop court")
                self.quotes(w, {lang: block.get("summary") or ""}, "summary")
                themes = block.get("themes")
                if not isinstance(themes, list) or not 2 <= len(themes) <= 5 or not all(
                        isinstance(t, str) and t.strip() for t in themes):
                    self.err(w, f"{lang}.themes : 2 à 5 thèmes attendus")
            if isinstance(book.get("fr"), dict) and isinstance(book.get("en"), dict):
                if len(book["fr"].get("themes") or []) != len(book["en"].get("themes") or []):
                    self.err(w, "autant de thèmes en fr et en en")
            kv = self.ref(w, book.get("keyVerse"))
            if kv and not kv <= book_verses:
                self.err(w, "keyVerse hors du livre")
            self.questions(w, book.get("questions"), book_verses, f"book-{num}", 2, 3)
            allowed = {"id", "keyVerse", "fr", "en", "questions"}
            if set(book) - allowed:
                self.err(w, f"clés inattendues {sorted(set(book) - allowed)}")


    def groups_file(self, path):
        where = path.name
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            self.err(where, f"JSON invalide : {e}")
            return
        if not isinstance(data, list) or not data:
            self.err(where, "liste non vide attendue")
            return
        orders = []
        for i, g in enumerate(data):
            w = f"{where} › {g.get('id') if isinstance(g, dict) else i + 1}"
            if not isinstance(g, dict):
                self.err(w, "objet attendu")
                continue
            if not isinstance(g.get("id"), str) or not ID_RE.match(g["id"]):
                self.err(w, "« id » attendu")
            if not isinstance(g.get("order"), int):
                self.err(w, "« order » entier attendu")
            orders.append(g.get("order"))
            self.text(w, g.get("title"), "title", 3)
            self.text(w, g.get("description"), "description", 20)
            if set(g) - {"id", "order", "title", "description"}:
                self.err(w, f"clés inattendues {sorted(set(g) - {'id', 'order', 'title', 'description'})}")
        if len(orders) != len(set(orders)):
            self.err(where, "deux groupes ont le même « order »")
        ids = [g.get("id") for g in data if isinstance(g, dict)]
        if len(ids) != len(set(ids)):
            self.err(where, "deux groupes ont le même id")

    def printed_file(self, path):
        """Table des numéros de la Segond imprimée (scripts/build_lsg_printed.py) : chaque
        chapitre listé doit être couvert entièrement, sans trou ni recouvrement."""
        where = path.relative_to(ROOT).as_posix()
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as e:
            self.err(where, f"illisible : {e}")
            return
        counts = {}
        for (b, c, _v) in self.bible:
            counts[(b, c)] = counts.get((b, c), 0) + 1
        for key, runs in data.items():
            try:
                b, c = map(int, key.split(":"))
            except ValueError:
                self.err(where, f"clé « {key} » : « livre:chapitre » attendu")
                continue
            expected = 1
            for r in runs:
                if (not isinstance(r, list) or len(r) != 6 or not all(isinstance(x, int) and x > 0 for x in r)
                        or r[0] != expected or r[1] < r[0] or (r[1] > r[0] and r[2:4] != [r[4], r[5] - (r[1] - r[0])])
                        or (r[2], r[3]) > (r[4], r[5])):
                    self.err(where, f"{key} : plage invalide {r}")
                    break
                expected = r[1] + 1
            else:
                if expected - 1 != counts.get((b, c)):
                    self.err(where, f"{key} : {expected - 1} versets couverts, {counts.get((b, c))} attendus")


def main(argv):
    c = Checker()
    targets = [CONTENT / a for a in argv] if argv else (
        sorted((CONTENT / "paths").glob("*.json")) + [CONTENT / "books.json", CONTENT / "groups.json"])
    n_questions = 0
    for t in targets:
        if not t.exists():
            c.err(t.name, "fichier introuvable")
        elif t.name.startswith("books"):
            c.books_file(t)
        elif t.name == "groups.json":
            c.groups_file(t)
        else:
            c.path_file(t)
    n_questions = sum(1 for i in c.ids if re.search(r"-\d+$", i))
    if not argv:
        c.printed_file(ROOT / "assets" / "bible" / "lsg_printed.json")
        orders = []
        for p in sorted((CONTENT / "paths").glob("*.json")):
            try:
                orders.append(json.loads(p.read_text(encoding="utf-8")).get("order"))
            except json.JSONDecodeError:
                pass
        if len(orders) != len(set(orders)):
            c.err("paths", "deux parcours ont le même « order »")
    for e in c.errors:
        print("✗", e)
    print(f"{len(targets)} fichier(s), {n_questions} question(s), {len(c.errors)} erreur(s)")
    return 1 if c.errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
