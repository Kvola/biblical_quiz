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
}
