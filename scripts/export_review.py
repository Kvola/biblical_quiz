#!/usr/bin/env python3
"""Produit le cahier de relecture du contenu : un fichier HTML autonome.

    python3 scripts/export_review.py            # -> build/relecture.html

Pour chaque leçon : passages, intro, « à retenir », puis chaque question avec
la bonne réponse marquée, l'explication, et le texte du verset de référence
dans les deux traductions, côte à côte (FR | EN).

Dans le navigateur, chaque question peut être cochée « relue » et recevoir
une remarque. Ces marques restent dans le navigateur (localStorage) ; le
bouton « Copier mes remarques » les rassemble en texte, prêt à envoyer.
"""
import html
import json
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from books import BOOKS  # noqa: E402
from refs import expand, parse_ref  # noqa: E402

ROOT = HERE.parent
CONTENT = ROOT / "assets" / "content"
OUT = ROOT / "build" / "relecture.html"
NAMES = {b[0]: (b[1], b[3]) for b in BOOKS}

# Points signalés par les rédacteurs, à trancher en priorité.
FLAGS = [
    ("Convention « Lord »", "Le texte KJV embarqué écrit « the Lord » (sans petites capitales). Tout le texte anglais a été aligné sur cette forme pour que les citations correspondent exactement à ce qui s'affiche."),
    ("Contexte hors du passage lu", "Quelques intros et explications ajoutent un fait de contexte qui ne figure pas dans les versets lus : sens d'un mot hébreu (Mara, vanité/buée, nom divin d'Ex 3:15), « Christ = oint », heures juives, Pentecôte, acrostiche de Pr 31, chute de Ninive en 612 av. J.-C., ordre des livres. Vérifier le ton et l'exactitude."),
    ("Sujets sensibles entre confessions", "themes-grace-5 (Ép 2:8-10, œuvres et salut) ; leçon jesus-supper (keyVerse Mc 14:22) ; people-mary (Lc 1:26-38) ; people-peter ; book-46 (dons spirituels) ; book-63 (« Kyria l'élue » / « the elect lady »). Les questions s'en tiennent au texte : valider les explications."),
    ("Écarts entre traductions", "Les rédacteurs ont évité de poser des questions sur les versets où LSG et KJV divergent (Ps 8:5, Pr 31:10, Ec 3:11, Jn 6:11, Mc 14:24, Mt 28:19, Ph 4:13, Ga 2:16, 2 Th 2:2). Quelques réponses diffèrent légèrement d'une langue à l'autre en restant fidèles à chaque texte (ex. wisdom-psalm121-1 : « les montagnes » / « the hills » ; people-samuel-1 : « rare » / « precious »)."),
    ("Numérotation des versets", "Les deux Bibles embarquées suivent la numérotation de la KJV, y compris pour la Segond (ex. Jonas 1:17, Joël 2:28, Malachie 4:5, suscriptions des Psaumes en verset 1). Un lecteur qui ouvre une Segond papier peut voir un décalage d'un verset à ces endroits."),
    ("Attributions et dates", "Auteurs et dates des fiches de livres sont formulés prudemment (« traditionnellement attribué à », « vers… », « date discutée »). Pastorales et 2 Pierre : attribution selon 1:1, sans mention des débats savants."),
    ("Orthographe des majuscules", "Les citations gardent l'orthographe de la Segond 1910 (Eternel, Esaïe, Eglise sans accent sur la majuscule) ; le texte rédigé emploie parfois les majuscules accentuées (Église, Écriture). À harmoniser si vous le souhaitez."),
]


def load_bible(name):
    verses = json.loads((ROOT / "data" / name).read_text(encoding="utf-8"))["verses"]
    return {(v["book"], v["chapter"], v["verse"]): v["text"].replace("¶", "").strip() for v in verses}


LSG, KJV = load_bible("segond_1910.json"), load_bible("kjv_1769.json")


def label(code, lang):
    book, (c1, v1), (c2, v2) = parse_ref(code)
    name = NAMES[book][0 if lang == "fr" else 1]
    if (c1, v1) == (c2, v2):
        return f"{name} {c1}:{v1}"
    if c1 == c2:
        return f"{name} {c1}:{v1}-{v2}"
    return f"{name} {c1}:{v1}–{c2}:{v2}"


def verse_text(code, bible):
    keys = expand(parse_ref(code), bible)
    return " ".join(f"<sup>{k[2]}</sup>{html.escape(bible[k])}" for k in keys)


e = html.escape


def question_html(q):
    qid = q["id"]
    if q["kind"] == "truefalse":
        fr_opts = [("Vrai", q["answer"] is True), ("Faux", q["answer"] is False)]
        en_opts = [("True", q["answer"] is True), ("False", q["answer"] is False)]
    else:
        fr_opts = [(c, i == q["answer"]) for i, c in enumerate(q["choices"]["fr"])]
        en_opts = [(c, i == q["answer"]) for i, c in enumerate(q["choices"]["en"])]

    def opts(items):
        return "".join(f'<li class="{"ok" if good else ""}">{"✔ " if good else ""}{e(t)}</li>' for t, good in items)

    return f"""
<div class="q" id="{e(qid)}">
  <div class="qhead"><code>{e(qid)}</code>
    <label class="done"><input type="checkbox" data-id="{e(qid)}"> relue</label></div>
  <div class="cols">
    <div><p class="prompt">{e(q["q"]["fr"])}</p><ul>{opts(fr_opts)}</ul>
      <p class="explain">{e(q["explain"]["fr"])}</p></div>
    <div><p class="prompt">{e(q["q"]["en"])}</p><ul>{opts(en_opts)}</ul>
      <p class="explain">{e(q["explain"]["en"])}</p></div>
  </div>
  <div class="cols verse">
    <div><b>{e(label(q["ref"], "fr"))}</b> — {verse_text(q["ref"], LSG)}</div>
    <div><b>{e(label(q["ref"], "en"))}</b> — {verse_text(q["ref"], KJV)}</div>
  </div>
  <textarea data-note="{e(qid)}" placeholder="Remarque (facultatif)…"></textarea>
</div>"""


def main():
    paths = sorted((json.loads(p.read_text(encoding="utf-8")) for p in (CONTENT / "paths").glob("*.json")),
                   key=lambda p: p["order"])
    books = json.loads((CONTENT / "books.json").read_text(encoding="utf-8"))
    total = sum(len(l["questions"]) for p in paths for l in p["lessons"]) + sum(len(b["questions"]) for b in books)

    toc, body = [], []
    for p in paths:
        toc.append(f'<li><a href="#{p["id"]}">{e(p["title"]["fr"])}</a> ({len(p["lessons"])} leçons)</li>')
        body.append(f'<h2 id="{p["id"]}">{e(p["title"]["fr"])} <small>/ {e(p["title"]["en"])}</small></h2>'
                    f'<p class="desc">{e(p["description"]["fr"])}</p>')
        for l in p["lessons"]:
            passages = " · ".join(e(label(x, "fr")) for x in l["passages"])
            body.append(f"""
<section class="lesson" id="{l["id"]}">
  <h3>{e(l["title"]["fr"])} <small>/ {e(l["title"]["en"])} — <code>{e(l["id"])}</code></small></h3>
  <p class="meta">À lire : {passages} · Verset clé : {e(label(l["keyVerse"], "fr"))}</p>
  <div class="cols">
    <div><p><b>Intro.</b> {e(l["intro"]["fr"])}</p><p><b>À retenir.</b> {e(l["takeaway"]["fr"])}</p></div>
    <div><p><b>Intro.</b> {e(l["intro"]["en"])}</p><p><b>Key point.</b> {e(l["takeaway"]["en"])}</p></div>
  </div>
  {"".join(question_html(q) for q in l["questions"])}
</section>""")
    toc.append('<li><a href="#books">Les 66 livres</a></li>')
    body.append('<h2 id="books">Les 66 livres <small>/ The 66 books</small></h2>')
    for b in books:
        fr, en = b["fr"], b["en"]
        body.append(f"""
<section class="lesson" id="book-{b["id"]}">
  <h3>{b["id"]}. {e(fr["name"])} <small>/ {e(en["name"])}</small></h3>
  <div class="cols">
    <div><p><b>Auteur :</b> {e(fr["author"])}<br><b>Époque :</b> {e(fr["period"])}</p><p>{e(fr["summary"])}</p>
      <p><b>Thèmes :</b> {e(" · ".join(fr["themes"]))}</p></div>
    <div><p><b>Author:</b> {e(en["author"])}<br><b>Period:</b> {e(en["period"])}</p><p>{e(en["summary"])}</p>
      <p><b>Themes:</b> {e(" · ".join(en["themes"]))}</p></div>
  </div>
  <p class="meta">Verset clé : {e(label(b["keyVerse"], "fr"))} — {verse_text(b["keyVerse"], LSG)}</p>
  {"".join(question_html(q) for q in b["questions"])}
</section>""")

    flags = "".join(f"<li><b>{e(t)}.</b> {e(d)}</li>" for t, d in FLAGS)
    page = f"""<!doctype html>
<html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Relecture — Quiz Biblique</title>
<style>
:root {{ --night:#1E3A5F; --gold:#C9A227; --paper:#FBF7EF; --ink:#1F2430; --ok:#3F7D3A; --line:#e4dccb; }}
body {{ margin:0; background:var(--paper); color:var(--ink); font:16px/1.5 system-ui, sans-serif; }}
header {{ background:var(--night); color:#fff; padding:20px 16px; position:sticky; top:0; z-index:2; }}
header h1 {{ margin:0; font-size:20px; }} header p {{ margin:4px 0 0; opacity:.85; }}
header button {{ margin-top:8px; background:var(--gold); border:0; padding:8px 14px; border-radius:8px; font-weight:600; cursor:pointer; }}
main {{ max-width:1100px; margin:0 auto; padding:16px; }}
h2 {{ color:var(--night); border-bottom:3px solid var(--gold); padding-bottom:4px; margin-top:40px; }}
h3 {{ margin:0 0 4px; }} small {{ font-weight:400; color:#6b6355; }}
.lesson {{ background:#fff; border:1px solid var(--line); border-radius:14px; padding:16px; margin:16px 0; }}
.meta, .desc {{ color:#6b6355; font-size:14px; }}
.cols {{ display:grid; grid-template-columns:1fr 1fr; gap:16px; }}
@media (max-width:720px) {{ .cols {{ grid-template-columns:1fr; }} }}
.q {{ border-top:1px dashed var(--line); padding-top:12px; margin-top:12px; }}
.q.checked {{ opacity:.55; }}
.qhead {{ display:flex; justify-content:space-between; align-items:center; }}
.prompt {{ font-weight:600; margin:6px 0; }}
ul {{ margin:0; padding-left:20px; }} li.ok {{ color:var(--ok); font-weight:700; }}
.explain {{ background:#f6f1e6; border-radius:8px; padding:8px 10px; font-size:15px; }}
.verse {{ font-family:Georgia, serif; font-size:15px; color:#3a3428; margin-top:8px; }}
sup {{ color:var(--night); font-weight:700; margin-right:2px; }}
textarea {{ width:100%; box-sizing:border-box; margin-top:8px; min-height:38px; border:1px solid var(--line); border-radius:8px; padding:6px 8px; font:inherit; }}
.flags li {{ margin-bottom:8px; }}
code {{ font-size:13px; color:#6b6355; }}
</style></head><body>
<header><h1>Relecture du Quiz Biblique</h1>
<p>{len(paths)} parcours, 66 fiches de livres, {total} questions · <span id="progress"></span></p>
<button id="copy">Copier mes remarques</button></header>
<main>
<h2>Points signalés par les rédacteurs</h2><ul class="flags">{flags}</ul>
<h2>Sommaire</h2><ul>{"".join(toc)}</ul>
{"".join(body)}
</main>
<script>
const KEY = 'bq-review-v1';
let state = {{}};
try {{ state = JSON.parse(localStorage.getItem(KEY) || '{{}}'); }} catch (e) {{ state = {{}}; }}
const save = () => {{ try {{ localStorage.setItem(KEY, JSON.stringify(state)); }} catch (e) {{}} refresh(); }};
function refresh() {{
  const boxes = document.querySelectorAll('input[data-id]');
  let n = 0;
  boxes.forEach(b => {{ const s = state[b.dataset.id] || {{}}; b.checked = !!s.done; if (s.done) n++;
    b.closest('.q').classList.toggle('checked', !!s.done); }});
  document.getElementById('progress').textContent = n + ' / ' + boxes.length + ' relues';
}}
document.querySelectorAll('input[data-id]').forEach(b => b.addEventListener('change', () => {{
  (state[b.dataset.id] ||= {{}}).done = b.checked; save(); }}));
document.querySelectorAll('textarea[data-note]').forEach(t => {{
  t.value = (state[t.dataset.note] || {{}}).note || '';
  t.addEventListener('input', () => {{ (state[t.dataset.note] ||= {{}}).note = t.value; save(); }}); }});
document.getElementById('copy').addEventListener('click', async () => {{
  const lines = Object.entries(state).filter(([, s]) => s.note && s.note.trim()).map(([id, s]) => id + ' : ' + s.note.trim());
  const text = lines.length ? lines.join('\\n') : '(aucune remarque)';
  try {{ await navigator.clipboard.writeText(text); alert(lines.length + ' remarque(s) copiée(s).'); }}
  catch (e) {{ prompt('Copiez ce texte :', text); }}
}});
refresh();
</script></body></html>
"""
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(page, encoding="utf-8")
    print(f"{OUT.relative_to(ROOT)} : {total} questions")


if __name__ == "__main__":
    main()
