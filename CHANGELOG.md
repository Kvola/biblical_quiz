# Journal des versions

Le numéro de version (`version:` de `pubspec.yaml`, sous la forme `nom+build`) est repris dans le nom des APK de `dist/`. Le numéro de build augmente à chaque version publiée : Android refuse d'installer une mise à jour dont le numéro est inférieur ou égal à celui de la version installée.

## 1.5.0 (build 6) — 9 novembre 2026

- **Bandeau « nouvelle version »** (Android) : quand une version plus récente est publiée sur la page de téléchargement, un bandeau propose de la télécharger (« Plus tard » le masque pour cette version). Vérification au plus toutes les 12 h, silencieuse hors connexion ; une mise à jour déclarée obligatoire par le serveur ne peut pas être masquée. Le quiz reste entièrement utilisable sans Internet.
- Permission Internet déclarée (elle manquait aux APK de publication : seule la vérification des nouvelles versions s'en sert).

## 1.4.0 (build 5) — 8 novembre 2026

- **Tester ce chapitre** : en bas de chaque chapitre du lecteur, un quiz de 5 questions sur ce chapitre seulement.
- **Ma lecture de la Bible** (onglet Progrès) : chapitres lus sur 1 189, livres commencés et terminés, avancement par Testament,
  et les 66 livres en tuiles remplies selon les chapitres lus. Toucher un livre montre ses chapitres (lus en vert) :
  ouvrir un chapitre dans le lecteur, ou lancer un quiz sur ce livre.
- Lecteur : boutons « Précédent » / « Suivant » (le libellé long était coupé).
- **APK signés avec la clé définitive** (empreinte SHA-256 `25:3D:55:8F:…:7D:CE`). Une version antérieure, signée avec la clé
  de développement, doit être désinstallée avant d'installer celle-ci (Android refuse la mise à jour) ; ensuite, toutes les
  mises à jour s'installeront par-dessus.

## 1.3.0 (build 4) — 8 novembre 2026

- **Quiz sur mes lectures** (Accueil, ou « Quiz sur ce livre » dans le lecteur) : un quiz sur un ou plusieurs livres choisis.
  - Raccourcis : « Mes lectures » et chaque genre (Pentateuque, Évangiles, Épîtres…) ; sur les chapitres lus ou les livres entiers ; 10, 15 ou 20 questions.
  - Les questions relues viennent d'abord (avec leur passage, « Jean 6 ») ; des questions tirées du texte même complètent le quiz,
    signalées « Tiré du texte » : compléter un verset, « Dans quel livre ? » parmi les livres choisis, ordre du récit.
  - Ces questions sont justes par construction et vérifiées par les tests sur les 66 livres (FR et EN) : le verset n'est jamais modifié,
    les propositions incorrectes sont des mots, des livres ou des passages réels. Elles ne vont pas en révision.
- **Chapitres lus** : notés tout seuls par le lecteur (temps de lecture suffisant et fin du chapitre atteinte), ou à la main
  (« Marquer comme lu » en bas du chapitre, ou tout un livre depuis le quiz) pour une lecture dans une Bible papier.
- « Effacer ma progression » efface aussi les chapitres lus. Base de données : version 2 (migration sans perte).

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
