# Quiz Biblique · Bible Quiz

*Lire et comprendre la Bible.* Application mobile Flutter (Android et iOS), en français et en anglais, **entièrement hors ligne**.

Ce n'est pas un jeu de culture générale : c'est un **compagnon de lecture**. Pour chaque leçon, on lit un court passage dans l'application, puis quelques questions vérifient qu'on l'a compris. Chaque réponse est expliquée et renvoie au verset qui la justifie.

| | Français | English |
|---|---|---|
| Texte biblique | Louis Segond 1910 | King James Version 1769 |
| Statut | domaine public | domaine public (hors Royaume-Uni, où la Couronne garde des droits) |

## Contenu

| Parcours | Leçons | Ce qu'on y découvre |
|---|---|---|
| Le grand récit | 17 | Le fil de la Bible, de la création à la nouvelle création |
| Qui est Dieu ? | 11 | Ce que la Bible dit de Dieu, avec ses propres mots |
| Jésus | 15 | Ce que les Évangiles racontent de ses paroles et de ses actes |
| Les grands thèmes | 13 | Pardon, grâce, foi, prière, amour, justice, espérance… |
| Des hommes et des femmes | 16 | Noé, Abraham, Ruth, David, Esther, Marie, Pierre, Paul… |
| Prier et méditer | 12 | Psaumes, Proverbes, Ecclésiaste, Job |
| Les 66 livres | 66 fiches | De quoi parle chaque livre, qui l'a écrit, verset clé, quiz |

Soit **669 questions**, toutes en français et en anglais.

**Principe éditorial** : inter-confessionnel, factuel, centré sur le texte. On demande ce que le texte *dit*, jamais ce qu'une Église en conclut. Les règles complètes et le format des fichiers sont dans [CONTENT.md](CONTENT.md).

## Fonctionnalités

- **Accueil** : la leçon suivante, la série de jours de lecture, les questions à revoir, le verset du jour.
- **Leçon** : intro de contexte, lecture du passage (lecture bilingue possible : l'autre traduction sous chaque verset), questions avec correction et explication immédiates, « à retenir » et verset clé.
- **Révision espacée** : une question ratée revient le lendemain, puis de plus en plus rarement quand elle est réussie (boîtes de Leitner : 1, 3, 7, 16, 35 jours), jusqu'à être « acquise ».
- **Défi « Dans quel livre ? »** : retrouver le livre d'un verset clé (questions construites à partir du texte embarqué : justes par construction).
- **Recherche** : par mots (tous présents, dans n'importe quel ordre), `"expression exacte"` ou `-mot` exclu, sans tenir compte des accents ni des majuscules, dans toute la Bible, un Testament ou un livre, en Segond ou en King James ; résultats répartis par livre et surlignés ; une référence (« Jean 3:16 », « 1 Co 13 ») ouvre le passage ; recherches récentes.
- **Bible** : lecture libre chapitre par chapitre, reprise là où on s'était arrêté ; toucher un verset pour le copier, le partager ou le mettre de côté.
- **Progrès** : série, leçons, réponses, taux de réussite, questions acquises, versets mis de côté.
- **Réglages** : langue (la traduction biblique suit la langue), thème (celui du téléphone, clair ou sombre), taille du texte, lecture bilingue, effacement de la progression.

## Fiabilité

- **Contenu vérifié automatiquement** (`scripts/validate_content.py`, exécuté aussi par les tests et avant chaque APK) : format, langues, chaque référence existe dans les deux Bibles, la référence d'une question est dans le passage lu, bonnes réponses et propositions cohérentes, ids uniques, et **chaque citation entre guillemets d'une explication ou d'une bonne réponse existe mot pour mot dans la traduction de sa langue**.
- **Bibles alignées** : `scripts/build_bible.py` refuse de construire si les deux traductions n'ont pas exactement les mêmes 31 102 versets.
- **Progression** : SQLite (Drift), écritures transactionnelles (une leçon terminée met à jour d'un bloc la leçon, chaque question et le jour), migrations versionnées. Une série abandonnée en cours de route n'est pas enregistrée.
- **Tests** : logique pure (références, séries, révision, quiz), Bibles et contenu, base de données, et parcours de bout en bout dans l'interface (FR et EN).

## Couleurs, mode sombre et bords d'écran

- **Palette sémantique** (`QuizPalette` dans `lib/core/theme.dart`) : chaque couleur (bonne réponse, erreur, or d'une étiquette, carte d'accueil…) a une valeur pour le mode clair et une pour le mode sombre. Les écrans n'emploient jamais directement les couleurs de marque (`QuizColors`) pour un texte ou une icône.
- **Contraste vérifié par test** (`test/theme_contrast_test.dart`) : dans les deux modes, chaque texte atteint au moins 4,5:1 sur son fond et chaque icône ou bordure 3:1 (WCAG AA).
- **Bords d'écran** : Android 15+ affiche l'application jusqu'aux bords. Le corps de chaque écran et chaque feuille du bas respecte les zones de sécurité (barre de gestes, encoche), pour qu'aucun bouton ne passe dessous ; un test le vérifie en simulant une barre de gestes.
- **Écran de lancement** aux couleurs de l'application, en clair et en sombre, y compris sur Android 12+.

## Architecture

```
lib/
  core/      références de versets, table des 66 livres, thème
  bible/     chargement des Bibles embarquées (décompression dans un isolat)
  content/   modèles et chargement du contenu (parcours, leçons, questions, fiches)
  domain/    logique pure et testée : déroulé du quiz, révision espacée, séries, défi des livres
  data/      base Drift, dépôts (progression, réglages)
  ui/        écrans (accueil, parcours, leçon/quiz, Bible, progrès, réglages)
  l10n/      textes FR/EN (générés depuis scripts/gen_arb.py)
assets/
  bible/     lsg.tsv.gz, kjv.tsv.gz (générés depuis data/)
  content/   paths/*.json, books.json
data/        sources JSON des deux Bibles
scripts/     construction, validation, relecture, publication
branding/    logo SVG
```

État : Riverpod 3. Base : Drift (SQLite).

## Commandes

```bash
flutter pub get
dart run build_runner build                       # après modification des tables (lib/data/database.dart)
python3 scripts/gen_arb.py && flutter gen-l10n    # après modification des textes de l'interface
python3 scripts/build_bible.py                    # après modification de data/*.json
python3 scripts/validate_content.py               # après toute modification du contenu
python3 scripts/verse.py 43:3:16 1:1:1-5          # afficher un passage dans les deux traductions
python3 scripts/export_review.py                  # cahier de relecture -> build/relecture.html
swift scripts/svg2png.swift branding/icon-foreground.svg assets/branding/icon-foreground.png 1024
                                                  # SVG -> PNG transparent (ne pas utiliser Quick Look : fond blanc)
dart run flutter_launcher_icons                   # après modification des icônes
flutter test
flutter run
```

## Relire le contenu

`python3 scripts/export_review.py` produit `build/relecture.html`, à ouvrir dans un navigateur : chaque leçon et chaque question avec la bonne réponse, l'explication et le texte du verset dans les deux traductions, côte à côte. On peut cocher chaque question « relue » et noter une remarque ; le bouton **Copier mes remarques** les rassemble en texte. Les points à trancher en priorité sont listés en tête du cahier.

Pour corriger une question, modifier le fichier JSON concerné dans `assets/content/`, puis relancer `python3 scripts/validate_content.py`. **Ne jamais changer l'`id` d'une leçon ou d'une question publiée** : la progression des utilisateurs y est attachée.

## Installer sur un téléphone Android

```bash
scripts/build_release_apk.sh
```

Le script valide le contenu puis produit dans `dist/` :
- `QuizBiblique-<version>.apk` : téléphones récents (arm64), le bon fichier dans la quasi-totalité des cas ;
- `QuizBiblique-<version>-ancien.apk` : anciens téléphones 32 bits.

## Clé de signature Android

Android n'accepte une mise à jour que si elle est signée avec **la même clé** que la version installée. Il faut donc créer la clé une fois, puis la garder précieusement. Le dépôt est **public** : la clé et ses mots de passe ne doivent jamais y entrer.

1. Créer la clé, une seule fois, **hors du dépôt** :
   ```bash
   mkdir -p ~/biblical-quiz-cles
   /Users/icp/development/jdk17/Contents/Home/bin/keytool -genkeypair -v \
     -keystore ~/biblical-quiz-cles/biblical-quiz-release.jks -alias biblical_quiz \
     -keyalg RSA -keysize 4096 -validity 10000
   ```
2. Copier `android/key.properties.example` en `android/key.properties` et le remplir (avec un fichier PKCS12, `storePassword` et `keyPassword` ont la même valeur). Ce fichier est ignoré par Git.
3. `scripts/build_release_apk.sh` signe alors avec cette clé et l'indique dans son message de fin.

⚠️ **Sauvegardez le fichier `.jks` et ses mots de passe** (clé USB, coffre de mots de passe). Sans eux, impossible de publier une mise à jour.

## Avant publication

- Relire le contenu (`build/relecture.html`).
- Créer la clé de signature (ci-dessus).
- iOS : configurer l'équipe de développement Apple dans Xcode ; le nom affiché est « Quiz Biblique » (traduction du nom pour l'anglais à ajouter dans Xcode si souhaité).
- Identifiants : Android `ci.ivorycocoa.biblical_quiz`, iOS `ci.ivorycocoa.biblicalQuiz`.

## Licence

Code : à préciser par Kvola. Textes bibliques : Louis Segond 1910 et King James Version 1769, domaine public.
