// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Quiz Biblique';

  @override
  String get tagline => 'Lire et comprendre la Bible';

  @override
  String get navHome => 'Accueil';

  @override
  String get navPaths => 'Parcours';

  @override
  String get navBible => 'Bible';

  @override
  String get navProgress => 'Progrès';

  @override
  String get close => 'Fermer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get retry => 'Réessayer';

  @override
  String get loadError => 'Le contenu n’a pas pu être chargé.';

  @override
  String get copied => 'Copié';

  @override
  String get copy => 'Copier';

  @override
  String get share => 'Partager';

  @override
  String get addFavorite => 'Mettre de côté';

  @override
  String get removeFavorite => 'Retirer des versets mis de côté';

  @override
  String get favoriteAdded => 'Verset mis de côté';

  @override
  String get favoriteRemoved => 'Verset retiré';

  @override
  String get undo => 'Annuler';

  @override
  String questionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
      zero: '0 question',
    );
    return '$_temp0';
  }

  @override
  String versesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versets',
      one: '1 verset',
      zero: '0 verset',
    );
    return '$_temp0';
  }

  @override
  String get welcomeTitle => 'Bienvenue';

  @override
  String get welcomeIntro =>
      'Ce quiz est un compagnon de lecture : il vous aide à découvrir ce dont parle la Bible.';

  @override
  String get welcomeStep1 =>
      'Lisez un court passage, directement dans l’application.';

  @override
  String get welcomeStep2 =>
      'Répondez à quelques questions pour vérifier ce que vous avez compris.';

  @override
  String get welcomeStep3 =>
      'Chaque réponse est expliquée et renvoie au verset.';

  @override
  String get welcomeOffline =>
      'Tout fonctionne sans Internet. Textes : Louis Segond 1910 (français) et King James 1769 (anglais).';

  @override
  String get chooseLanguage => 'Langue';

  @override
  String get start => 'Commencer';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours de suite',
      one: '1 jour de suite',
      zero: '0 jour de suite',
    );
    return '$_temp0';
  }

  @override
  String get streakStart => 'Commencez votre série aujourd’hui';

  @override
  String get streakKeep => 'Lisez aujourd’hui pour garder votre série';

  @override
  String get streakDone => 'Bravo, vous avez lu aujourd’hui';

  @override
  String get continueTitle => 'Continuer';

  @override
  String get startTitle => 'Pour commencer';

  @override
  String get allDone =>
      'Vous avez terminé tous les parcours. Refaites vos leçons préférées ou lisez librement la Bible.';

  @override
  String get lessonStart => 'Lire et répondre';

  @override
  String get reviewTitle => 'À revoir';

  @override
  String reviewDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions à revoir aujourd’hui',
      one: '1 question à revoir aujourd’hui',
      zero: '0 question à revoir aujourd’hui',
    );
    return '$_temp0';
  }

  @override
  String get reviewStart => 'Réviser';

  @override
  String get verseOfDay => 'Verset du jour';

  @override
  String get challengeTitle => 'Dans quel livre ?';

  @override
  String get challengeSubtitle =>
      'Retrouvez le livre d’où vient chaque verset.';

  @override
  String get challengeQuestion => 'Dans quel livre se trouve ce verset ?';

  @override
  String get play => 'Jouer';

  @override
  String get settings => 'Réglages';

  @override
  String get pathsTitle => 'Parcours';

  @override
  String lessonsProgress(int done, int total) {
    return '$done / $total leçons';
  }

  @override
  String get booksPathTitle => 'Les 66 livres';

  @override
  String get booksPathSubtitle =>
      'Une fiche par livre : de quoi il parle, qui l’a écrit, et quelques questions.';

  @override
  String bestScore(int score, int total) {
    return 'Meilleur score : $score / $total';
  }

  @override
  String get oldTestament => 'Ancien Testament';

  @override
  String get newTestament => 'Nouveau Testament';

  @override
  String get readTitle => 'À lire';

  @override
  String get introTitle => 'Avant de lire';

  @override
  String goToQuestions(int count) {
    return 'J’ai lu : aux questions ($count)';
  }

  @override
  String get showParallel => 'Afficher aussi l’autre traduction';

  @override
  String questionOf(int index, int total) {
    return 'Question $index sur $total';
  }

  @override
  String get trueLabel => 'Vrai';

  @override
  String get falseLabel => 'Faux';

  @override
  String get correct => 'Bonne réponse !';

  @override
  String get incorrect => 'Pas tout à fait';

  @override
  String correctAnswerWas(String answer) {
    return 'La bonne réponse : $answer';
  }

  @override
  String readVerse(String ref) {
    return 'Lire $ref';
  }

  @override
  String printedRef(String ref) {
    return 'Segond imprimée : $ref';
  }

  @override
  String get printedNoteTitle => 'Numéros des versets';

  @override
  String get printedNoteBody =>
      'Les numéros de versets de l’application suivent ceux de la King James, pour que le français et l’anglais aient les mêmes références.\n\nBeaucoup de Bibles Segond imprimées numérotent quelques passages autrement. Dans les Psaumes surtout, le titre du psaume y compte souvent comme verset 1 : le Psaume 19:7 de l’application est le Psaume 19:8 dans votre Bible.\n\nQuand c’est le cas, l’application indique aussi le numéro de la Segond imprimée.';

  @override
  String get printedChapterBanner =>
      'Dans une Segond imprimée, les versets de ce chapitre sont numérotés autrement. Touchez un verset pour voir son numéro sur papier.';

  @override
  String get printedMore => 'En savoir plus';

  @override
  String updateAvailable(String version) {
    return 'Version $version disponible';
  }

  @override
  String updateRequired(String version) {
    return 'Mise à jour obligatoire : version $version';
  }

  @override
  String get updateRequiredHint =>
      'Cette version n’est plus prise en charge : installez la nouvelle pour continuer.';

  @override
  String get updateDownload => 'Télécharger';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get webInstallTitle => 'Installez l’application Android';

  @override
  String get webInstallBody =>
      'Plus fluide au quotidien, et vos données ne dépendent plus du navigateur.';

  @override
  String get webInstallAction => 'Installer';

  @override
  String get homeScreenTitle => 'Ajoutez l’application à l’écran d’accueil';

  @override
  String get homeScreenBody =>
      'Touchez Partager (le carré avec une flèche), puis « Sur l’écran d’accueil ». L’application s’ouvrira en plein écran et vos données seront mieux conservées.';

  @override
  String get homeScreenDismiss => 'Compris';

  @override
  String get navNotes => 'Notes';

  @override
  String get notesTitle => 'Notes de prédication';

  @override
  String get notesEmptyTitle => 'Aucune note pour l’instant';

  @override
  String get notesEmptyBody =>
      'Pendant une prédication, notez ce que vous retenez et associez-y les passages lus. Vos notes restent sur votre téléphone.';

  @override
  String get notesNew => 'Nouvelle note';

  @override
  String get notesSearch => 'Rechercher dans mes notes';

  @override
  String get notesNoMatch => 'Aucune note ne correspond.';

  @override
  String get noteUntitled => 'Sans titre';

  @override
  String get noteTitleHint => 'Titre ou thème de la prédication';

  @override
  String get notePreacherHint => 'Prédicateur';

  @override
  String get notePlaceHint => 'Lieu, Église';

  @override
  String get noteDateTooltip => 'Jour de la prédication';

  @override
  String get notePassages => 'Passages';

  @override
  String get noteAddPassage => 'Ajouter un passage';

  @override
  String get noteBody => 'Notes';

  @override
  String get noteBodyHint =>
      'Ce que vous retenez… Les références que vous tapez (Jean 3:16, Ps 23) sont repérées.';

  @override
  String get noteFoundRefs => 'Repérés dans vos notes : touchez pour ajouter';

  @override
  String get noteReadPassages => 'Lire les passages';

  @override
  String get noteDelete => 'Supprimer la note';

  @override
  String get noteDeleted => 'Note supprimée';

  @override
  String get noteAutosave => 'Enregistrée automatiquement';

  @override
  String get notePassageRemoved => 'Passage retiré';

  @override
  String get notePassageAdded => 'Passage ajouté';

  @override
  String get noteShareFooter => 'Notes prises avec Quiz Biblique';

  @override
  String get keepScreenOnSetting => 'Garder l’écran allumé';

  @override
  String get keepScreenOnHint =>
      'Tant qu’une note de prédication est ouverte, le téléphone ne se verrouille pas.';

  @override
  String get shareImage => 'Image à partager';

  @override
  String get shareImageTitle => 'Image du verset';

  @override
  String get shareImageAction => 'Partager l’image';

  @override
  String get imageDark => 'Fond sombre';

  @override
  String get imageLight => 'Fond clair';

  @override
  String get shareImageFailed => 'L’image n’a pas pu être créée.';

  @override
  String get shareImageLong =>
      'Passage long : seul le début figure sur l’image.';

  @override
  String get backupReminderNever =>
      'Vos notes ne sont pas encore sauvegardées. Une sauvegarde permet de les retrouver si vous changez de téléphone.';

  @override
  String backupReminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
      zero: '0 jour',
    );
    return 'Dernière sauvegarde de vos notes il y a $_temp0. Pensez à en faire une nouvelle.';
  }

  @override
  String get backupNow => 'Sauvegarder';

  @override
  String get later => 'Plus tard';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareOther => 'Autre application (e-mail, SMS…)';

  @override
  String get copyText => 'Copier le texte';

  @override
  String get whatsappFailed =>
      'WhatsApp n’a pas pu s’ouvrir : choisissez une autre application.';

  @override
  String get noteQuiz => 'Tester ces passages';

  @override
  String get noteQuizTooFew => 'Ces passages sont trop courts pour un quiz.';

  @override
  String get addPassageHint => 'Ex. : Jean 3:16-18, Ps 23, 1 Co 13';

  @override
  String get addPassageInvalid =>
      'Référence non reconnue. Écrivez le livre, le chapitre puis les versets : Jean 3:16-18.';

  @override
  String get addPassageAdd => 'Ajouter';

  @override
  String get addPassageNumbering =>
      'Ce passage est numéroté autrement selon les Bibles. D’où viennent ces numéros ?';

  @override
  String get addPassagePrinted => 'Ma Bible imprimée (Segond)';

  @override
  String get addPassageApp => 'L’application';

  @override
  String get addToNote => 'Ajouter à une note';

  @override
  String addToNoteTitle(String ref) {
    return 'Ajouter $ref à…';
  }

  @override
  String addedToNote(String title) {
    return 'Ajouté à « $title »';
  }

  @override
  String alreadyInNote(String title) {
    return 'Déjà dans « $title »';
  }

  @override
  String get open => 'Ouvrir';

  @override
  String get inYourNotes => 'Dans vos notes';

  @override
  String get notesBackup => 'Sauvegarder mes notes';

  @override
  String get notesRestore => 'Restaurer une sauvegarde';

  @override
  String get notesBackupHint =>
      'Vos notes restent sur ce téléphone. Sauvegardez-les de temps en temps (Drive, e-mail…) pour les retrouver sur un autre appareil.';

  @override
  String get notesBackupEmpty => 'Aucune note à sauvegarder.';

  @override
  String notesRestoreAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouvelles notes',
      one: '1 nouvelle note',
      zero: 'aucune nouvelle note',
    );
    return '$_temp0';
  }

  @override
  String notesRestoreUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mises à jour',
      one: '1 mise à jour',
      zero: 'aucune mise à jour',
    );
    return '$_temp0';
  }

  @override
  String notesRestoreDone(String result) {
    return 'Restauration terminée : $result.';
  }

  @override
  String get notesRestoreInvalid =>
      'Ce fichier n’est pas une sauvegarde de notes du Quiz Biblique.';

  @override
  String get notesRestoreNewer =>
      'Cette sauvegarde vient d’une version plus récente : mettez l’application à jour.';

  @override
  String get notesRestoreError => 'Le fichier n’a pas pu être lu.';

  @override
  String get pathReviewTitle => 'Bilan du parcours';

  @override
  String pathReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions tirées',
      one: '1 question tirée',
      zero: '0 question tirée',
    );
    return '$_temp0 de toutes les leçons du parcours';
  }

  @override
  String get pathReviewHint => 'Idéal une fois les leçons terminées';

  @override
  String get pathReviewAction => 'Faire le bilan du parcours';

  @override
  String get nextPath => 'Parcours suivant';

  @override
  String get next => 'Suivant';

  @override
  String get seeResult => 'Voir le résultat';

  @override
  String get quitTitle => 'Quitter ?';

  @override
  String get quitBody =>
      'Vos réponses à cette série ne seront pas enregistrées.';

  @override
  String get quit => 'Quitter';

  @override
  String get stay => 'Continuer';

  @override
  String resultScore(int score, int total) {
    return '$score / $total';
  }

  @override
  String get resultPerfect => 'Parfait ! Vous avez tout compris.';

  @override
  String get resultGood => 'Très bien ! Il reste un ou deux points à revoir.';

  @override
  String get resultFair => 'C’est un début. Relire le passage aide beaucoup.';

  @override
  String get resultLow => 'Pas de souci : relisez le passage, puis réessayez.';

  @override
  String get takeawayTitle => 'À retenir';

  @override
  String get keyVerseTitle => 'Verset clé';

  @override
  String get missedTitle => 'À revoir';

  @override
  String get missedHint => 'Ces questions reviendront dans vos révisions.';

  @override
  String get rereadPassage => 'Relire le passage';

  @override
  String get retryQuiz => 'Refaire les questions';

  @override
  String get nextLesson => 'Leçon suivante';

  @override
  String get finish => 'Terminer';

  @override
  String get reviewEmpty =>
      'Rien à revoir aujourd’hui. Les questions ratées reviennent ici le lendemain.';

  @override
  String get bookAuthor => 'Auteur';

  @override
  String get bookPeriod => 'Époque';

  @override
  String get bookThemes => 'Thèmes';

  @override
  String bookChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapitres',
      one: '1 chapitre',
      zero: '0 chapitre',
    );
    return '$_temp0';
  }

  @override
  String get readBook => 'Lire le livre';

  @override
  String bookQuiz(int count) {
    return 'Quiz ($count)';
  }

  @override
  String get bookInfo => 'Fiche du livre';

  @override
  String get chooseBook => 'Choisir un livre';

  @override
  String chooseChapter(String book) {
    return '$book : choisir un chapitre';
  }

  @override
  String chapterTitle(String book, int chapter) {
    return '$book $chapter';
  }

  @override
  String get previousChapter => 'Précédent';

  @override
  String get nextChapter => 'Suivant';

  @override
  String get textSize => 'Taille du texte';

  @override
  String get searchTitle => 'Rechercher';

  @override
  String get searchHint => 'Mots, \"expression exacte\" ou référence';

  @override
  String get searchClear => 'Effacer';

  @override
  String searchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versets',
      one: '1 verset',
      zero: 'Aucun verset',
    );
    return '$_temp0';
  }

  @override
  String searchResultsFiltered(int shown, int total) {
    return '$shown sur $total versets';
  }

  @override
  String get searchNoResult =>
      'Aucun verset ne contient tous ces mots. Essayez moins de mots, ou désactivez « Mots entiers ».';

  @override
  String get searchAll => 'Toute la Bible';

  @override
  String get searchOld => 'Ancien Testament';

  @override
  String get searchNew => 'Nouveau Testament';

  @override
  String get searchBook => 'Livre…';

  @override
  String get searchAllBooks => 'Tous les livres';

  @override
  String get searchWholeWords => 'Mots entiers';

  @override
  String searchIn(String name) {
    return 'Chercher dans : $name';
  }

  @override
  String searchGoTo(String ref) {
    return 'Aller à $ref';
  }

  @override
  String get searchRecent => 'Recherches récentes';

  @override
  String get searchClearRecent => 'Tout effacer';

  @override
  String get searchTipsTitle => 'Comment chercher';

  @override
  String get searchTipWords =>
      'Plusieurs mots : les versets qui les contiennent tous, dans n’importe quel ordre.';

  @override
  String get searchTipPhrase =>
      'Entre guillemets : l’expression exacte, ponctuation comprise ou non.';

  @override
  String get searchTipExclude => 'Un tiret devant un mot l’exclut.';

  @override
  String get searchTipAccents =>
      'Accents et majuscules ne comptent pas ; un mot trouve aussi les mots qui commencent par lui (pardon → pardonne).';

  @override
  String get searchTipRef => 'Une référence ouvre directement le passage.';

  @override
  String get searchExampleWords => 'berger brebis';

  @override
  String get searchExamplePhrase => '\"que la lumière soit\"';

  @override
  String get searchExampleExclude => 'berger -loup';

  @override
  String get searchExampleRef => 'Jean 3:16';

  @override
  String get searchPreparing => 'Préparation de la recherche…';

  @override
  String searchMoreResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de plus',
      one: '1 de plus',
      zero: '0 de plus',
    );
    return 'Affiner la recherche pour voir les autres versets ($_temp0).';
  }

  @override
  String get progressTitle => 'Vos progrès';

  @override
  String get statLessons => 'Leçons terminées';

  @override
  String get statAnswered => 'Réponses données';

  @override
  String get statAccuracy => 'Bonnes réponses';

  @override
  String get statMastered => 'Questions acquises';

  @override
  String get statStreak => 'Série en cours';

  @override
  String get statBestStreak => 'Meilleure série';

  @override
  String daysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
      zero: '0 jour',
    );
    return '$_temp0';
  }

  @override
  String get favoritesTitle => 'Versets mis de côté';

  @override
  String get favoritesEmpty =>
      'Touchez un verset dans la Bible pour le mettre de côté.';

  @override
  String get pathsProgressTitle => 'Par parcours';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Celle du téléphone';

  @override
  String get themeTitle => 'Thème';

  @override
  String get themeSystem => 'Celui du téléphone';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get parallelSetting => 'Lecture bilingue';

  @override
  String get parallelSettingHint =>
      'Affiche sous chaque verset l’autre traduction (KJV ou Segond).';

  @override
  String get textSizePreview =>
      'Au commencement, Dieu créa les cieux et la terre.';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutTexts =>
      'Textes bibliques : Louis Segond 1910 et King James Version 1769, tous deux dans le domaine public.';

  @override
  String get aboutContent =>
      'Les questions s’en tiennent à ce que dit le texte, sans prendre parti entre les Églises. Chaque réponse renvoie au verset qui la justifie.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get resetProgress => 'Effacer ma progression';

  @override
  String get resetProgressBody =>
      'Leçons terminées, révisions, série et chapitres lus seront effacés. Vos versets mis de côté et vos réglages sont conservés. Cette action est définitive.';

  @override
  String get resetDone => 'Progression effacée';

  @override
  String get readingQuizTitle => 'Quiz sur mes lectures';

  @override
  String get readingQuizSubtitle =>
      'Un quiz sur le ou les livres que vous avez lus';

  @override
  String get readingQuizIntro =>
      'Choisissez un ou plusieurs livres. Les questions relues viennent d’abord ; d’autres, tirées du texte même, complètent le quiz.';

  @override
  String get readingQuizBooks => 'Livres du quiz';

  @override
  String get selectMyReading => 'Mes lectures';

  @override
  String get selectNone => 'Aucun';

  @override
  String get genreLaw => 'Pentateuque';

  @override
  String get genreHistory => 'Livres historiques';

  @override
  String get genrePoetry => 'Poétiques';

  @override
  String get genreProphets => 'Prophètes';

  @override
  String get genreGospels => 'Évangiles';

  @override
  String get genreActs => 'Actes';

  @override
  String get genreEpistles => 'Épîtres';

  @override
  String get genreApocalyptic => 'Apocalypse';

  @override
  String chaptersReadOf(int done, int total) {
    return '$done / $total chapitres lus';
  }

  @override
  String get scopeRead => 'Chapitres lus';

  @override
  String get scopeWhole => 'Livres entiers';

  @override
  String get scopeReadHint =>
      'Les questions portent seulement sur les chapitres que vous avez lus.';

  @override
  String get scopeWholeHint =>
      'Les questions portent sur l’ensemble des livres choisis.';

  @override
  String get questionCountLabel => 'Nombre de questions';

  @override
  String startReadingQuiz(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Commencer · $count livres',
      one: 'Commencer · 1 livre',
      zero: 'Commencer · 0 livre',
    );
    return '$_temp0';
  }

  @override
  String get readingQuizPickOne => 'Choisissez au moins un livre.';

  @override
  String get readingQuizTooFew =>
      'Pas assez de matière pour un quiz : ajoutez des chapitres, ou choisissez « Livres entiers ».';

  @override
  String readingQuizNamed(String name) {
    return 'Quiz : $name';
  }

  @override
  String readingQuizBooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres',
      one: '1 livre',
      zero: '0 livre',
    );
    return '$_temp0';
  }

  @override
  String get fromTheText => 'Tiré du texte';

  @override
  String get markChapterRead => 'Marquer comme lu';

  @override
  String get chapterRead => 'Chapitre lu';

  @override
  String get markBookRead => 'Marquer tout le livre comme lu';

  @override
  String get unmarkBookRead => 'Retirer « lu » pour ce livre';

  @override
  String get quizOnThisBook => 'Quiz sur ce livre';

  @override
  String chaptersReadTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapitres lus',
      one: '1 chapitre lu',
      zero: 'Aucun chapitre lu',
    );
    return '$_temp0';
  }

  @override
  String get testThisChapter => 'Tester ce chapitre';

  @override
  String get chapterQuizTooFew =>
      'Ce chapitre est trop court pour un quiz. Essayez un quiz sur le livre entier.';

  @override
  String get bibleReadingTitle => 'Ma lecture de la Bible';

  @override
  String bibleReadingTotal(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      done,
      locale: localeName,
      other: '$done chapitres lus sur $total',
      one: '1 chapitre lu sur $total',
      zero: 'Aucun chapitre lu sur $total',
    );
    return '$_temp0';
  }

  @override
  String get bibleReadingHint => 'Touchez un livre pour voir ses chapitres.';

  @override
  String bookReadSemantics(String name, int done, int total) {
    return '$name : $done chapitres lus sur $total';
  }

  @override
  String booksStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres commencés',
      one: '1 livre commencé',
      zero: 'Aucun livre commencé',
    );
    return '$_temp0';
  }

  @override
  String booksFinished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terminés',
      one: '1 terminé',
      zero: 'aucun terminé',
    );
    return '$_temp0';
  }

  @override
  String get onlineTitle => 'Jouer avec d’autres';

  @override
  String get onlineCardSubtitle =>
      'Matchs et tournois en ligne sur les passages de votre choix';

  @override
  String get onlineIntro =>
      'Affrontez d’autres lecteurs, seul ou en équipe, sur un ou plusieurs passages de la Bible. Le premier qui prend la main répond ; une bonne réponse rapporte 10 points, une erreur en coûte 5.';

  @override
  String get onlineOptional =>
      'Le jeu en ligne est facultatif : tout le reste de l’application fonctionne sans compte et sans Internet.';

  @override
  String get onlineBecomePlayer => 'Devenir joueur';

  @override
  String get onlineAccountHint =>
      'Il faut un numéro de téléphone (code reçu par WhatsApp) et un pseudo.';

  @override
  String get onlineCreateMatch => 'Créer un match';

  @override
  String get onlineJoin => 'Rejoindre';

  @override
  String get onlineJoinTitle => 'Rejoindre avec un code';

  @override
  String get onlineJoinHint => 'Code à 6 caractères';

  @override
  String get onlineCreateTournament => 'Créer un tournoi';

  @override
  String get onlineOpenMatches => 'Matchs ouverts';

  @override
  String get onlineOpenTournaments => 'Tournois ouverts';

  @override
  String get onlineNoOpenMatch =>
      'Aucun match ouvert pour l’instant. Créez-en un et partagez son code.';

  @override
  String get onlineMyTournaments => 'Mes tournois';

  @override
  String get onlineInvitations => 'Invitations';

  @override
  String get onlineHistory => 'Mes matchs';

  @override
  String get onlineNoHistory => 'Vos matchs terminés s’afficheront ici.';

  @override
  String get onlineProfile => 'Mon profil de joueur';

  @override
  String get onlineProjection => 'Écran de projection';

  @override
  String get onlineProjectionHint =>
      'Affichez un match ou un tournoi en grand (vidéoprojecteur, télévision), sans compte.';

  @override
  String get onlineCurrentMatch => 'Vous avez un match en cours';

  @override
  String onlineCurrentTournament(String name) {
    return 'Vous participez au tournoi « $name »';
  }

  @override
  String get onlineResume => 'Reprendre';

  @override
  String onlineStats(int played, int won) {
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: '$played matchs',
      one: '1 match',
      zero: 'Aucun match',
    );
    String _temp1 = intl.Intl.pluralLogic(
      won,
      locale: localeName,
      other: '$won gagnés',
      one: '1 gagné',
      zero: 'aucun gagné',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get onlineOffline =>
      'Pas de connexion au serveur. Vérifiez Internet puis réessayez.';

  @override
  String onlinePlayers(int players, int max) {
    return '$players/$max joueurs';
  }

  @override
  String onlineBy(String name) {
    return 'par $name';
  }

  @override
  String get onlineModeSolo => 'Individuel';

  @override
  String get onlineModeTeam => 'Par équipes';

  @override
  String get onlineRealtimeOff =>
      'Connexion lente : l’affichage peut avoir un peu de retard.';

  @override
  String get signInTitle => 'Devenir joueur';

  @override
  String get signInPhone => 'Votre numéro de téléphone';

  @override
  String get signInCountry => 'Pays';

  @override
  String get signInSendCode => 'Recevoir le code par WhatsApp';

  @override
  String signInCodeSent(String phone) {
    return 'Code envoyé au $phone';
  }

  @override
  String get signInCode => 'Code reçu';

  @override
  String get signInVerify => 'Valider';

  @override
  String get signInResend => 'Renvoyer le code';

  @override
  String get signInChangeNumber => 'Changer de numéro';

  @override
  String get signInPrivacy =>
      'Votre numéro sert seulement à protéger votre compte. Les autres joueurs ne voient que votre pseudo.';

  @override
  String get pseudoTitle => 'Choisissez votre pseudo';

  @override
  String get pseudoLabel => 'Pseudo';

  @override
  String get pseudoHint => '3 à 20 caractères, visible par les autres joueurs';

  @override
  String get pseudoSave => 'C’est parti';

  @override
  String get profileRename => 'Changer de pseudo';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get profileDelete => 'Supprimer mon compte joueur';

  @override
  String get profileDeleteConfirm =>
      'Votre pseudo et votre historique seront effacés, et vous quitterez la partie en cours. Vos lectures et vos progrès dans l’application ne sont pas touchés.';

  @override
  String get profileDeleted => 'Compte joueur supprimé';

  @override
  String profileTournamentsWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tournois gagnés',
      one: '1 tournoi gagné',
      zero: 'Aucun tournoi gagné',
    );
    return '$_temp0';
  }

  @override
  String get report => 'Signaler ce pseudo';

  @override
  String get reportReason => 'Pourquoi ? (facultatif)';

  @override
  String get reportSent => 'Signalement envoyé. Merci.';

  @override
  String get createMatchTitle => 'Nouveau match';

  @override
  String get createPassages => 'Passages';

  @override
  String get createAddPassage => 'Ajouter un passage';

  @override
  String get createNoPassage =>
      'Choisissez au moins un passage sur lequel porteront les questions.';

  @override
  String createAvailable(int available) {
    return '$available questions possibles sur ces passages';
  }

  @override
  String get createNotEnough =>
      'Pas assez de questions : ajoutez ou élargissez un passage, ou réduisez le nombre de questions.';

  @override
  String get createBible => 'Bible du match';

  @override
  String createQuestions(int n) {
    return 'Questions : $n';
  }

  @override
  String createQuestionTime(int seconds) {
    return 'Temps par question : $seconds s';
  }

  @override
  String createHandTime(int seconds) {
    return 'Temps pour répondre après avoir pris la main : $seconds s';
  }

  @override
  String createMaxPlayers(int n) {
    return 'Joueurs au plus : $n';
  }

  @override
  String get createPublic => 'Visible dans les matchs ouverts';

  @override
  String get createPublicHint =>
      'Sinon, seuls ceux qui ont le code peuvent entrer.';

  @override
  String get createSubmit => 'Créer le match';

  @override
  String get passagePickerTitle => 'Choisir un passage';

  @override
  String get passageBook => 'Livre';

  @override
  String get passageFromChapter => 'Du chapitre';

  @override
  String get passageToChapter => 'au chapitre';

  @override
  String get passageVerses => 'Seulement certains versets';

  @override
  String get passageFromVerse => 'Du verset';

  @override
  String get passageToVerse => 'au verset';

  @override
  String get passageAdd => 'Ajouter';

  @override
  String get lobbyTitle => 'Salle d’attente';

  @override
  String get lobbyCode => 'Code du match';

  @override
  String get lobbyShareHint =>
      'Les autres joueurs saisissent ce code dans Jouer → Rejoindre, ou scannent le QR code avec l’appareil photo.';

  @override
  String get lobbyShareWhatsApp => 'Inviter par WhatsApp';

  @override
  String lobbyShareText(String passages, String code, String link) {
    return 'Rejoins-moi pour un match de Quiz Biblique ($passages) ! Code : $code\n$link';
  }

  @override
  String get lobbyPlayers => 'Joueurs';

  @override
  String lobbyWaitCreator(String name) {
    return 'En attente du lancement par $name…';
  }

  @override
  String get lobbyStart => 'Lancer le match';

  @override
  String get lobbyNeedPlayers => 'Il faut au moins 2 joueurs.';

  @override
  String get lobbyLeave => 'Quitter';

  @override
  String get lobbyLeaveConfirm => 'Quitter ce match ?';

  @override
  String get lobbyLeaveRunning =>
      'Si vous quittez un match en cours, vous l’abandonnez.';

  @override
  String get lobbyKick => 'Retirer du match';

  @override
  String get lobbyCreator => 'créateur';

  @override
  String lobbySettings(int n, int seconds, String hand) {
    return '$n questions · $seconds s par question · main : $hand s';
  }

  @override
  String get lobbyCancelled => 'Ce match a été annulé.';

  @override
  String get lobbyNoTeam => 'Sans équipe';

  @override
  String get lobbyNoTeamHint =>
      'Les joueurs sans équipe ne jouent pas : demandez à entrer dans une équipe, ou créez-la.';

  @override
  String get teamCreate => 'Créer une équipe';

  @override
  String get teamName => 'Nom de l’équipe';

  @override
  String get teamCaptain => 'capitaine';

  @override
  String get teamInvite => 'Inviter un joueur';

  @override
  String get teamInviteSearch => 'Pseudo du joueur';

  @override
  String get teamInviteBusy => 'déjà en partie';

  @override
  String get teamInvited => 'invité';

  @override
  String get teamRequested => 'demande à entrer';

  @override
  String get teamAccept => 'Accepter';

  @override
  String get teamDecline => 'Refuser';

  @override
  String get teamRemove => 'Retirer';

  @override
  String get teamAskJoin => 'Demander à entrer';

  @override
  String get teamLeave => 'Quitter l’équipe';

  @override
  String get teamRename => 'Renommer';

  @override
  String teamMembers(int n) {
    return '$n joueurs';
  }

  @override
  String teamInvitation(String captain, String team) {
    return '$captain vous invite dans l’équipe « $team »';
  }

  @override
  String teamSizeHint(int min, int max) {
    return 'De $min à $max joueurs par équipe.';
  }

  @override
  String get playCountdown => 'Prêts ?';

  @override
  String playQuestion(int index, int total) {
    return 'Question $index sur $total';
  }

  @override
  String get playTiebreak =>
      'Question décisive : la première bonne réponse l’emporte';

  @override
  String get playBuzz => 'Je réponds !';

  @override
  String get playYourHand => 'À vous ! Choisissez la réponse';

  @override
  String playHandOf(String name) {
    return '$name a la main';
  }

  @override
  String get playLocked => 'Vous ne pouvez plus répondre à cette question';

  @override
  String get playLockedTeam =>
      'Votre équipe ne peut plus répondre à cette question';

  @override
  String get playPaused => 'Chrono en pause';

  @override
  String get playCorrect => 'Bonne réponse ! +10';

  @override
  String get playWrong => 'Mauvaise réponse : −5';

  @override
  String playWonBy(String name) {
    return '$name a trouvé';
  }

  @override
  String get playNobody => 'Personne n’a trouvé';

  @override
  String playAnswerWas(String answer) {
    return 'Réponse : $answer';
  }

  @override
  String get playTimeout => 'Temps écoulé';

  @override
  String get playFromText => 'Tiré du texte';

  @override
  String get playSpectator => 'Vous regardez ce match';

  @override
  String get playScores => 'Scores';

  @override
  String playHandLost(String name) {
    return '$name a laissé filer la main : −5';
  }

  @override
  String playAnsweredWrong(String name) {
    return '$name s’est trompé : −5';
  }

  @override
  String playPoints(int points) {
    return '$points pts';
  }

  @override
  String get playLeft => 'a quitté';

  @override
  String get playOffline => 'hors ligne';

  @override
  String get resultTitle => 'Résultats';

  @override
  String resultWinner(String name) {
    return '$name gagne !';
  }

  @override
  String get resultYouWin => 'Vous avez gagné !';

  @override
  String get resultDraw => 'Égalité';

  @override
  String resultRank(int rank) {
    return '$rankᵉ';
  }

  @override
  String get resultFirst => '1ᵉʳ';

  @override
  String get resultAbandon => 'Match arrêté : un camp a quitté la partie.';

  @override
  String get resultIdle => 'Match clos faute d’activité.';

  @override
  String get resultTiebreak => 'Départagé par une question décisive.';

  @override
  String get resultTiebreakRule =>
      'Égalité parfaite : départagé au règlement (moins d’erreurs, puis rapidité).';

  @override
  String get resultReview => 'Revoir les questions';

  @override
  String get resultRematch => 'Revanche';

  @override
  String get resultRematchSent =>
      'Nouveau match créé : les autres joueurs reçoivent le code.';

  @override
  String get resultBack => 'Retour';

  @override
  String get resultReadPassage => 'Lire le passage';

  @override
  String get projectionCodePrompt => 'Code du match ou du tournoi';

  @override
  String get projectionCast => 'Diffuser sur un écran';

  @override
  String get projectionHere => 'Sur cet appareil';

  @override
  String get projectionHereHint =>
      'Plein écran, à relier au vidéoprojecteur ou à la télévision (câble, partage d’écran).';

  @override
  String get projectionOther => 'Sur une télévision ou un ordinateur';

  @override
  String get projectionOtherHint =>
      'Ouvrez ce lien dans son navigateur, sans compte :';

  @override
  String projectionOtherApp(String code) {
    return 'Ou, dans l’application : Jouer en ligne → Écran de projection, code $code.';
  }

  @override
  String projectionTourOpen(String code) {
    return 'Inscriptions ouvertes — code $code';
  }

  @override
  String get projectionTourScan => 'Scannez pour vous inscrire';

  @override
  String get projectionLiveDuels =>
      'Duels en cours — touchez-en un pour l’afficher en grand';

  @override
  String get projectionNoLive => 'Aucun duel en cours pour l’instant.';

  @override
  String projectionFollowing(String tournament, String stage) {
    return '$tournament · $stage';
  }

  @override
  String get projectionShow => 'Afficher';

  @override
  String projectionWaiting(String code) {
    return 'En attente des joueurs — code $code';
  }

  @override
  String eventInvitation(String captain, String team) {
    return '$captain vous invite dans l’équipe « $team »';
  }

  @override
  String eventRequest(String pseudo) {
    return '$pseudo demande à entrer dans votre équipe';
  }

  @override
  String get eventDuelReady => 'Tournoi : votre duel vous attend !';

  @override
  String eventRematch(String code) {
    return 'Revanche proposée : code $code';
  }

  @override
  String get eventSee => 'Voir';

  @override
  String get errNetwork => 'Pas de connexion Internet.';

  @override
  String get errServer =>
      'Le serveur ne répond pas correctement. Réessayez plus tard.';

  @override
  String get errHandTaken => 'Trop tard : un autre joueur a pris la main.';

  @override
  String get errLocked => 'Vous ne pouvez plus répondre à cette question.';

  @override
  String get errTooLate => 'Le temps est écoulé.';

  @override
  String get errNoHand => 'Vous n’avez plus la main.';

  @override
  String get errFull => 'C’est complet.';

  @override
  String get errServerBusy =>
      'Trop de parties en cours en ce moment. Réessayez dans quelques minutes.';

  @override
  String get errUnknownCode => 'Aucun match ni tournoi avec ce code.';

  @override
  String get errBadCode => 'Code incorrect ou expiré.';

  @override
  String get errBanned => 'Votre compte joueur est suspendu.';

  @override
  String get errRateLimited =>
      'Trop de tentatives. Réessayez dans quelques minutes.';

  @override
  String get scanQr => 'Scanner le QR code';

  @override
  String get scanHint =>
      'Visez le QR code affiché dans la salle d’attente du match ou du tournoi.';

  @override
  String get scanNotAGame =>
      'Ce QR code n’est pas celui d’une partie de Quiz Biblique.';

  @override
  String get scanTorch => 'Lampe';

  @override
  String get scanFromImage => 'Choisir une image';

  @override
  String get scanNoQrInImage => 'Aucun QR code de partie dans cette image.';

  @override
  String get scanTypeCode => 'Saisir le code';

  @override
  String get scanCameraDenied =>
      'L’accès à la caméra a été refusé. Autorisez-le dans les réglages du téléphone, ou saisissez le code.';

  @override
  String get scanCameraUnavailable =>
      'La caméra n’est pas disponible. Saisissez le code de la partie.';

  @override
  String get tourCreateTitle => 'Nouveau tournoi';

  @override
  String get tourName => 'Nom du tournoi';

  @override
  String get tourNameHint => 'Par ex. : Tournoi des jeunes — Évangile de Jean';

  @override
  String get tourNameTooShort => '3 caractères au moins';

  @override
  String get tourFormat => 'Formule';

  @override
  String get tourModeSolo => 'Entre joueurs';

  @override
  String get tourModeTeam => 'Entre équipes';

  @override
  String get tourModeSoloHint =>
      'Chaque joueur s’inscrit seul ; les duels opposent deux joueurs.';

  @override
  String get tourModeTeamHint =>
      'Les joueurs forment des équipes ; les duels opposent deux équipes.';

  @override
  String get tourBible => 'Bible du tournoi';

  @override
  String get tourBibleFr => 'Louis Segond 1910';

  @override
  String get tourBibleEn => 'King James';

  @override
  String tourEntriesRange(int min, int max) {
    return 'Participants : de $min à $max';
  }

  @override
  String get tourEntriesTeamHint => 'Une équipe compte pour un participant.';

  @override
  String tourQuestionsPerDuel(int n) {
    return 'Questions par duel : $n';
  }

  @override
  String get tourForfeitDelay => 'Délai pour confirmer « Prêt »';

  @override
  String get tourForfeitHint =>
      'Quand un duel s’ouvre, chaque camp a ce délai pour se déclarer prêt. Sinon, il perd par forfait.';

  @override
  String tourMinutesValue(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
      zero: '0 minute',
    );
    return '$_temp0';
  }

  @override
  String tourHoursValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n heures',
      one: '1 heure',
      zero: '0 heure',
    );
    return '$_temp0';
  }

  @override
  String get tourPublic => 'Visible dans les tournois ouverts';

  @override
  String get tourPublicHint =>
      'Sinon, seuls ceux qui ont le code peuvent s’inscrire.';

  @override
  String get tourPlay => 'Je joue aussi';

  @override
  String get tourPlaySoloHint =>
      'Vous êtes inscrit d’office. Sinon, vous organisez seulement.';

  @override
  String get tourPlayTeamHint =>
      'Vous créez votre équipe et en êtes le capitaine.';

  @override
  String get tourNeedPassage => 'Choisissez au moins un passage.';

  @override
  String get tourCreateSubmit => 'Créer le tournoi';

  @override
  String get tourTitle => 'Tournoi';

  @override
  String get tourCode => 'Code du tournoi';

  @override
  String tourShareText(String name, String passages, String code) {
    return 'Inscris-toi au tournoi « $name » de Quiz Biblique ($passages) ! Code : $code';
  }

  @override
  String get tourStateRegistration => 'Inscriptions ouvertes';

  @override
  String get tourStateRunning => 'En cours';

  @override
  String get tourStateFinished => 'Terminé';

  @override
  String get tourStateCancelled => 'Annulé';

  @override
  String get tourOrganizer => 'Organisateur';

  @override
  String tourOrganizedBy(String name) {
    return 'Organisé par $name';
  }

  @override
  String get tourRules => 'Règlement';

  @override
  String tourRulesDuel(int n, int seconds) {
    return '$n questions par duel · $seconds s par question';
  }

  @override
  String tourRulesHand(int seconds) {
    return 'Après avoir pris la main : $seconds s pour répondre';
  }

  @override
  String tourRulesForfeit(int minutes) {
    return '« Prêt » à confirmer dans les $minutes min, sinon forfait';
  }

  @override
  String tourRulesEntries(int min, int max) {
    return 'De $min à $max participants';
  }

  @override
  String get tourRulesElimination =>
      'Élimination directe : le perdant de chaque duel est éliminé.';

  @override
  String tourPlayers(int count, int max) {
    return 'Joueurs inscrits : $count/$max';
  }

  @override
  String tourTeams(int count, int max) {
    return 'Équipes inscrites : $count/$max';
  }

  @override
  String get tourNoEntries =>
      'Personne n’est encore inscrit. Partagez le code !';

  @override
  String get tourYou => 'vous';

  @override
  String get tourRegister => 'M’inscrire';

  @override
  String get tourUnregister => 'Me désinscrire';

  @override
  String get tourUnregisterConfirm => 'Vous désinscrire de ce tournoi ?';

  @override
  String get tourRegistered =>
      'Vous êtes inscrit. Le tournoi commencera quand l’organisateur le lancera.';

  @override
  String get tourFull => 'Le tournoi est complet.';

  @override
  String get tourTeamHint =>
      'Créez votre équipe et invitez vos coéquipiers, ou demandez à entrer dans une équipe ci-dessous.';

  @override
  String tourTeamIncomplete(int min) {
    return 'Équipe incomplète : il faut $min joueurs au moins, sinon elle ne sera pas retenue au lancement.';
  }

  @override
  String get tourOrganize => 'Organisation';

  @override
  String get tourStart => 'Lancer le tournoi';

  @override
  String get tourStartConfirm => 'Lancer le tournoi ?';

  @override
  String get tourStartBody =>
      'Les inscriptions seront closes et le tableau tiré au sort.';

  @override
  String tourStartBodyTeam(int min) {
    return 'Les inscriptions seront closes et le tableau tiré au sort. Les équipes de moins de $min joueurs ne seront pas retenues.';
  }

  @override
  String tourNeedEntries(int min, int count) {
    return 'Il faut au moins $min participants pour lancer (inscrits : $count).';
  }

  @override
  String get tourCancel => 'Annuler le tournoi';

  @override
  String get tourCancelConfirm => 'Annuler ce tournoi ?';

  @override
  String get tourCancelBody =>
      'Tous les participants seront prévenus. C’est définitif.';

  @override
  String get tourRoundPassages => 'Passages par tour';

  @override
  String get tourRoundPassagesHint =>
      'Vous pouvez choisir d’autres passages pour un tour, tant que ses duels n’ont pas commencé. Sans choix, les passages du tournoi s’appliquent.';

  @override
  String get tourRoundDefault => 'Passages du tournoi';

  @override
  String get tourRoundStarted => 'Ce tour a commencé';

  @override
  String get tourRoundReset => 'Revenir aux passages du tournoi';

  @override
  String get tourSave => 'Enregistrer';

  @override
  String get tourSaved => 'Passages enregistrés';

  @override
  String tourRound(int round) {
    return 'Tour $round';
  }

  @override
  String get tourFinal => 'Finale';

  @override
  String get tourSemiFinals => 'Demi-finales';

  @override
  String get tourQuarterFinals => 'Quarts de finale';

  @override
  String get tourBracket => 'Tableau';

  @override
  String get tourYourDuel => 'Votre duel';

  @override
  String tourAgainst(String name) {
    return 'Contre $name';
  }

  @override
  String tourForfeitIn(String time) {
    return 'Forfait dans $time';
  }

  @override
  String get tourDeadlinePassed => 'Délai écoulé, résultat en cours…';

  @override
  String get tourReady => 'Prêt !';

  @override
  String get tourReadyHint =>
      'Le duel commence dès que les deux camps sont prêts.';

  @override
  String get tourYouReady => 'Vous êtes prêt';

  @override
  String get tourTeamReady => 'Votre équipe est prête';

  @override
  String tourOpponentReady(String name) {
    return '$name est prêt';
  }

  @override
  String tourOpponentWaiting(String name) {
    return '$name n’a pas encore confirmé';
  }

  @override
  String get tourJoinDuel => 'Rejoindre le duel';

  @override
  String get tourDuelPlaying => 'Votre duel est en cours';

  @override
  String get tourWaitingNext =>
      'Qualifié ! En attente de votre prochain adversaire.';

  @override
  String tourEliminatedAt(int round) {
    return 'Vous êtes éliminé au tour $round. Merci d’avoir joué !';
  }

  @override
  String get tourEliminated => 'Vous êtes éliminé. Merci d’avoir joué !';

  @override
  String get tourSpectator => 'Vous suivez ce tournoi.';

  @override
  String get tourAbandon => 'Abandonner le tournoi';

  @override
  String get tourAbandonBody => 'Votre duel en cours ou à venir sera perdu.';

  @override
  String get tourAbandonTeamBody =>
      'Vous quittez votre équipe ; elle continue sans vous.';

  @override
  String get tourBye => 'Exempt';

  @override
  String get tourByeWin => 'Qualifié d’office';

  @override
  String get tourTbd => 'À déterminer';

  @override
  String get tourForfeitResult => 'Forfait';

  @override
  String get tourDoubleForfeit => 'Double forfait';

  @override
  String get tourDuelPending => 'À venir';

  @override
  String get tourDuelReadyWait => 'En attente des joueurs';

  @override
  String get tourDuelLive => 'En cours';

  @override
  String tourDuelSemantics(String a, String b) {
    return '$a contre $b';
  }

  @override
  String tourDuelWinnerSemantics(String name) {
    return 'vainqueur : $name';
  }

  @override
  String get tourEliminatedTag => 'éliminé';

  @override
  String tourWinner(String name) {
    return '$name remporte le tournoi !';
  }

  @override
  String get tourYouWon => 'Vous avez gagné le tournoi !';

  @override
  String get tourNoWinner => 'Tournoi terminé sans vainqueur.';

  @override
  String get tourCancelled => 'Ce tournoi a été annulé.';
}
