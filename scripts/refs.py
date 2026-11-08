"""Analyse des références « livre:chapitre:verset » (même grammaire que lib/core/verse_ref.dart)."""
import re

_RE = re.compile(r"^(\d{1,2}):(\d{1,3}):(\d{1,3})(?:-(?:(\d{1,3}):)?(\d{1,3}))?$")


class RefError(ValueError):
    pass


def parse_ref(text):
    """Renvoie (livre, (chap, vers) début, (chap, vers) fin)."""
    m = _RE.match(text.strip())
    if not m:
        raise RefError(f"référence mal formée : {text!r}")
    book, c1, v1, c2, v2 = m.groups()
    book, c1, v1 = int(book), int(c1), int(v1)
    if v2 is None:
        end = (c1, v1)
    else:
        end = (int(c2) if c2 else c1, int(v2))
    start = (c1, v1)
    if not 1 <= book <= 66:
        raise RefError(f"livre inconnu : {text!r}")
    if end < start:
        raise RefError(f"fin avant le début : {text!r}")
    return book, start, end


def expand(ref, bible):
    """Clés (livre, chap, vers) couvertes, dans l'ordre. Exige que début et fin existent."""
    book, start, end = ref
    if (book, *start) not in bible or (book, *end) not in bible:
        raise RefError(f"verset inexistant : {book}:{start[0]}:{start[1]}-{end[0]}:{end[1]}")
    return [k for k in sorted(bible) if k[0] == book and start <= (k[1], k[2]) <= end]
