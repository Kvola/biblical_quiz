# Journal des versions

Le numéro de version (`version:` de `pubspec.yaml`, sous la forme `nom+build`) est repris dans le nom des APK de `dist/`. Le numéro de build augmente à chaque version publiée : Android refuse d'installer une mise à jour dont le numéro est inférieur ou égal à celui de la version installée.

## 1.2.0 (build 3) — 8 novembre 2026

- **Recherche de versets**, hors ligne, dans la Segond et la King James :
  - plusieurs mots (tous présents, dans n'importe quel ordre), `"expression exacte"`, `-mot` pour exclure ;
  - accents et majuscules ignorés ; un mot trouve aussi ceux qui commencent par lui (option « Mots entiers ») ;
  - filtres : toute la Bible, Ancien ou Nouveau Testament, un livre ; recherche dans l'autre traduction ;
  - répartition des résultats par livre (touchez un livre pour filtrer), mots trouvés surlignés ;
  - une référence (« Jean 3:16 », « Jn 3 16 », « 1 Co 13 ») ouvre directement le passage ;
  - recherches récentes ; appui long sur un résultat : copier, partager, mettre de côté.
- **Lecteur** : ouvert sur un verset (recherche, verset mis de côté), il défile jusqu'à lui et le surligne.

## 1.1.0 (build 2) — 8 novembre 2026

- **Mode sombre lisible** : palette déclinée en clair et en sombre, contraste vérifié (WCAG AA) pour chaque texte et chaque icône. La carte « Pour commencer » de l'accueil, illisible en sombre, et plusieurs icônes invisibles sont corrigées ; l'or des étiquettes, trop pâle en mode clair aussi.
- **Réglage du thème** : celui du téléphone, clair ou sombre.
- **Bords d'écran** : plus rien d'utile sous la barre de gestes ou l'encoche (Android 15 et plus), y compris dans les feuilles qui s'ouvrent du bas.
- **Série** : seule une vraie lecture de la Bible compte (avant, l'application ouverte 20 secondes suffisait).
- **Leçons** : toucher un verset ouvre sa feuille (copier, partager, mettre de côté).
- **Leçon en cours** : le bouton retour demande confirmation avant de quitter.
- **Verset du jour et défi** : uniquement des versets qui forment une phrase complète.
- **Icône et écran de lancement** aux couleurs de l'application, en clair et en sombre.

## 1.0.0 (build 1) — 8 novembre 2026

- Première version : 6 parcours (84 leçons) et 66 fiches de livres, 669 questions en français (Louis Segond 1910) et en anglais (King James 1769), entièrement hors ligne.
