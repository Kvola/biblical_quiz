import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quiz Biblique'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In fr, this message translates to:
  /// **'Lire et comprendre la Bible'**
  String get tagline;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navPaths.
  ///
  /// In fr, this message translates to:
  /// **'Parcours'**
  String get navPaths;

  /// No description provided for @navBible.
  ///
  /// In fr, this message translates to:
  /// **'Bible'**
  String get navBible;

  /// No description provided for @navProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progrès'**
  String get navProgress;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @loadError.
  ///
  /// In fr, this message translates to:
  /// **'Le contenu n’a pas pu être chargé.'**
  String get loadError;

  /// No description provided for @copied.
  ///
  /// In fr, this message translates to:
  /// **'Copié'**
  String get copied;

  /// No description provided for @copy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// No description provided for @addFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Mettre de côté'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des versets mis de côté'**
  String get removeFavorite;

  /// No description provided for @favoriteAdded.
  ///
  /// In fr, this message translates to:
  /// **'Verset mis de côté'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Verset retiré'**
  String get favoriteRemoved;

  /// No description provided for @undo.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get undo;

  /// No description provided for @questionsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String questionsCount(int count);

  /// No description provided for @versesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 verset} other{{count} versets}}'**
  String versesCount(int count);

  /// No description provided for @welcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get welcomeTitle;

  /// No description provided for @welcomeIntro.
  ///
  /// In fr, this message translates to:
  /// **'Ce quiz est un compagnon de lecture : il vous aide à découvrir ce dont parle la Bible.'**
  String get welcomeIntro;

  /// No description provided for @welcomeStep1.
  ///
  /// In fr, this message translates to:
  /// **'Lisez un court passage, directement dans l’application.'**
  String get welcomeStep1;

  /// No description provided for @welcomeStep2.
  ///
  /// In fr, this message translates to:
  /// **'Répondez à quelques questions pour vérifier ce que vous avez compris.'**
  String get welcomeStep2;

  /// No description provided for @welcomeStep3.
  ///
  /// In fr, this message translates to:
  /// **'Chaque réponse est expliquée et renvoie au verset.'**
  String get welcomeStep3;

  /// No description provided for @welcomeOffline.
  ///
  /// In fr, this message translates to:
  /// **'Tout fonctionne sans Internet. Textes : Louis Segond 1910 (français) et King James 1769 (anglais).'**
  String get welcomeOffline;

  /// No description provided for @chooseLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get chooseLanguage;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get start;

  /// No description provided for @streakDays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 jour de suite} other{{count} jours de suite}}'**
  String streakDays(int count);

  /// No description provided for @streakStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencez votre série aujourd’hui'**
  String get streakStart;

  /// No description provided for @streakKeep.
  ///
  /// In fr, this message translates to:
  /// **'Lisez aujourd’hui pour garder votre série'**
  String get streakKeep;

  /// No description provided for @streakDone.
  ///
  /// In fr, this message translates to:
  /// **'Bravo, vous avez lu aujourd’hui'**
  String get streakDone;

  /// No description provided for @continueTitle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueTitle;

  /// No description provided for @startTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pour commencer'**
  String get startTitle;

  /// No description provided for @allDone.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez terminé tous les parcours. Refaites vos leçons préférées ou lisez librement la Bible.'**
  String get allDone;

  /// No description provided for @lessonStart.
  ///
  /// In fr, this message translates to:
  /// **'Lire et répondre'**
  String get lessonStart;

  /// No description provided for @reviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'À revoir'**
  String get reviewTitle;

  /// No description provided for @reviewDue.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 question à revoir aujourd’hui} other{{count} questions à revoir aujourd’hui}}'**
  String reviewDue(int count);

  /// No description provided for @reviewStart.
  ///
  /// In fr, this message translates to:
  /// **'Réviser'**
  String get reviewStart;

  /// No description provided for @verseOfDay.
  ///
  /// In fr, this message translates to:
  /// **'Verset du jour'**
  String get verseOfDay;

  /// No description provided for @challengeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dans quel livre ?'**
  String get challengeTitle;

  /// No description provided for @challengeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Retrouvez le livre d’où vient chaque verset.'**
  String get challengeSubtitle;

  /// No description provided for @challengeQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Dans quel livre se trouve ce verset ?'**
  String get challengeQuestion;

  /// No description provided for @play.
  ///
  /// In fr, this message translates to:
  /// **'Jouer'**
  String get play;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settings;

  /// No description provided for @pathsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Parcours'**
  String get pathsTitle;

  /// No description provided for @lessonsProgress.
  ///
  /// In fr, this message translates to:
  /// **'{done} / {total} leçons'**
  String lessonsProgress(int done, int total);

  /// No description provided for @booksPathTitle.
  ///
  /// In fr, this message translates to:
  /// **'Les 66 livres'**
  String get booksPathTitle;

  /// No description provided for @booksPathSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Une fiche par livre : de quoi il parle, qui l’a écrit, et quelques questions.'**
  String get booksPathSubtitle;

  /// No description provided for @bestScore.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur score : {score} / {total}'**
  String bestScore(int score, int total);

  /// No description provided for @oldTestament.
  ///
  /// In fr, this message translates to:
  /// **'Ancien Testament'**
  String get oldTestament;

  /// No description provided for @newTestament.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau Testament'**
  String get newTestament;

  /// No description provided for @readTitle.
  ///
  /// In fr, this message translates to:
  /// **'À lire'**
  String get readTitle;

  /// No description provided for @introTitle.
  ///
  /// In fr, this message translates to:
  /// **'Avant de lire'**
  String get introTitle;

  /// No description provided for @goToQuestions.
  ///
  /// In fr, this message translates to:
  /// **'J’ai lu : aux questions ({count})'**
  String goToQuestions(int count);

  /// No description provided for @showParallel.
  ///
  /// In fr, this message translates to:
  /// **'Afficher aussi l’autre traduction'**
  String get showParallel;

  /// No description provided for @questionOf.
  ///
  /// In fr, this message translates to:
  /// **'Question {index} sur {total}'**
  String questionOf(int index, int total);

  /// No description provided for @trueLabel.
  ///
  /// In fr, this message translates to:
  /// **'Vrai'**
  String get trueLabel;

  /// No description provided for @falseLabel.
  ///
  /// In fr, this message translates to:
  /// **'Faux'**
  String get falseLabel;

  /// No description provided for @correct.
  ///
  /// In fr, this message translates to:
  /// **'Bonne réponse !'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In fr, this message translates to:
  /// **'Pas tout à fait'**
  String get incorrect;

  /// No description provided for @correctAnswerWas.
  ///
  /// In fr, this message translates to:
  /// **'La bonne réponse : {answer}'**
  String correctAnswerWas(String answer);

  /// No description provided for @readVerse.
  ///
  /// In fr, this message translates to:
  /// **'Lire {ref}'**
  String readVerse(String ref);

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @seeResult.
  ///
  /// In fr, this message translates to:
  /// **'Voir le résultat'**
  String get seeResult;

  /// No description provided for @quitTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter ?'**
  String get quitTitle;

  /// No description provided for @quitBody.
  ///
  /// In fr, this message translates to:
  /// **'Vos réponses à cette série ne seront pas enregistrées.'**
  String get quitBody;

  /// No description provided for @quit.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get quit;

  /// No description provided for @stay.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get stay;

  /// No description provided for @resultScore.
  ///
  /// In fr, this message translates to:
  /// **'{score} / {total}'**
  String resultScore(int score, int total);

  /// No description provided for @resultPerfect.
  ///
  /// In fr, this message translates to:
  /// **'Parfait ! Vous avez tout compris.'**
  String get resultPerfect;

  /// No description provided for @resultGood.
  ///
  /// In fr, this message translates to:
  /// **'Très bien ! Il reste un ou deux points à revoir.'**
  String get resultGood;

  /// No description provided for @resultFair.
  ///
  /// In fr, this message translates to:
  /// **'C’est un début. Relire le passage aide beaucoup.'**
  String get resultFair;

  /// No description provided for @resultLow.
  ///
  /// In fr, this message translates to:
  /// **'Pas de souci : relisez le passage, puis réessayez.'**
  String get resultLow;

  /// No description provided for @takeawayTitle.
  ///
  /// In fr, this message translates to:
  /// **'À retenir'**
  String get takeawayTitle;

  /// No description provided for @keyVerseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Verset clé'**
  String get keyVerseTitle;

  /// No description provided for @missedTitle.
  ///
  /// In fr, this message translates to:
  /// **'À revoir'**
  String get missedTitle;

  /// No description provided for @missedHint.
  ///
  /// In fr, this message translates to:
  /// **'Ces questions reviendront dans vos révisions.'**
  String get missedHint;

  /// No description provided for @rereadPassage.
  ///
  /// In fr, this message translates to:
  /// **'Relire le passage'**
  String get rereadPassage;

  /// No description provided for @retryQuiz.
  ///
  /// In fr, this message translates to:
  /// **'Refaire les questions'**
  String get retryQuiz;

  /// No description provided for @nextLesson.
  ///
  /// In fr, this message translates to:
  /// **'Leçon suivante'**
  String get nextLesson;

  /// No description provided for @finish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get finish;

  /// No description provided for @reviewEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien à revoir aujourd’hui. Les questions ratées reviennent ici le lendemain.'**
  String get reviewEmpty;

  /// No description provided for @bookAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Auteur'**
  String get bookAuthor;

  /// No description provided for @bookPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Époque'**
  String get bookPeriod;

  /// No description provided for @bookThemes.
  ///
  /// In fr, this message translates to:
  /// **'Thèmes'**
  String get bookThemes;

  /// No description provided for @bookChapters.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 chapitre} other{{count} chapitres}}'**
  String bookChapters(int count);

  /// No description provided for @readBook.
  ///
  /// In fr, this message translates to:
  /// **'Lire le livre'**
  String get readBook;

  /// No description provided for @bookQuiz.
  ///
  /// In fr, this message translates to:
  /// **'Quiz ({count})'**
  String bookQuiz(int count);

  /// No description provided for @bookInfo.
  ///
  /// In fr, this message translates to:
  /// **'Fiche du livre'**
  String get bookInfo;

  /// No description provided for @chooseBook.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un livre'**
  String get chooseBook;

  /// No description provided for @chooseChapter.
  ///
  /// In fr, this message translates to:
  /// **'{book} : choisir un chapitre'**
  String chooseChapter(String book);

  /// No description provided for @chapterTitle.
  ///
  /// In fr, this message translates to:
  /// **'{book} {chapter}'**
  String chapterTitle(String book, int chapter);

  /// No description provided for @previousChapter.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get previousChapter;

  /// No description provided for @nextChapter.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get nextChapter;

  /// No description provided for @textSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille du texte'**
  String get textSize;

  /// No description provided for @searchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Mots, \"expression exacte\" ou référence'**
  String get searchHint;

  /// No description provided for @searchClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get searchClear;

  /// No description provided for @searchResults.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun verset} =1{1 verset} other{{count} versets}}'**
  String searchResults(int count);

  /// No description provided for @searchResultsFiltered.
  ///
  /// In fr, this message translates to:
  /// **'{shown} sur {total} versets'**
  String searchResultsFiltered(int shown, int total);

  /// No description provided for @searchNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucun verset ne contient tous ces mots. Essayez moins de mots, ou désactivez « Mots entiers ».'**
  String get searchNoResult;

  /// No description provided for @searchAll.
  ///
  /// In fr, this message translates to:
  /// **'Toute la Bible'**
  String get searchAll;

  /// No description provided for @searchOld.
  ///
  /// In fr, this message translates to:
  /// **'Ancien Testament'**
  String get searchOld;

  /// No description provided for @searchNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau Testament'**
  String get searchNew;

  /// No description provided for @searchBook.
  ///
  /// In fr, this message translates to:
  /// **'Livre…'**
  String get searchBook;

  /// No description provided for @searchAllBooks.
  ///
  /// In fr, this message translates to:
  /// **'Tous les livres'**
  String get searchAllBooks;

  /// No description provided for @searchWholeWords.
  ///
  /// In fr, this message translates to:
  /// **'Mots entiers'**
  String get searchWholeWords;

  /// No description provided for @searchIn.
  ///
  /// In fr, this message translates to:
  /// **'Chercher dans : {name}'**
  String searchIn(String name);

  /// No description provided for @searchGoTo.
  ///
  /// In fr, this message translates to:
  /// **'Aller à {ref}'**
  String searchGoTo(String ref);

  /// No description provided for @searchRecent.
  ///
  /// In fr, this message translates to:
  /// **'Recherches récentes'**
  String get searchRecent;

  /// No description provided for @searchClearRecent.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get searchClearRecent;

  /// No description provided for @searchTipsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment chercher'**
  String get searchTipsTitle;

  /// No description provided for @searchTipWords.
  ///
  /// In fr, this message translates to:
  /// **'Plusieurs mots : les versets qui les contiennent tous, dans n’importe quel ordre.'**
  String get searchTipWords;

  /// No description provided for @searchTipPhrase.
  ///
  /// In fr, this message translates to:
  /// **'Entre guillemets : l’expression exacte, ponctuation comprise ou non.'**
  String get searchTipPhrase;

  /// No description provided for @searchTipExclude.
  ///
  /// In fr, this message translates to:
  /// **'Un tiret devant un mot l’exclut.'**
  String get searchTipExclude;

  /// No description provided for @searchTipAccents.
  ///
  /// In fr, this message translates to:
  /// **'Accents et majuscules ne comptent pas ; un mot trouve aussi les mots qui commencent par lui (pardon → pardonne).'**
  String get searchTipAccents;

  /// No description provided for @searchTipRef.
  ///
  /// In fr, this message translates to:
  /// **'Une référence ouvre directement le passage.'**
  String get searchTipRef;

  /// No description provided for @searchExampleWords.
  ///
  /// In fr, this message translates to:
  /// **'berger brebis'**
  String get searchExampleWords;

  /// No description provided for @searchExamplePhrase.
  ///
  /// In fr, this message translates to:
  /// **'\"que la lumière soit\"'**
  String get searchExamplePhrase;

  /// No description provided for @searchExampleExclude.
  ///
  /// In fr, this message translates to:
  /// **'berger -loup'**
  String get searchExampleExclude;

  /// No description provided for @searchExampleRef.
  ///
  /// In fr, this message translates to:
  /// **'Jean 3:16'**
  String get searchExampleRef;

  /// No description provided for @searchPreparing.
  ///
  /// In fr, this message translates to:
  /// **'Préparation de la recherche…'**
  String get searchPreparing;

  /// No description provided for @searchMoreResults.
  ///
  /// In fr, this message translates to:
  /// **'Affiner la recherche pour voir les autres versets ({count, plural, =1{1 de plus} other{{count} de plus}}).'**
  String searchMoreResults(int count);

  /// No description provided for @progressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos progrès'**
  String get progressTitle;

  /// No description provided for @statLessons.
  ///
  /// In fr, this message translates to:
  /// **'Leçons terminées'**
  String get statLessons;

  /// No description provided for @statAnswered.
  ///
  /// In fr, this message translates to:
  /// **'Réponses données'**
  String get statAnswered;

  /// No description provided for @statAccuracy.
  ///
  /// In fr, this message translates to:
  /// **'Bonnes réponses'**
  String get statAccuracy;

  /// No description provided for @statMastered.
  ///
  /// In fr, this message translates to:
  /// **'Questions acquises'**
  String get statMastered;

  /// No description provided for @statStreak.
  ///
  /// In fr, this message translates to:
  /// **'Série en cours'**
  String get statStreak;

  /// No description provided for @statBestStreak.
  ///
  /// In fr, this message translates to:
  /// **'Meilleure série'**
  String get statBestStreak;

  /// No description provided for @daysShort.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 jour} other{{count} jours}}'**
  String daysShort(int count);

  /// No description provided for @favoritesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Versets mis de côté'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Touchez un verset dans la Bible pour le mettre de côté.'**
  String get favoritesEmpty;

  /// No description provided for @pathsProgressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Par parcours'**
  String get pathsProgressTitle;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Celle du téléphone'**
  String get languageSystem;

  /// No description provided for @themeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get themeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Celui du téléphone'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @parallelSetting.
  ///
  /// In fr, this message translates to:
  /// **'Lecture bilingue'**
  String get parallelSetting;

  /// No description provided for @parallelSettingHint.
  ///
  /// In fr, this message translates to:
  /// **'Affiche sous chaque verset l’autre traduction (KJV ou Segond).'**
  String get parallelSettingHint;

  /// No description provided for @textSizePreview.
  ///
  /// In fr, this message translates to:
  /// **'Au commencement, Dieu créa les cieux et la terre.'**
  String get textSizePreview;

  /// No description provided for @aboutTitle.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get aboutTitle;

  /// No description provided for @aboutTexts.
  ///
  /// In fr, this message translates to:
  /// **'Textes bibliques : Louis Segond 1910 et King James Version 1769, tous deux dans le domaine public.'**
  String get aboutTexts;

  /// No description provided for @aboutContent.
  ///
  /// In fr, this message translates to:
  /// **'Les questions s’en tiennent à ce que dit le texte, sans prendre parti entre les Églises. Chaque réponse renvoie au verset qui la justifie.'**
  String get aboutContent;

  /// No description provided for @aboutVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @resetProgress.
  ///
  /// In fr, this message translates to:
  /// **'Effacer ma progression'**
  String get resetProgress;

  /// No description provided for @resetProgressBody.
  ///
  /// In fr, this message translates to:
  /// **'Leçons terminées, révisions, série et chapitres lus seront effacés. Vos versets mis de côté et vos réglages sont conservés. Cette action est définitive.'**
  String get resetProgressBody;

  /// No description provided for @resetDone.
  ///
  /// In fr, this message translates to:
  /// **'Progression effacée'**
  String get resetDone;

  /// No description provided for @readingQuizTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quiz sur mes lectures'**
  String get readingQuizTitle;

  /// No description provided for @readingQuizSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Un quiz sur le ou les livres que vous avez lus'**
  String get readingQuizSubtitle;

  /// No description provided for @readingQuizIntro.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un ou plusieurs livres. Les questions relues viennent d’abord ; d’autres, tirées du texte même, complètent le quiz.'**
  String get readingQuizIntro;

  /// No description provided for @readingQuizBooks.
  ///
  /// In fr, this message translates to:
  /// **'Livres du quiz'**
  String get readingQuizBooks;

  /// No description provided for @selectMyReading.
  ///
  /// In fr, this message translates to:
  /// **'Mes lectures'**
  String get selectMyReading;

  /// No description provided for @selectNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get selectNone;

  /// No description provided for @genreLaw.
  ///
  /// In fr, this message translates to:
  /// **'Pentateuque'**
  String get genreLaw;

  /// No description provided for @genreHistory.
  ///
  /// In fr, this message translates to:
  /// **'Livres historiques'**
  String get genreHistory;

  /// No description provided for @genrePoetry.
  ///
  /// In fr, this message translates to:
  /// **'Poétiques'**
  String get genrePoetry;

  /// No description provided for @genreProphets.
  ///
  /// In fr, this message translates to:
  /// **'Prophètes'**
  String get genreProphets;

  /// No description provided for @genreGospels.
  ///
  /// In fr, this message translates to:
  /// **'Évangiles'**
  String get genreGospels;

  /// No description provided for @genreActs.
  ///
  /// In fr, this message translates to:
  /// **'Actes'**
  String get genreActs;

  /// No description provided for @genreEpistles.
  ///
  /// In fr, this message translates to:
  /// **'Épîtres'**
  String get genreEpistles;

  /// No description provided for @genreApocalyptic.
  ///
  /// In fr, this message translates to:
  /// **'Apocalypse'**
  String get genreApocalyptic;

  /// No description provided for @chaptersReadOf.
  ///
  /// In fr, this message translates to:
  /// **'{done} / {total} chapitres lus'**
  String chaptersReadOf(int done, int total);

  /// No description provided for @scopeRead.
  ///
  /// In fr, this message translates to:
  /// **'Chapitres lus'**
  String get scopeRead;

  /// No description provided for @scopeWhole.
  ///
  /// In fr, this message translates to:
  /// **'Livres entiers'**
  String get scopeWhole;

  /// No description provided for @scopeReadHint.
  ///
  /// In fr, this message translates to:
  /// **'Les questions portent seulement sur les chapitres que vous avez lus.'**
  String get scopeReadHint;

  /// No description provided for @scopeWholeHint.
  ///
  /// In fr, this message translates to:
  /// **'Les questions portent sur l’ensemble des livres choisis.'**
  String get scopeWholeHint;

  /// No description provided for @questionCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de questions'**
  String get questionCountLabel;

  /// No description provided for @startReadingQuiz.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Commencer · 1 livre} other{Commencer · {count} livres}}'**
  String startReadingQuiz(int count);

  /// No description provided for @readingQuizPickOne.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un livre.'**
  String get readingQuizPickOne;

  /// No description provided for @readingQuizTooFew.
  ///
  /// In fr, this message translates to:
  /// **'Pas assez de matière pour un quiz : ajoutez des chapitres, ou choisissez « Livres entiers ».'**
  String get readingQuizTooFew;

  /// No description provided for @readingQuizNamed.
  ///
  /// In fr, this message translates to:
  /// **'Quiz : {name}'**
  String readingQuizNamed(String name);

  /// No description provided for @readingQuizBooksCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 livre} other{{count} livres}}'**
  String readingQuizBooksCount(int count);

  /// No description provided for @fromTheText.
  ///
  /// In fr, this message translates to:
  /// **'Tiré du texte'**
  String get fromTheText;

  /// No description provided for @markChapterRead.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme lu'**
  String get markChapterRead;

  /// No description provided for @chapterRead.
  ///
  /// In fr, this message translates to:
  /// **'Chapitre lu'**
  String get chapterRead;

  /// No description provided for @markBookRead.
  ///
  /// In fr, this message translates to:
  /// **'Marquer tout le livre comme lu'**
  String get markBookRead;

  /// No description provided for @unmarkBookRead.
  ///
  /// In fr, this message translates to:
  /// **'Retirer « lu » pour ce livre'**
  String get unmarkBookRead;

  /// No description provided for @quizOnThisBook.
  ///
  /// In fr, this message translates to:
  /// **'Quiz sur ce livre'**
  String get quizOnThisBook;

  /// No description provided for @chaptersReadTotal.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun chapitre lu} =1{1 chapitre lu} other{{count} chapitres lus}}'**
  String chaptersReadTotal(int count);

  /// No description provided for @testThisChapter.
  ///
  /// In fr, this message translates to:
  /// **'Tester ce chapitre'**
  String get testThisChapter;

  /// No description provided for @chapterQuizTooFew.
  ///
  /// In fr, this message translates to:
  /// **'Ce chapitre est trop court pour un quiz. Essayez un quiz sur le livre entier.'**
  String get chapterQuizTooFew;

  /// No description provided for @bibleReadingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ma lecture de la Bible'**
  String get bibleReadingTitle;

  /// No description provided for @bibleReadingTotal.
  ///
  /// In fr, this message translates to:
  /// **'{done, plural, =0{Aucun chapitre lu sur {total}} =1{1 chapitre lu sur {total}} other{{done} chapitres lus sur {total}}}'**
  String bibleReadingTotal(int done, int total);

  /// No description provided for @bibleReadingHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez un livre pour voir ses chapitres.'**
  String get bibleReadingHint;

  /// No description provided for @bookReadSemantics.
  ///
  /// In fr, this message translates to:
  /// **'{name} : {done} chapitres lus sur {total}'**
  String bookReadSemantics(String name, int done, int total);

  /// No description provided for @booksStarted.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun livre commencé} =1{1 livre commencé} other{{count} livres commencés}}'**
  String booksStarted(int count);

  /// No description provided for @booksFinished.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucun terminé} =1{1 terminé} other{{count} terminés}}'**
  String booksFinished(int count);

  /// No description provided for @updateAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Version {version} disponible'**
  String updateAvailable(String version);

  /// No description provided for @updateRequired.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour obligatoire : version {version}'**
  String updateRequired(String version);

  /// No description provided for @updateRequiredHint.
  ///
  /// In fr, this message translates to:
  /// **'Cette version n’est plus prise en charge : installez la nouvelle pour continuer.'**
  String get updateRequiredHint;

  /// No description provided for @updateDownload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get updateDownload;

  /// No description provided for @updateLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get updateLater;

  /// No description provided for @webInstallTitle.
  ///
  /// In fr, this message translates to:
  /// **'Installez l’application Android'**
  String get webInstallTitle;

  /// No description provided for @webInstallBody.
  ///
  /// In fr, this message translates to:
  /// **'Plus fluide au quotidien, et vos données ne dépendent plus du navigateur.'**
  String get webInstallBody;

  /// No description provided for @webInstallAction.
  ///
  /// In fr, this message translates to:
  /// **'Installer'**
  String get webInstallAction;

  /// No description provided for @homeScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez l’application à l’écran d’accueil'**
  String get homeScreenTitle;

  /// No description provided for @homeScreenBody.
  ///
  /// In fr, this message translates to:
  /// **'Touchez Partager (le carré avec une flèche), puis « Sur l’écran d’accueil ». L’application s’ouvrira en plein écran et vos données seront mieux conservées.'**
  String get homeScreenBody;

  /// No description provided for @homeScreenDismiss.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get homeScreenDismiss;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
