# Contenu du Quiz Biblique — règles et format

Le but de l'application : **aider à lire et comprendre la Bible** en s'intéressant
à ce dont elle parle. Le quiz est un compagnon de lecture : on lit un passage,
puis des questions vérifient qu'on l'a compris, et chaque réponse est expliquée
et renvoie au texte.

## Règles éditoriales (obligatoires)

1. **Inter-confessionnel, factuel, centré sur le texte.** On demande ce que le
   texte *dit*, jamais ce qu'une Église en *conclut*. Pas de doctrine propre à
   une confession (baptême, sacrements, Marie, prédestination, dons, millénium,
   sabbat/dimanche, etc. : seulement si la question porte sur ce que dit
   littéralement le verset). Formules : « Selon ce passage… », « Que dit… ».
2. **Vrai dans les deux traductions.** Chaque question doit être juste avec la
   Louis Segond 1910 (FR) **et** la King James 1769 (EN). Vérifier le texte des
   deux (data/segond_1910.json, data/kjv_1769.json ; le script
   `python3 scripts/verse.py 43:3:16` affiche un passage dans les deux).
   Attention aux différences de noms : FR utilise ceux de la Segond (l'Eternel,
   Esaïe, Elie, Ésaü…), EN ceux de la KJV (the LORD, Esaias/Isaiah selon le
   livre cité, Elias/Elijah…). Une citation entre guillemets doit être **mot
   pour mot** celle de la traduction de la langue.
3. **Répondable depuis le passage.** La réponse se trouve dans les passages de
   la leçon (ou, pour une fiche de livre, dans le livre). Le champ `ref` pointe
   le verset exact qui la justifie.
4. **L'explication enseigne.** `explain` (1 à 3 phrases) dit pourquoi c'est la
   bonne réponse en s'appuyant sur le texte, et ajoute si utile un élément de
   contexte factuel (lieu, époque, sens d'un mot). Pas de sermon.
5. **Bons distracteurs.** Plausibles, de même forme et longueur que la bonne
   réponse, sans piège de vocabulaire ni « toutes les réponses ». Une seule
   réponse juste. Pas d'humour.
6. **Variété.** 4 à 6 questions par leçon, au plus 2 vrai/faux. Mélanger :
   faits du récit, sens d'une parole, lien avec le reste de la Bible quand le
   texte lui-même le fait (citation explicite).
7. **Langue.** Français soigné et naturel (pas de traduction mot à mot de
   l'anglais) ; anglais naturel et moderne pour les questions (les citations
   restent KJV). Les deux versions disent la même chose.
8. **Longueur de lecture.** Les passages d'une leçon totalisent 5 à 50 versets.

## Références

Chaîne `livre:chapitre:verset`, livres numérotés 1 (Genèse) à 66 (Apocalypse) :

| Forme | Exemple | Sens |
|---|---|---|
| `B:C:V` | `43:3:16` | un verset |
| `B:C:V-V` | `1:1:1-31` | versets d'un chapitre |
| `B:C:V-C:V` | `1:1:1-2:3` | à cheval sur deux chapitres |

## Fichiers

### `assets/content/paths/<id>.json` — un parcours

```json
{
  "id": "story",
  "order": 1,
  "icon": "auto_stories",
  "title": {"fr": "Le grand récit", "en": "The big story"},
  "description": {"fr": "…", "en": "…"},
  "lessons": [
    {
      "id": "story-creation",
      "title": {"fr": "Au commencement", "en": "In the beginning"},
      "passages": ["1:1:1-31", "1:2:1-3"],
      "intro": {"fr": "1 à 3 phrases de contexte avant de lire.", "en": "…"},
      "keyVerse": "1:1:1",
      "takeaway": {"fr": "Ce que dit le passage, en 1 à 2 phrases factuelles.", "en": "…"},
      "questions": [
        {
          "id": "story-creation-1",
          "kind": "choice",
          "q": {"fr": "Selon Genèse 1, qu'est-ce que Dieu crée le premier jour ?", "en": "…"},
          "choices": {"fr": ["La lumière", "Les étoiles", "Les plantes", "L'homme"], "en": ["…", "…", "…", "…"]},
          "answer": 0,
          "explain": {"fr": "…", "en": "…"},
          "ref": "1:1:3"
        },
        {
          "id": "story-creation-2",
          "kind": "truefalse",
          "q": {"fr": "Affirmation à juger vraie ou fausse.", "en": "…"},
          "answer": true,
          "explain": {"fr": "…", "en": "…"},
          "ref": "1:1:27"
        }
      ]
    }
  ]
}
```

- `id` de leçon : `<id du parcours>-<mot>` ; `id` de question : `<id leçon>-<n>`.
  **Ne jamais changer un id publié** : la progression des utilisateurs y est attachée.
- `choices` : 3 ou 4 propositions, mêmes nombres en FR et EN, **la bonne réponse
  à l'indice `answer`** dans les deux langues (l'application mélange l'ordre).
- `icon` : un nom d'icône Material (snake_case).

### `assets/content/books.json` — les 66 livres

```json
[
  {
    "id": 1,
    "keyVerse": "1:1:1",
    "fr": {"name": "Genèse", "abbr": "Gn", "author": "…", "period": "…",
           "summary": "2 à 4 phrases.", "themes": ["Création", "Alliance", "…"]},
    "en": {"name": "Genesis", "abbr": "Gen", "author": "…", "period": "…",
           "summary": "…", "themes": ["…"]},
    "questions": [ /* 2 ou 3 questions, même format, id "book-1-1"… */ ]
  }
]
```

- `author` : attribution **traditionnelle et prudente** (« Traditionnellement
  attribué à Moïse », « Anonyme », « L'apôtre Paul (1:1) »).
- `period` : ce dont parle le livre et/ou quand il a été écrit, formulé
  prudemment (« Écrit vers 55 apr. J.-C. »).
- Noms et abréviations : ceux de `scripts/books.py`.

## Vérification

```bash
python3 scripts/validate_content.py
```

Le validateur refuse : JSON invalide, champ manquant ou vide, langue manquante,
référence inexistante dans l'une des deux Bibles, `ref` hors des passages de la
leçon, indice de réponse hors limites, propositions en double, nombre de
propositions différent entre FR et EN, ids en double, passages trop longs ou
trop courts, plus de 2 vrai/faux par leçon. Les tests Flutter l'exécutent aussi.
