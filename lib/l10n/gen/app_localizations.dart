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
  /// **'{count, plural, =0{0 question} =1{1 question} other{{count} questions}}'**
  String questionsCount(int count);

  /// No description provided for @versesCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 verset} =1{1 verset} other{{count} versets}}'**
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
  /// **'{count, plural, =0{0 jour de suite} =1{1 jour de suite} other{{count} jours de suite}}'**
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
  /// **'{count, plural, =0{0 question à revoir aujourd’hui} =1{1 question à revoir aujourd’hui} other{{count} questions à revoir aujourd’hui}}'**
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

  /// No description provided for @printedRef.
  ///
  /// In fr, this message translates to:
  /// **'Segond imprimée : {ref}'**
  String printedRef(String ref);

  /// No description provided for @printedNoteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Numéros des versets'**
  String get printedNoteTitle;

  /// No description provided for @printedNoteBody.
  ///
  /// In fr, this message translates to:
  /// **'Les numéros de versets de l’application suivent ceux de la King James, pour que le français et l’anglais aient les mêmes références.\n\nBeaucoup de Bibles Segond imprimées numérotent quelques passages autrement. Dans les Psaumes surtout, le titre du psaume y compte souvent comme verset 1 : le Psaume 19:7 de l’application est le Psaume 19:8 dans votre Bible.\n\nQuand c’est le cas, l’application indique aussi le numéro de la Segond imprimée.'**
  String get printedNoteBody;

  /// No description provided for @printedChapterBanner.
  ///
  /// In fr, this message translates to:
  /// **'Dans une Segond imprimée, les versets de ce chapitre sont numérotés autrement. Touchez un verset pour voir son numéro sur papier.'**
  String get printedChapterBanner;

  /// No description provided for @printedMore.
  ///
  /// In fr, this message translates to:
  /// **'En savoir plus'**
  String get printedMore;

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

  /// No description provided for @navNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get navNotes;

  /// No description provided for @notesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notes de prédication'**
  String get notesTitle;

  /// No description provided for @notesEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune note pour l’instant'**
  String get notesEmptyTitle;

  /// No description provided for @notesEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Pendant une prédication, notez ce que vous retenez et associez-y les passages lus. Vos notes restent sur votre téléphone.'**
  String get notesEmptyBody;

  /// No description provided for @notesNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle note'**
  String get notesNew;

  /// No description provided for @notesSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans mes notes'**
  String get notesSearch;

  /// No description provided for @notesNoMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucune note ne correspond.'**
  String get notesNoMatch;

  /// No description provided for @noteUntitled.
  ///
  /// In fr, this message translates to:
  /// **'Sans titre'**
  String get noteUntitled;

  /// No description provided for @noteTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Titre ou thème de la prédication'**
  String get noteTitleHint;

  /// No description provided for @notePreacherHint.
  ///
  /// In fr, this message translates to:
  /// **'Prédicateur'**
  String get notePreacherHint;

  /// No description provided for @notePlaceHint.
  ///
  /// In fr, this message translates to:
  /// **'Lieu, Église'**
  String get notePlaceHint;

  /// No description provided for @noteDateTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Jour de la prédication'**
  String get noteDateTooltip;

  /// No description provided for @notePassages.
  ///
  /// In fr, this message translates to:
  /// **'Passages'**
  String get notePassages;

  /// No description provided for @noteAddPassage.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un passage'**
  String get noteAddPassage;

  /// No description provided for @noteBody.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get noteBody;

  /// No description provided for @noteBodyHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce que vous retenez… Les références que vous tapez (Jean 3:16, Ps 23) sont repérées.'**
  String get noteBodyHint;

  /// No description provided for @noteFoundRefs.
  ///
  /// In fr, this message translates to:
  /// **'Repérés dans vos notes : touchez pour ajouter'**
  String get noteFoundRefs;

  /// No description provided for @noteReadPassages.
  ///
  /// In fr, this message translates to:
  /// **'Lire les passages'**
  String get noteReadPassages;

  /// No description provided for @noteDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la note'**
  String get noteDelete;

  /// No description provided for @noteDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Note supprimée'**
  String get noteDeleted;

  /// No description provided for @noteAutosave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrée automatiquement'**
  String get noteAutosave;

  /// No description provided for @notePassageRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Passage retiré'**
  String get notePassageRemoved;

  /// No description provided for @notePassageAdded.
  ///
  /// In fr, this message translates to:
  /// **'Passage ajouté'**
  String get notePassageAdded;

  /// No description provided for @noteShareFooter.
  ///
  /// In fr, this message translates to:
  /// **'Notes prises avec Quiz Biblique'**
  String get noteShareFooter;

  /// No description provided for @keepScreenOnSetting.
  ///
  /// In fr, this message translates to:
  /// **'Garder l’écran allumé'**
  String get keepScreenOnSetting;

  /// No description provided for @keepScreenOnHint.
  ///
  /// In fr, this message translates to:
  /// **'Tant qu’une note de prédication est ouverte, le téléphone ne se verrouille pas.'**
  String get keepScreenOnHint;

  /// No description provided for @shareImage.
  ///
  /// In fr, this message translates to:
  /// **'Image à partager'**
  String get shareImage;

  /// No description provided for @shareImageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Image du verset'**
  String get shareImageTitle;

  /// No description provided for @shareImageAction.
  ///
  /// In fr, this message translates to:
  /// **'Partager l’image'**
  String get shareImageAction;

  /// No description provided for @imageDark.
  ///
  /// In fr, this message translates to:
  /// **'Fond sombre'**
  String get imageDark;

  /// No description provided for @imageLight.
  ///
  /// In fr, this message translates to:
  /// **'Fond clair'**
  String get imageLight;

  /// No description provided for @shareImageFailed.
  ///
  /// In fr, this message translates to:
  /// **'L’image n’a pas pu être créée.'**
  String get shareImageFailed;

  /// No description provided for @shareImageLong.
  ///
  /// In fr, this message translates to:
  /// **'Passage long : seul le début figure sur l’image.'**
  String get shareImageLong;

  /// No description provided for @backupReminderNever.
  ///
  /// In fr, this message translates to:
  /// **'Vos notes ne sont pas encore sauvegardées. Une sauvegarde permet de les retrouver si vous changez de téléphone.'**
  String get backupReminderNever;

  /// No description provided for @backupReminderDays.
  ///
  /// In fr, this message translates to:
  /// **'Dernière sauvegarde de vos notes il y a {count, plural, =0{0 jour} =1{1 jour} other{{count} jours}}. Pensez à en faire une nouvelle.'**
  String backupReminderDays(int count);

  /// No description provided for @backupNow.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get backupNow;

  /// No description provided for @later.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get later;

  /// No description provided for @shareWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get shareWhatsApp;

  /// No description provided for @shareOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre application (e-mail, SMS…)'**
  String get shareOther;

  /// No description provided for @copyText.
  ///
  /// In fr, this message translates to:
  /// **'Copier le texte'**
  String get copyText;

  /// No description provided for @whatsappFailed.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp n’a pas pu s’ouvrir : choisissez une autre application.'**
  String get whatsappFailed;

  /// No description provided for @noteQuiz.
  ///
  /// In fr, this message translates to:
  /// **'Tester ces passages'**
  String get noteQuiz;

  /// No description provided for @noteQuizTooFew.
  ///
  /// In fr, this message translates to:
  /// **'Ces passages sont trop courts pour un quiz.'**
  String get noteQuizTooFew;

  /// No description provided for @addPassageHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Jean 3:16-18, Ps 23, 1 Co 13'**
  String get addPassageHint;

  /// No description provided for @addPassageInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Référence non reconnue. Écrivez le livre, le chapitre puis les versets : Jean 3:16-18.'**
  String get addPassageInvalid;

  /// No description provided for @addPassageAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addPassageAdd;

  /// No description provided for @addPassageNumbering.
  ///
  /// In fr, this message translates to:
  /// **'Ce passage est numéroté autrement selon les Bibles. D’où viennent ces numéros ?'**
  String get addPassageNumbering;

  /// No description provided for @addPassagePrinted.
  ///
  /// In fr, this message translates to:
  /// **'Ma Bible imprimée (Segond)'**
  String get addPassagePrinted;

  /// No description provided for @addPassageApp.
  ///
  /// In fr, this message translates to:
  /// **'L’application'**
  String get addPassageApp;

  /// No description provided for @addToNote.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à une note'**
  String get addToNote;

  /// No description provided for @addToNoteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter {ref} à…'**
  String addToNoteTitle(String ref);

  /// No description provided for @addedToNote.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté à « {title} »'**
  String addedToNote(String title);

  /// No description provided for @alreadyInNote.
  ///
  /// In fr, this message translates to:
  /// **'Déjà dans « {title} »'**
  String alreadyInNote(String title);

  /// No description provided for @open.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get open;

  /// No description provided for @inYourNotes.
  ///
  /// In fr, this message translates to:
  /// **'Dans vos notes'**
  String get inYourNotes;

  /// No description provided for @notesBackup.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder mes notes'**
  String get notesBackup;

  /// No description provided for @notesRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer une sauvegarde'**
  String get notesRestore;

  /// No description provided for @notesBackupHint.
  ///
  /// In fr, this message translates to:
  /// **'Vos notes restent sur ce téléphone. Sauvegardez-les de temps en temps (Drive, e-mail…) pour les retrouver sur un autre appareil.'**
  String get notesBackupHint;

  /// No description provided for @notesBackupEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune note à sauvegarder.'**
  String get notesBackupEmpty;

  /// No description provided for @notesRestoreAdded.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune nouvelle note} =1{1 nouvelle note} other{{count} nouvelles notes}}'**
  String notesRestoreAdded(int count);

  /// No description provided for @notesRestoreUpdated.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune mise à jour} =1{1 mise à jour} other{{count} mises à jour}}'**
  String notesRestoreUpdated(int count);

  /// No description provided for @notesRestoreDone.
  ///
  /// In fr, this message translates to:
  /// **'Restauration terminée : {result}.'**
  String notesRestoreDone(String result);

  /// No description provided for @notesRestoreInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n’est pas une sauvegarde de notes du Quiz Biblique.'**
  String get notesRestoreInvalid;

  /// No description provided for @notesRestoreNewer.
  ///
  /// In fr, this message translates to:
  /// **'Cette sauvegarde vient d’une version plus récente : mettez l’application à jour.'**
  String get notesRestoreNewer;

  /// No description provided for @notesRestoreError.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier n’a pas pu être lu.'**
  String get notesRestoreError;

  /// No description provided for @pathReviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bilan du parcours'**
  String get pathReviewTitle;

  /// No description provided for @pathReviewSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 question tirée} =1{1 question tirée} other{{count} questions tirées}} de toutes les leçons du parcours'**
  String pathReviewSubtitle(int count);

  /// No description provided for @pathReviewHint.
  ///
  /// In fr, this message translates to:
  /// **'Idéal une fois les leçons terminées'**
  String get pathReviewHint;

  /// No description provided for @pathReviewAction.
  ///
  /// In fr, this message translates to:
  /// **'Faire le bilan du parcours'**
  String get pathReviewAction;

  /// No description provided for @nextPath.
  ///
  /// In fr, this message translates to:
  /// **'Parcours suivant'**
  String get nextPath;

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
  /// **'{count, plural, =0{0 chapitre} =1{1 chapitre} other{{count} chapitres}}'**
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
  /// **'Affiner la recherche pour voir les autres versets ({count, plural, =0{0 de plus} =1{1 de plus} other{{count} de plus}}).'**
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
  /// **'{count, plural, =0{0 jour} =1{1 jour} other{{count} jours}}'**
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
  /// **'{count, plural, =0{Commencer · 0 livre} =1{Commencer · 1 livre} other{Commencer · {count} livres}}'**
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
  /// **'{count, plural, =0{0 livre} =1{1 livre} other{{count} livres}}'**
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

  /// No description provided for @onlineTitle.
  ///
  /// In fr, this message translates to:
  /// **'Jouer avec d’autres'**
  String get onlineTitle;

  /// No description provided for @onlineCardSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Matchs et tournois en ligne sur les passages de votre choix'**
  String get onlineCardSubtitle;

  /// No description provided for @onlineIntro.
  ///
  /// In fr, this message translates to:
  /// **'Affrontez d’autres lecteurs, seul ou en équipe, sur un ou plusieurs passages de la Bible. Le premier qui prend la main répond ; une bonne réponse rapporte 10 points, une erreur en coûte 5.'**
  String get onlineIntro;

  /// No description provided for @onlineOptional.
  ///
  /// In fr, this message translates to:
  /// **'Le jeu en ligne est facultatif : tout le reste de l’application fonctionne sans compte et sans Internet.'**
  String get onlineOptional;

  /// No description provided for @onlineBecomePlayer.
  ///
  /// In fr, this message translates to:
  /// **'Devenir joueur'**
  String get onlineBecomePlayer;

  /// No description provided for @onlineAccountHint.
  ///
  /// In fr, this message translates to:
  /// **'Il faut un numéro de téléphone (code reçu par WhatsApp) et un pseudo.'**
  String get onlineAccountHint;

  /// No description provided for @onlineCreateMatch.
  ///
  /// In fr, this message translates to:
  /// **'Créer un match'**
  String get onlineCreateMatch;

  /// No description provided for @onlineJoin.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get onlineJoin;

  /// No description provided for @onlineJoinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre avec un code'**
  String get onlineJoinTitle;

  /// No description provided for @onlineJoinHint.
  ///
  /// In fr, this message translates to:
  /// **'Code à 6 caractères'**
  String get onlineJoinHint;

  /// No description provided for @onlineCreateTournament.
  ///
  /// In fr, this message translates to:
  /// **'Créer un tournoi'**
  String get onlineCreateTournament;

  /// No description provided for @onlineOpenMatches.
  ///
  /// In fr, this message translates to:
  /// **'Matchs ouverts'**
  String get onlineOpenMatches;

  /// No description provided for @onlineOpenTournaments.
  ///
  /// In fr, this message translates to:
  /// **'Tournois ouverts'**
  String get onlineOpenTournaments;

  /// No description provided for @onlineNoOpenMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match ouvert pour l’instant. Créez-en un et partagez son code.'**
  String get onlineNoOpenMatch;

  /// No description provided for @onlineMyTournaments.
  ///
  /// In fr, this message translates to:
  /// **'Mes tournois'**
  String get onlineMyTournaments;

  /// No description provided for @onlineInvitations.
  ///
  /// In fr, this message translates to:
  /// **'Invitations'**
  String get onlineInvitations;

  /// No description provided for @onlineHistory.
  ///
  /// In fr, this message translates to:
  /// **'Mes matchs'**
  String get onlineHistory;

  /// No description provided for @onlineNoHistory.
  ///
  /// In fr, this message translates to:
  /// **'Vos matchs terminés s’afficheront ici.'**
  String get onlineNoHistory;

  /// No description provided for @onlineProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil de joueur'**
  String get onlineProfile;

  /// No description provided for @onlineProjection.
  ///
  /// In fr, this message translates to:
  /// **'Écran de projection'**
  String get onlineProjection;

  /// No description provided for @onlineProjectionHint.
  ///
  /// In fr, this message translates to:
  /// **'Affichez un match ou un tournoi en grand (vidéoprojecteur, télévision), sans compte.'**
  String get onlineProjectionHint;

  /// No description provided for @onlineCurrentMatch.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez un match en cours'**
  String get onlineCurrentMatch;

  /// No description provided for @onlineCurrentTournament.
  ///
  /// In fr, this message translates to:
  /// **'Vous participez au tournoi « {name} »'**
  String onlineCurrentTournament(String name);

  /// No description provided for @onlineResume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get onlineResume;

  /// No description provided for @onlineStats.
  ///
  /// In fr, this message translates to:
  /// **'{played, plural, =0{Aucun match} =1{1 match} other{{played} matchs}} · {won, plural, =0{aucun gagné} =1{1 gagné} other{{won} gagnés}}'**
  String onlineStats(int played, int won);

  /// No description provided for @onlineOffline.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion au serveur. Vérifiez Internet puis réessayez.'**
  String get onlineOffline;

  /// No description provided for @onlinePlayers.
  ///
  /// In fr, this message translates to:
  /// **'{players}/{max} joueurs'**
  String onlinePlayers(int players, int max);

  /// No description provided for @onlineBy.
  ///
  /// In fr, this message translates to:
  /// **'par {name}'**
  String onlineBy(String name);

  /// No description provided for @onlineModeSolo.
  ///
  /// In fr, this message translates to:
  /// **'Individuel'**
  String get onlineModeSolo;

  /// No description provided for @onlineModeTeam.
  ///
  /// In fr, this message translates to:
  /// **'Par équipes'**
  String get onlineModeTeam;

  /// No description provided for @onlineRealtimeOff.
  ///
  /// In fr, this message translates to:
  /// **'Connexion lente : l’affichage peut avoir un peu de retard.'**
  String get onlineRealtimeOff;

  /// No description provided for @signInTitle.
  ///
  /// In fr, this message translates to:
  /// **'Devenir joueur'**
  String get signInTitle;

  /// No description provided for @signInPhone.
  ///
  /// In fr, this message translates to:
  /// **'Votre numéro de téléphone'**
  String get signInPhone;

  /// No description provided for @signInCountry.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get signInCountry;

  /// No description provided for @signInSendCode.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir le code par WhatsApp'**
  String get signInSendCode;

  /// No description provided for @signInCodeSent.
  ///
  /// In fr, this message translates to:
  /// **'Code envoyé au {phone}'**
  String signInCodeSent(String phone);

  /// No description provided for @signInCode.
  ///
  /// In fr, this message translates to:
  /// **'Code reçu'**
  String get signInCode;

  /// No description provided for @signInVerify.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get signInVerify;

  /// No description provided for @signInResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get signInResend;

  /// No description provided for @signInChangeNumber.
  ///
  /// In fr, this message translates to:
  /// **'Changer de numéro'**
  String get signInChangeNumber;

  /// No description provided for @signInPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Votre numéro sert seulement à protéger votre compte. Les autres joueurs ne voient que votre pseudo.'**
  String get signInPrivacy;

  /// No description provided for @pseudoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre pseudo'**
  String get pseudoTitle;

  /// No description provided for @pseudoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo'**
  String get pseudoLabel;

  /// No description provided for @pseudoHint.
  ///
  /// In fr, this message translates to:
  /// **'3 à 20 caractères, visible par les autres joueurs'**
  String get pseudoHint;

  /// No description provided for @pseudoSave.
  ///
  /// In fr, this message translates to:
  /// **'C’est parti'**
  String get pseudoSave;

  /// No description provided for @profileRename.
  ///
  /// In fr, this message translates to:
  /// **'Changer de pseudo'**
  String get profileRename;

  /// No description provided for @profileSignOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileSignOut;

  /// No description provided for @profileDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte joueur'**
  String get profileDelete;

  /// No description provided for @profileDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Votre pseudo et votre historique seront effacés, et vous quitterez la partie en cours. Vos lectures et vos progrès dans l’application ne sont pas touchés.'**
  String get profileDeleteConfirm;

  /// No description provided for @profileDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Compte joueur supprimé'**
  String get profileDeleted;

  /// No description provided for @profileTournamentsWon.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun tournoi gagné} =1{1 tournoi gagné} other{{count} tournois gagnés}}'**
  String profileTournamentsWon(int count);

  /// No description provided for @report.
  ///
  /// In fr, this message translates to:
  /// **'Signaler ce pseudo'**
  String get report;

  /// No description provided for @reportReason.
  ///
  /// In fr, this message translates to:
  /// **'Pourquoi ? (facultatif)'**
  String get reportReason;

  /// No description provided for @reportSent.
  ///
  /// In fr, this message translates to:
  /// **'Signalement envoyé. Merci.'**
  String get reportSent;

  /// No description provided for @createMatchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau match'**
  String get createMatchTitle;

  /// No description provided for @createPassages.
  ///
  /// In fr, this message translates to:
  /// **'Passages'**
  String get createPassages;

  /// No description provided for @createAddPassage.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un passage'**
  String get createAddPassage;

  /// No description provided for @createNoPassage.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un passage sur lequel porteront les questions.'**
  String get createNoPassage;

  /// No description provided for @createAvailable.
  ///
  /// In fr, this message translates to:
  /// **'{available} questions possibles sur ces passages'**
  String createAvailable(int available);

  /// No description provided for @createNotEnough.
  ///
  /// In fr, this message translates to:
  /// **'Pas assez de questions : ajoutez ou élargissez un passage, ou réduisez le nombre de questions.'**
  String get createNotEnough;

  /// No description provided for @createBible.
  ///
  /// In fr, this message translates to:
  /// **'Bible du match'**
  String get createBible;

  /// No description provided for @createQuestions.
  ///
  /// In fr, this message translates to:
  /// **'Questions : {n}'**
  String createQuestions(int n);

  /// No description provided for @createQuestionTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps par question : {seconds} s'**
  String createQuestionTime(int seconds);

  /// No description provided for @createHandTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps pour répondre après avoir pris la main : {seconds} s'**
  String createHandTime(int seconds);

  /// No description provided for @createMaxPlayers.
  ///
  /// In fr, this message translates to:
  /// **'Joueurs au plus : {n}'**
  String createMaxPlayers(int n);

  /// No description provided for @createPublic.
  ///
  /// In fr, this message translates to:
  /// **'Visible dans les matchs ouverts'**
  String get createPublic;

  /// No description provided for @createPublicHint.
  ///
  /// In fr, this message translates to:
  /// **'Sinon, seuls ceux qui ont le code peuvent entrer.'**
  String get createPublicHint;

  /// No description provided for @createSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Créer le match'**
  String get createSubmit;

  /// No description provided for @passagePickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un passage'**
  String get passagePickerTitle;

  /// No description provided for @passageBook.
  ///
  /// In fr, this message translates to:
  /// **'Livre'**
  String get passageBook;

  /// No description provided for @passageFromChapter.
  ///
  /// In fr, this message translates to:
  /// **'Du chapitre'**
  String get passageFromChapter;

  /// No description provided for @passageToChapter.
  ///
  /// In fr, this message translates to:
  /// **'au chapitre'**
  String get passageToChapter;

  /// No description provided for @passageVerses.
  ///
  /// In fr, this message translates to:
  /// **'Seulement certains versets'**
  String get passageVerses;

  /// No description provided for @passageFromVerse.
  ///
  /// In fr, this message translates to:
  /// **'Du verset'**
  String get passageFromVerse;

  /// No description provided for @passageToVerse.
  ///
  /// In fr, this message translates to:
  /// **'au verset'**
  String get passageToVerse;

  /// No description provided for @passageAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get passageAdd;

  /// No description provided for @lobbyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Salle d’attente'**
  String get lobbyTitle;

  /// No description provided for @lobbyCode.
  ///
  /// In fr, this message translates to:
  /// **'Code du match'**
  String get lobbyCode;

  /// No description provided for @lobbyShareHint.
  ///
  /// In fr, this message translates to:
  /// **'Les autres joueurs saisissent ce code dans Jouer → Rejoindre, ou scannent le QR code avec l’appareil photo.'**
  String get lobbyShareHint;

  /// No description provided for @lobbyShareWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'Inviter par WhatsApp'**
  String get lobbyShareWhatsApp;

  /// No description provided for @lobbyShareText.
  ///
  /// In fr, this message translates to:
  /// **'Rejoins-moi pour un match de Quiz Biblique ({passages}) ! Code : {code}\n{link}'**
  String lobbyShareText(String passages, String code, String link);

  /// No description provided for @lobbyPlayers.
  ///
  /// In fr, this message translates to:
  /// **'Joueurs'**
  String get lobbyPlayers;

  /// No description provided for @lobbyWaitCreator.
  ///
  /// In fr, this message translates to:
  /// **'En attente du lancement par {name}…'**
  String lobbyWaitCreator(String name);

  /// No description provided for @lobbyStart.
  ///
  /// In fr, this message translates to:
  /// **'Lancer le match'**
  String get lobbyStart;

  /// No description provided for @lobbyNeedPlayers.
  ///
  /// In fr, this message translates to:
  /// **'Il faut au moins 2 joueurs.'**
  String get lobbyNeedPlayers;

  /// No description provided for @lobbyLeave.
  ///
  /// In fr, this message translates to:
  /// **'Quitter'**
  String get lobbyLeave;

  /// No description provided for @lobbyLeaveConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Quitter ce match ?'**
  String get lobbyLeaveConfirm;

  /// No description provided for @lobbyLeaveRunning.
  ///
  /// In fr, this message translates to:
  /// **'Si vous quittez un match en cours, vous l’abandonnez.'**
  String get lobbyLeaveRunning;

  /// No description provided for @lobbyKick.
  ///
  /// In fr, this message translates to:
  /// **'Retirer du match'**
  String get lobbyKick;

  /// No description provided for @lobbyCreator.
  ///
  /// In fr, this message translates to:
  /// **'créateur'**
  String get lobbyCreator;

  /// No description provided for @lobbySettings.
  ///
  /// In fr, this message translates to:
  /// **'{n} questions · {seconds} s par question · main : {hand} s'**
  String lobbySettings(int n, int seconds, String hand);

  /// No description provided for @lobbyCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Ce match a été annulé.'**
  String get lobbyCancelled;

  /// No description provided for @lobbyNoTeam.
  ///
  /// In fr, this message translates to:
  /// **'Sans équipe'**
  String get lobbyNoTeam;

  /// No description provided for @lobbyNoTeamHint.
  ///
  /// In fr, this message translates to:
  /// **'Les joueurs sans équipe ne jouent pas : demandez à entrer dans une équipe, ou créez-la.'**
  String get lobbyNoTeamHint;

  /// No description provided for @teamCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer une équipe'**
  String get teamCreate;

  /// No description provided for @teamName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l’équipe'**
  String get teamName;

  /// No description provided for @teamCaptain.
  ///
  /// In fr, this message translates to:
  /// **'capitaine'**
  String get teamCaptain;

  /// No description provided for @teamInvite.
  ///
  /// In fr, this message translates to:
  /// **'Inviter un joueur'**
  String get teamInvite;

  /// No description provided for @teamInviteSearch.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo du joueur'**
  String get teamInviteSearch;

  /// No description provided for @teamInviteBusy.
  ///
  /// In fr, this message translates to:
  /// **'déjà en partie'**
  String get teamInviteBusy;

  /// No description provided for @teamInvited.
  ///
  /// In fr, this message translates to:
  /// **'invité'**
  String get teamInvited;

  /// No description provided for @teamRequested.
  ///
  /// In fr, this message translates to:
  /// **'demande à entrer'**
  String get teamRequested;

  /// No description provided for @teamAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get teamAccept;

  /// No description provided for @teamDecline.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get teamDecline;

  /// No description provided for @teamRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get teamRemove;

  /// No description provided for @teamAskJoin.
  ///
  /// In fr, this message translates to:
  /// **'Demander à entrer'**
  String get teamAskJoin;

  /// No description provided for @teamLeave.
  ///
  /// In fr, this message translates to:
  /// **'Quitter l’équipe'**
  String get teamLeave;

  /// No description provided for @teamRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get teamRename;

  /// No description provided for @teamMembers.
  ///
  /// In fr, this message translates to:
  /// **'{n} joueurs'**
  String teamMembers(int n);

  /// No description provided for @teamInvitation.
  ///
  /// In fr, this message translates to:
  /// **'{captain} vous invite dans l’équipe « {team} »'**
  String teamInvitation(String captain, String team);

  /// No description provided for @teamSizeHint.
  ///
  /// In fr, this message translates to:
  /// **'De {min} à {max} joueurs par équipe.'**
  String teamSizeHint(int min, int max);

  /// No description provided for @playCountdown.
  ///
  /// In fr, this message translates to:
  /// **'Prêts ?'**
  String get playCountdown;

  /// No description provided for @playQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Question {index} sur {total}'**
  String playQuestion(int index, int total);

  /// No description provided for @playTiebreak.
  ///
  /// In fr, this message translates to:
  /// **'Question décisive : la première bonne réponse l’emporte'**
  String get playTiebreak;

  /// No description provided for @playBuzz.
  ///
  /// In fr, this message translates to:
  /// **'Je réponds !'**
  String get playBuzz;

  /// No description provided for @playYourHand.
  ///
  /// In fr, this message translates to:
  /// **'À vous ! Choisissez la réponse'**
  String get playYourHand;

  /// No description provided for @playHandOf.
  ///
  /// In fr, this message translates to:
  /// **'{name} a la main'**
  String playHandOf(String name);

  /// No description provided for @playLocked.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne pouvez plus répondre à cette question'**
  String get playLocked;

  /// No description provided for @playLockedTeam.
  ///
  /// In fr, this message translates to:
  /// **'Votre équipe ne peut plus répondre à cette question'**
  String get playLockedTeam;

  /// No description provided for @playPaused.
  ///
  /// In fr, this message translates to:
  /// **'Chrono en pause'**
  String get playPaused;

  /// No description provided for @playCorrect.
  ///
  /// In fr, this message translates to:
  /// **'Bonne réponse ! +10'**
  String get playCorrect;

  /// No description provided for @playWrong.
  ///
  /// In fr, this message translates to:
  /// **'Mauvaise réponse : −5'**
  String get playWrong;

  /// No description provided for @playWonBy.
  ///
  /// In fr, this message translates to:
  /// **'{name} a trouvé'**
  String playWonBy(String name);

  /// No description provided for @playNobody.
  ///
  /// In fr, this message translates to:
  /// **'Personne n’a trouvé'**
  String get playNobody;

  /// No description provided for @playAnswerWas.
  ///
  /// In fr, this message translates to:
  /// **'Réponse : {answer}'**
  String playAnswerWas(String answer);

  /// No description provided for @playTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Temps écoulé'**
  String get playTimeout;

  /// No description provided for @playFromText.
  ///
  /// In fr, this message translates to:
  /// **'Tiré du texte'**
  String get playFromText;

  /// No description provided for @playSpectator.
  ///
  /// In fr, this message translates to:
  /// **'Vous regardez ce match'**
  String get playSpectator;

  /// No description provided for @playScores.
  ///
  /// In fr, this message translates to:
  /// **'Scores'**
  String get playScores;

  /// No description provided for @playHandLost.
  ///
  /// In fr, this message translates to:
  /// **'{name} a laissé filer la main : −5'**
  String playHandLost(String name);

  /// No description provided for @playAnsweredWrong.
  ///
  /// In fr, this message translates to:
  /// **'{name} s’est trompé : −5'**
  String playAnsweredWrong(String name);

  /// No description provided for @playPoints.
  ///
  /// In fr, this message translates to:
  /// **'{points} pts'**
  String playPoints(int points);

  /// No description provided for @playLeft.
  ///
  /// In fr, this message translates to:
  /// **'a quitté'**
  String get playLeft;

  /// No description provided for @playOffline.
  ///
  /// In fr, this message translates to:
  /// **'hors ligne'**
  String get playOffline;

  /// No description provided for @resultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résultats'**
  String get resultTitle;

  /// No description provided for @resultWinner.
  ///
  /// In fr, this message translates to:
  /// **'{name} gagne !'**
  String resultWinner(String name);

  /// No description provided for @resultYouWin.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez gagné !'**
  String get resultYouWin;

  /// No description provided for @resultDraw.
  ///
  /// In fr, this message translates to:
  /// **'Égalité'**
  String get resultDraw;

  /// No description provided for @resultRank.
  ///
  /// In fr, this message translates to:
  /// **'{rank}ᵉ'**
  String resultRank(int rank);

  /// No description provided for @resultFirst.
  ///
  /// In fr, this message translates to:
  /// **'1ᵉʳ'**
  String get resultFirst;

  /// No description provided for @resultAbandon.
  ///
  /// In fr, this message translates to:
  /// **'Match arrêté : un camp a quitté la partie.'**
  String get resultAbandon;

  /// No description provided for @resultIdle.
  ///
  /// In fr, this message translates to:
  /// **'Match clos faute d’activité.'**
  String get resultIdle;

  /// No description provided for @resultTiebreak.
  ///
  /// In fr, this message translates to:
  /// **'Départagé par une question décisive.'**
  String get resultTiebreak;

  /// No description provided for @resultTiebreakRule.
  ///
  /// In fr, this message translates to:
  /// **'Égalité parfaite : départagé au règlement (moins d’erreurs, puis rapidité).'**
  String get resultTiebreakRule;

  /// No description provided for @resultReview.
  ///
  /// In fr, this message translates to:
  /// **'Revoir les questions'**
  String get resultReview;

  /// No description provided for @resultRematch.
  ///
  /// In fr, this message translates to:
  /// **'Revanche'**
  String get resultRematch;

  /// No description provided for @resultRematchSent.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau match créé : les autres joueurs reçoivent le code.'**
  String get resultRematchSent;

  /// No description provided for @resultBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get resultBack;

  /// No description provided for @resultReadPassage.
  ///
  /// In fr, this message translates to:
  /// **'Lire le passage'**
  String get resultReadPassage;

  /// No description provided for @projectionCodePrompt.
  ///
  /// In fr, this message translates to:
  /// **'Code du match ou du tournoi'**
  String get projectionCodePrompt;

  /// No description provided for @projectionCast.
  ///
  /// In fr, this message translates to:
  /// **'Diffuser sur un écran'**
  String get projectionCast;

  /// No description provided for @projectionHere.
  ///
  /// In fr, this message translates to:
  /// **'Sur cet appareil'**
  String get projectionHere;

  /// No description provided for @projectionHereHint.
  ///
  /// In fr, this message translates to:
  /// **'Plein écran, à relier au vidéoprojecteur ou à la télévision (câble, partage d’écran).'**
  String get projectionHereHint;

  /// No description provided for @projectionOther.
  ///
  /// In fr, this message translates to:
  /// **'Sur une télévision ou un ordinateur'**
  String get projectionOther;

  /// No description provided for @projectionOtherHint.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez ce lien dans son navigateur, sans compte :'**
  String get projectionOtherHint;

  /// No description provided for @projectionOtherApp.
  ///
  /// In fr, this message translates to:
  /// **'Ou, dans l’application : Jouer en ligne → Écran de projection, code {code}.'**
  String projectionOtherApp(String code);

  /// No description provided for @projectionTourOpen.
  ///
  /// In fr, this message translates to:
  /// **'Inscriptions ouvertes — code {code}'**
  String projectionTourOpen(String code);

  /// No description provided for @projectionTourScan.
  ///
  /// In fr, this message translates to:
  /// **'Scannez pour vous inscrire'**
  String get projectionTourScan;

  /// No description provided for @projectionLiveDuels.
  ///
  /// In fr, this message translates to:
  /// **'Duels en cours — touchez-en un pour l’afficher en grand'**
  String get projectionLiveDuels;

  /// No description provided for @projectionNoLive.
  ///
  /// In fr, this message translates to:
  /// **'Aucun duel en cours pour l’instant.'**
  String get projectionNoLive;

  /// No description provided for @projectionFollowing.
  ///
  /// In fr, this message translates to:
  /// **'{tournament} · {stage}'**
  String projectionFollowing(String tournament, String stage);

  /// No description provided for @projectionShow.
  ///
  /// In fr, this message translates to:
  /// **'Afficher'**
  String get projectionShow;

  /// No description provided for @projectionWaiting.
  ///
  /// In fr, this message translates to:
  /// **'En attente des joueurs — code {code}'**
  String projectionWaiting(String code);

  /// No description provided for @eventInvitation.
  ///
  /// In fr, this message translates to:
  /// **'{captain} vous invite dans l’équipe « {team} »'**
  String eventInvitation(String captain, String team);

  /// No description provided for @eventRequest.
  ///
  /// In fr, this message translates to:
  /// **'{pseudo} demande à entrer dans votre équipe'**
  String eventRequest(String pseudo);

  /// No description provided for @eventDuelReady.
  ///
  /// In fr, this message translates to:
  /// **'Tournoi : votre duel vous attend !'**
  String get eventDuelReady;

  /// No description provided for @eventRematch.
  ///
  /// In fr, this message translates to:
  /// **'Revanche proposée : code {code}'**
  String eventRematch(String code);

  /// No description provided for @eventSee.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get eventSee;

  /// No description provided for @errNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion Internet.'**
  String get errNetwork;

  /// No description provided for @errServer.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur ne répond pas correctement. Réessayez plus tard.'**
  String get errServer;

  /// No description provided for @errHandTaken.
  ///
  /// In fr, this message translates to:
  /// **'Trop tard : un autre joueur a pris la main.'**
  String get errHandTaken;

  /// No description provided for @errLocked.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne pouvez plus répondre à cette question.'**
  String get errLocked;

  /// No description provided for @errTooLate.
  ///
  /// In fr, this message translates to:
  /// **'Le temps est écoulé.'**
  String get errTooLate;

  /// No description provided for @errNoHand.
  ///
  /// In fr, this message translates to:
  /// **'Vous n’avez plus la main.'**
  String get errNoHand;

  /// No description provided for @errFull.
  ///
  /// In fr, this message translates to:
  /// **'C’est complet.'**
  String get errFull;

  /// No description provided for @errServerBusy.
  ///
  /// In fr, this message translates to:
  /// **'Trop de parties en cours en ce moment. Réessayez dans quelques minutes.'**
  String get errServerBusy;

  /// No description provided for @errUnknownCode.
  ///
  /// In fr, this message translates to:
  /// **'Aucun match ni tournoi avec ce code.'**
  String get errUnknownCode;

  /// No description provided for @errBadCode.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect ou expiré.'**
  String get errBadCode;

  /// No description provided for @errBanned.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte joueur est suspendu.'**
  String get errBanned;

  /// No description provided for @errRateLimited.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessayez dans quelques minutes.'**
  String get errRateLimited;

  /// No description provided for @scanQr.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le QR code'**
  String get scanQr;

  /// No description provided for @scanHint.
  ///
  /// In fr, this message translates to:
  /// **'Visez le QR code affiché dans la salle d’attente du match ou du tournoi.'**
  String get scanHint;

  /// No description provided for @scanNotAGame.
  ///
  /// In fr, this message translates to:
  /// **'Ce QR code n’est pas celui d’une partie de Quiz Biblique.'**
  String get scanNotAGame;

  /// No description provided for @scanTorch.
  ///
  /// In fr, this message translates to:
  /// **'Lampe'**
  String get scanTorch;

  /// No description provided for @scanFromImage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une image'**
  String get scanFromImage;

  /// No description provided for @scanNoQrInImage.
  ///
  /// In fr, this message translates to:
  /// **'Aucun QR code de partie dans cette image.'**
  String get scanNoQrInImage;

  /// No description provided for @scanTypeCode.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le code'**
  String get scanTypeCode;

  /// No description provided for @scanCameraDenied.
  ///
  /// In fr, this message translates to:
  /// **'L’accès à la caméra a été refusé. Autorisez-le dans les réglages du téléphone, ou saisissez le code.'**
  String get scanCameraDenied;

  /// No description provided for @scanCameraUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'La caméra n’est pas disponible. Saisissez le code de la partie.'**
  String get scanCameraUnavailable;

  /// No description provided for @tourCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau tournoi'**
  String get tourCreateTitle;

  /// No description provided for @tourName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du tournoi'**
  String get tourName;

  /// No description provided for @tourNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Par ex. : Tournoi des jeunes — Évangile de Jean'**
  String get tourNameHint;

  /// No description provided for @tourNameTooShort.
  ///
  /// In fr, this message translates to:
  /// **'3 caractères au moins'**
  String get tourNameTooShort;

  /// No description provided for @tourFormat.
  ///
  /// In fr, this message translates to:
  /// **'Formule'**
  String get tourFormat;

  /// No description provided for @tourModeSolo.
  ///
  /// In fr, this message translates to:
  /// **'Entre joueurs'**
  String get tourModeSolo;

  /// No description provided for @tourModeTeam.
  ///
  /// In fr, this message translates to:
  /// **'Entre équipes'**
  String get tourModeTeam;

  /// No description provided for @tourModeSoloHint.
  ///
  /// In fr, this message translates to:
  /// **'Chaque joueur s’inscrit seul ; les duels opposent deux joueurs.'**
  String get tourModeSoloHint;

  /// No description provided for @tourModeTeamHint.
  ///
  /// In fr, this message translates to:
  /// **'Les joueurs forment des équipes ; les duels opposent deux équipes.'**
  String get tourModeTeamHint;

  /// No description provided for @tourBible.
  ///
  /// In fr, this message translates to:
  /// **'Bible du tournoi'**
  String get tourBible;

  /// No description provided for @tourBibleFr.
  ///
  /// In fr, this message translates to:
  /// **'Louis Segond 1910'**
  String get tourBibleFr;

  /// No description provided for @tourBibleEn.
  ///
  /// In fr, this message translates to:
  /// **'King James'**
  String get tourBibleEn;

  /// No description provided for @tourEntriesRange.
  ///
  /// In fr, this message translates to:
  /// **'Participants : de {min} à {max}'**
  String tourEntriesRange(int min, int max);

  /// No description provided for @tourEntriesTeamHint.
  ///
  /// In fr, this message translates to:
  /// **'Une équipe compte pour un participant.'**
  String get tourEntriesTeamHint;

  /// No description provided for @tourQuestionsPerDuel.
  ///
  /// In fr, this message translates to:
  /// **'Questions par duel : {n}'**
  String tourQuestionsPerDuel(int n);

  /// No description provided for @tourForfeitDelay.
  ///
  /// In fr, this message translates to:
  /// **'Délai pour confirmer « Prêt »'**
  String get tourForfeitDelay;

  /// No description provided for @tourForfeitHint.
  ///
  /// In fr, this message translates to:
  /// **'Quand un duel s’ouvre, chaque camp a ce délai pour se déclarer prêt. Sinon, il perd par forfait.'**
  String get tourForfeitHint;

  /// No description provided for @tourMinutesValue.
  ///
  /// In fr, this message translates to:
  /// **'{minutes, plural, =0{0 minute} =1{1 minute} other{{minutes} minutes}}'**
  String tourMinutesValue(int minutes);

  /// No description provided for @tourHoursValue.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =0{0 heure} =1{1 heure} other{{n} heures}}'**
  String tourHoursValue(int n);

  /// No description provided for @tourPublic.
  ///
  /// In fr, this message translates to:
  /// **'Visible dans les tournois ouverts'**
  String get tourPublic;

  /// No description provided for @tourPublicHint.
  ///
  /// In fr, this message translates to:
  /// **'Sinon, seuls ceux qui ont le code peuvent s’inscrire.'**
  String get tourPublicHint;

  /// No description provided for @tourPlay.
  ///
  /// In fr, this message translates to:
  /// **'Je joue aussi'**
  String get tourPlay;

  /// No description provided for @tourPlaySoloHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes inscrit d’office. Sinon, vous organisez seulement.'**
  String get tourPlaySoloHint;

  /// No description provided for @tourPlayTeamHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous créez votre équipe et en êtes le capitaine.'**
  String get tourPlayTeamHint;

  /// No description provided for @tourNeedPassage.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un passage.'**
  String get tourNeedPassage;

  /// No description provided for @tourCreateSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Créer le tournoi'**
  String get tourCreateSubmit;

  /// No description provided for @tourTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tournoi'**
  String get tourTitle;

  /// No description provided for @tourCode.
  ///
  /// In fr, this message translates to:
  /// **'Code du tournoi'**
  String get tourCode;

  /// No description provided for @tourShareText.
  ///
  /// In fr, this message translates to:
  /// **'Inscris-toi au tournoi « {name} » de Quiz Biblique ({passages}) ! Code : {code}'**
  String tourShareText(String name, String passages, String code);

  /// No description provided for @tourStateRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Inscriptions ouvertes'**
  String get tourStateRegistration;

  /// No description provided for @tourStateRunning.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get tourStateRunning;

  /// No description provided for @tourStateFinished.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get tourStateFinished;

  /// No description provided for @tourStateCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get tourStateCancelled;

  /// No description provided for @tourOrganizer.
  ///
  /// In fr, this message translates to:
  /// **'Organisateur'**
  String get tourOrganizer;

  /// No description provided for @tourOrganizedBy.
  ///
  /// In fr, this message translates to:
  /// **'Organisé par {name}'**
  String tourOrganizedBy(String name);

  /// No description provided for @tourRules.
  ///
  /// In fr, this message translates to:
  /// **'Règlement'**
  String get tourRules;

  /// No description provided for @tourRulesDuel.
  ///
  /// In fr, this message translates to:
  /// **'{n} questions par duel · {seconds} s par question'**
  String tourRulesDuel(int n, int seconds);

  /// No description provided for @tourRulesHand.
  ///
  /// In fr, this message translates to:
  /// **'Après avoir pris la main : {seconds} s pour répondre'**
  String tourRulesHand(int seconds);

  /// No description provided for @tourRulesForfeit.
  ///
  /// In fr, this message translates to:
  /// **'« Prêt » à confirmer dans les {minutes} min, sinon forfait'**
  String tourRulesForfeit(int minutes);

  /// No description provided for @tourRulesEntries.
  ///
  /// In fr, this message translates to:
  /// **'De {min} à {max} participants'**
  String tourRulesEntries(int min, int max);

  /// No description provided for @tourRulesElimination.
  ///
  /// In fr, this message translates to:
  /// **'Élimination directe : le perdant de chaque duel est éliminé.'**
  String get tourRulesElimination;

  /// No description provided for @tourPlayers.
  ///
  /// In fr, this message translates to:
  /// **'Joueurs inscrits : {count}/{max}'**
  String tourPlayers(int count, int max);

  /// No description provided for @tourTeams.
  ///
  /// In fr, this message translates to:
  /// **'Équipes inscrites : {count}/{max}'**
  String tourTeams(int count, int max);

  /// No description provided for @tourNoEntries.
  ///
  /// In fr, this message translates to:
  /// **'Personne n’est encore inscrit. Partagez le code !'**
  String get tourNoEntries;

  /// No description provided for @tourYou.
  ///
  /// In fr, this message translates to:
  /// **'vous'**
  String get tourYou;

  /// No description provided for @tourRegister.
  ///
  /// In fr, this message translates to:
  /// **'M’inscrire'**
  String get tourRegister;

  /// No description provided for @tourUnregister.
  ///
  /// In fr, this message translates to:
  /// **'Me désinscrire'**
  String get tourUnregister;

  /// No description provided for @tourUnregisterConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Vous désinscrire de ce tournoi ?'**
  String get tourUnregisterConfirm;

  /// No description provided for @tourRegistered.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes inscrit. Le tournoi commencera quand l’organisateur le lancera.'**
  String get tourRegistered;

  /// No description provided for @tourFull.
  ///
  /// In fr, this message translates to:
  /// **'Le tournoi est complet.'**
  String get tourFull;

  /// No description provided for @tourTeamHint.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre équipe et invitez vos coéquipiers, ou demandez à entrer dans une équipe ci-dessous.'**
  String get tourTeamHint;

  /// No description provided for @tourTeamIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'Équipe incomplète : il faut {min} joueurs au moins, sinon elle ne sera pas retenue au lancement.'**
  String tourTeamIncomplete(int min);

  /// No description provided for @tourOrganize.
  ///
  /// In fr, this message translates to:
  /// **'Organisation'**
  String get tourOrganize;

  /// No description provided for @tourStart.
  ///
  /// In fr, this message translates to:
  /// **'Lancer le tournoi'**
  String get tourStart;

  /// No description provided for @tourStartConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Lancer le tournoi ?'**
  String get tourStartConfirm;

  /// No description provided for @tourStartBody.
  ///
  /// In fr, this message translates to:
  /// **'Les inscriptions seront closes et le tableau tiré au sort.'**
  String get tourStartBody;

  /// No description provided for @tourStartBodyTeam.
  ///
  /// In fr, this message translates to:
  /// **'Les inscriptions seront closes et le tableau tiré au sort. Les équipes de moins de {min} joueurs ne seront pas retenues.'**
  String tourStartBodyTeam(int min);

  /// No description provided for @tourNeedEntries.
  ///
  /// In fr, this message translates to:
  /// **'Il faut au moins {min} participants pour lancer (inscrits : {count}).'**
  String tourNeedEntries(int min, int count);

  /// No description provided for @tourCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le tournoi'**
  String get tourCancel;

  /// No description provided for @tourCancelConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Annuler ce tournoi ?'**
  String get tourCancelConfirm;

  /// No description provided for @tourCancelBody.
  ///
  /// In fr, this message translates to:
  /// **'Tous les participants seront prévenus. C’est définitif.'**
  String get tourCancelBody;

  /// No description provided for @tourRoundPassages.
  ///
  /// In fr, this message translates to:
  /// **'Passages par tour'**
  String get tourRoundPassages;

  /// No description provided for @tourRoundPassagesHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez choisir d’autres passages pour un tour, tant que ses duels n’ont pas commencé. Sans choix, les passages du tournoi s’appliquent.'**
  String get tourRoundPassagesHint;

  /// No description provided for @tourRoundDefault.
  ///
  /// In fr, this message translates to:
  /// **'Passages du tournoi'**
  String get tourRoundDefault;

  /// No description provided for @tourRoundStarted.
  ///
  /// In fr, this message translates to:
  /// **'Ce tour a commencé'**
  String get tourRoundStarted;

  /// No description provided for @tourRoundReset.
  ///
  /// In fr, this message translates to:
  /// **'Revenir aux passages du tournoi'**
  String get tourRoundReset;

  /// No description provided for @tourSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get tourSave;

  /// No description provided for @tourSaved.
  ///
  /// In fr, this message translates to:
  /// **'Passages enregistrés'**
  String get tourSaved;

  /// No description provided for @tourRound.
  ///
  /// In fr, this message translates to:
  /// **'Tour {round}'**
  String tourRound(int round);

  /// No description provided for @tourFinal.
  ///
  /// In fr, this message translates to:
  /// **'Finale'**
  String get tourFinal;

  /// No description provided for @tourSemiFinals.
  ///
  /// In fr, this message translates to:
  /// **'Demi-finales'**
  String get tourSemiFinals;

  /// No description provided for @tourQuarterFinals.
  ///
  /// In fr, this message translates to:
  /// **'Quarts de finale'**
  String get tourQuarterFinals;

  /// No description provided for @tourBracket.
  ///
  /// In fr, this message translates to:
  /// **'Tableau'**
  String get tourBracket;

  /// No description provided for @tourYourDuel.
  ///
  /// In fr, this message translates to:
  /// **'Votre duel'**
  String get tourYourDuel;

  /// No description provided for @tourAgainst.
  ///
  /// In fr, this message translates to:
  /// **'Contre {name}'**
  String tourAgainst(String name);

  /// No description provided for @tourForfeitIn.
  ///
  /// In fr, this message translates to:
  /// **'Forfait dans {time}'**
  String tourForfeitIn(String time);

  /// No description provided for @tourDeadlinePassed.
  ///
  /// In fr, this message translates to:
  /// **'Délai écoulé, résultat en cours…'**
  String get tourDeadlinePassed;

  /// No description provided for @tourReady.
  ///
  /// In fr, this message translates to:
  /// **'Prêt !'**
  String get tourReady;

  /// No description provided for @tourReadyHint.
  ///
  /// In fr, this message translates to:
  /// **'Le duel commence dès que les deux camps sont prêts.'**
  String get tourReadyHint;

  /// No description provided for @tourYouReady.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes prêt'**
  String get tourYouReady;

  /// No description provided for @tourTeamReady.
  ///
  /// In fr, this message translates to:
  /// **'Votre équipe est prête'**
  String get tourTeamReady;

  /// No description provided for @tourOpponentReady.
  ///
  /// In fr, this message translates to:
  /// **'{name} est prêt'**
  String tourOpponentReady(String name);

  /// No description provided for @tourOpponentWaiting.
  ///
  /// In fr, this message translates to:
  /// **'{name} n’a pas encore confirmé'**
  String tourOpponentWaiting(String name);

  /// No description provided for @tourJoinDuel.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre le duel'**
  String get tourJoinDuel;

  /// No description provided for @tourDuelPlaying.
  ///
  /// In fr, this message translates to:
  /// **'Votre duel est en cours'**
  String get tourDuelPlaying;

  /// No description provided for @tourWaitingNext.
  ///
  /// In fr, this message translates to:
  /// **'Qualifié ! En attente de votre prochain adversaire.'**
  String get tourWaitingNext;

  /// No description provided for @tourEliminatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes éliminé au tour {round}. Merci d’avoir joué !'**
  String tourEliminatedAt(int round);

  /// No description provided for @tourEliminated.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes éliminé. Merci d’avoir joué !'**
  String get tourEliminated;

  /// No description provided for @tourSpectator.
  ///
  /// In fr, this message translates to:
  /// **'Vous suivez ce tournoi.'**
  String get tourSpectator;

  /// No description provided for @tourAbandon.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner le tournoi'**
  String get tourAbandon;

  /// No description provided for @tourAbandonBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre duel en cours ou à venir sera perdu.'**
  String get tourAbandonBody;

  /// No description provided for @tourAbandonTeamBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous quittez votre équipe ; elle continue sans vous.'**
  String get tourAbandonTeamBody;

  /// No description provided for @tourBye.
  ///
  /// In fr, this message translates to:
  /// **'Exempt'**
  String get tourBye;

  /// No description provided for @tourByeWin.
  ///
  /// In fr, this message translates to:
  /// **'Qualifié d’office'**
  String get tourByeWin;

  /// No description provided for @tourTbd.
  ///
  /// In fr, this message translates to:
  /// **'À déterminer'**
  String get tourTbd;

  /// No description provided for @tourForfeitResult.
  ///
  /// In fr, this message translates to:
  /// **'Forfait'**
  String get tourForfeitResult;

  /// No description provided for @tourDoubleForfeit.
  ///
  /// In fr, this message translates to:
  /// **'Double forfait'**
  String get tourDoubleForfeit;

  /// No description provided for @tourDuelPending.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get tourDuelPending;

  /// No description provided for @tourDuelReadyWait.
  ///
  /// In fr, this message translates to:
  /// **'En attente des joueurs'**
  String get tourDuelReadyWait;

  /// No description provided for @tourDuelLive.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get tourDuelLive;

  /// No description provided for @tourDuelSemantics.
  ///
  /// In fr, this message translates to:
  /// **'{a} contre {b}'**
  String tourDuelSemantics(String a, String b);

  /// No description provided for @tourDuelWinnerSemantics.
  ///
  /// In fr, this message translates to:
  /// **'vainqueur : {name}'**
  String tourDuelWinnerSemantics(String name);

  /// No description provided for @tourEliminatedTag.
  ///
  /// In fr, this message translates to:
  /// **'éliminé'**
  String get tourEliminatedTag;

  /// No description provided for @tourWinner.
  ///
  /// In fr, this message translates to:
  /// **'{name} remporte le tournoi !'**
  String tourWinner(String name);

  /// No description provided for @tourYouWon.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez gagné le tournoi !'**
  String get tourYouWon;

  /// No description provided for @tourNoWinner.
  ///
  /// In fr, this message translates to:
  /// **'Tournoi terminé sans vainqueur.'**
  String get tourNoWinner;

  /// No description provided for @tourCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Ce tournoi a été annulé.'**
  String get tourCancelled;
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
