// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bible Quiz';

  @override
  String get tagline => 'Read and understand the Bible';

  @override
  String get navHome => 'Home';

  @override
  String get navPaths => 'Paths';

  @override
  String get navBible => 'Bible';

  @override
  String get navProgress => 'Progress';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Try again';

  @override
  String get loadError => 'The content could not be loaded.';

  @override
  String get copied => 'Copied';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get addFavorite => 'Save verse';

  @override
  String get removeFavorite => 'Remove from saved verses';

  @override
  String get favoriteAdded => 'Verse saved';

  @override
  String get favoriteRemoved => 'Verse removed';

  @override
  String get undo => 'Undo';

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
      other: '$count verses',
      one: '1 verse',
    );
    return '$_temp0';
  }

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeIntro =>
      'This quiz is a reading companion: it helps you discover what the Bible is about.';

  @override
  String get welcomeStep1 => 'Read a short passage, right in the app.';

  @override
  String get welcomeStep2 =>
      'Answer a few questions to check what you understood.';

  @override
  String get welcomeStep3 =>
      'Every answer is explained and points to the verse.';

  @override
  String get welcomeOffline =>
      'Everything works offline. Texts: Louis Segond 1910 (French) and King James 1769 (English).';

  @override
  String get chooseLanguage => 'Language';

  @override
  String get start => 'Start';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in a row',
      one: '1 day in a row',
    );
    return '$_temp0';
  }

  @override
  String get streakStart => 'Start your streak today';

  @override
  String get streakKeep => 'Read today to keep your streak';

  @override
  String get streakDone => 'Well done, you read today';

  @override
  String get continueTitle => 'Continue';

  @override
  String get startTitle => 'Get started';

  @override
  String get allDone =>
      'You have finished every path. Revisit your favourite lessons or read the Bible freely.';

  @override
  String get lessonStart => 'Read and answer';

  @override
  String get reviewTitle => 'Review';

  @override
  String reviewDue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions to review today',
      one: '1 question to review today',
    );
    return '$_temp0';
  }

  @override
  String get reviewStart => 'Review';

  @override
  String get verseOfDay => 'Verse of the day';

  @override
  String get challengeTitle => 'Which book?';

  @override
  String get challengeSubtitle => 'Find the book each verse comes from.';

  @override
  String get challengeQuestion => 'Which book is this verse from?';

  @override
  String get play => 'Play';

  @override
  String get settings => 'Settings';

  @override
  String get pathsTitle => 'Paths';

  @override
  String lessonsProgress(int done, int total) {
    return '$done / $total lessons';
  }

  @override
  String get booksPathTitle => 'The 66 books';

  @override
  String get booksPathSubtitle =>
      'One page per book: what it is about, who wrote it, and a few questions.';

  @override
  String bestScore(int score, int total) {
    return 'Best score: $score / $total';
  }

  @override
  String get oldTestament => 'Old Testament';

  @override
  String get newTestament => 'New Testament';

  @override
  String get readTitle => 'Read';

  @override
  String get introTitle => 'Before you read';

  @override
  String goToQuestions(int count) {
    return 'I’ve read it: to the questions ($count)';
  }

  @override
  String get showParallel => 'Also show the other translation';

  @override
  String questionOf(int index, int total) {
    return 'Question $index of $total';
  }

  @override
  String get trueLabel => 'True';

  @override
  String get falseLabel => 'False';

  @override
  String get correct => 'Correct!';

  @override
  String get incorrect => 'Not quite';

  @override
  String correctAnswerWas(String answer) {
    return 'The right answer: $answer';
  }

  @override
  String readVerse(String ref) {
    return 'Read $ref';
  }

  @override
  String printedRef(String ref) {
    return 'Printed Segond: $ref';
  }

  @override
  String get printedNoteTitle => 'Verse numbers';

  @override
  String get printedNoteBody =>
      'Verse numbers in the app follow the King James Version, so that French and English share the same references.\n\nMany printed French Segond Bibles number a few passages differently. In the Psalms especially, the psalm’s title often counts as verse 1: Psalm 19:7 in the app is Psalm 19:8 in a printed Segond.\n\nWhen that happens, the app also shows the printed Segond number.';

  @override
  String get printedChapterBanner =>
      'In a printed Segond, the verses of this chapter are numbered differently. Tap a verse to see its printed number.';

  @override
  String get printedMore => 'Learn more';

  @override
  String updateAvailable(String version) {
    return 'Version $version available';
  }

  @override
  String updateRequired(String version) {
    return 'Update required: version $version';
  }

  @override
  String get updateRequiredHint =>
      'This version is no longer supported: install the new one to continue.';

  @override
  String get updateDownload => 'Download';

  @override
  String get updateLater => 'Later';

  @override
  String get webInstallTitle => 'Install the Android app';

  @override
  String get webInstallBody =>
      'Smoother every day, and your data no longer depends on the browser.';

  @override
  String get webInstallAction => 'Install';

  @override
  String get homeScreenTitle => 'Add the app to your Home Screen';

  @override
  String get homeScreenBody =>
      'Tap Share (the square with an arrow), then “Add to Home Screen”. The app will open full screen and your data will be kept more reliably.';

  @override
  String get homeScreenDismiss => 'Got it';

  @override
  String get navNotes => 'Notes';

  @override
  String get notesTitle => 'Sermon notes';

  @override
  String get notesEmptyTitle => 'No notes yet';

  @override
  String get notesEmptyBody =>
      'During a sermon, write down what you take away and link the passages that were read. Your notes stay on your phone.';

  @override
  String get notesNew => 'New note';

  @override
  String get notesSearch => 'Search my notes';

  @override
  String get notesNoMatch => 'No note matches.';

  @override
  String get noteUntitled => 'Untitled';

  @override
  String get noteTitleHint => 'Sermon title or theme';

  @override
  String get notePreacherHint => 'Preacher';

  @override
  String get notePlaceHint => 'Place, church';

  @override
  String get noteDateTooltip => 'Day of the sermon';

  @override
  String get notePassages => 'Passages';

  @override
  String get noteAddPassage => 'Add a passage';

  @override
  String get noteBody => 'Notes';

  @override
  String get noteBodyHint =>
      'What you take away… References you type (John 3:16, Ps 23) are detected.';

  @override
  String get noteFoundRefs => 'Found in your notes: tap to add';

  @override
  String get noteReadPassages => 'Read the passages';

  @override
  String get noteDelete => 'Delete note';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get noteAutosave => 'Saved automatically';

  @override
  String get notePassageRemoved => 'Passage removed';

  @override
  String get notePassageAdded => 'Passage added';

  @override
  String get noteShareFooter => 'Notes taken with Bible Quiz';

  @override
  String get keepScreenOnSetting => 'Keep the screen on';

  @override
  String get keepScreenOnHint =>
      'While a sermon note is open, the phone does not lock.';

  @override
  String get shareImage => 'Image to share';

  @override
  String get shareImageTitle => 'Verse image';

  @override
  String get shareImageAction => 'Share the image';

  @override
  String get imageDark => 'Dark';

  @override
  String get imageLight => 'Light';

  @override
  String get shareImageFailed => 'The image could not be created.';

  @override
  String get shareImageLong =>
      'Long passage: only the beginning fits on the image.';

  @override
  String get backupReminderNever =>
      'Your notes are not backed up yet. A backup lets you find them again if you change phones.';

  @override
  String backupReminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'Your notes were last backed up $_temp0 ago. Consider making a new backup.';
  }

  @override
  String get backupNow => 'Back up';

  @override
  String get later => 'Later';

  @override
  String get shareWhatsApp => 'WhatsApp';

  @override
  String get shareOther => 'Another app (email, SMS…)';

  @override
  String get copyText => 'Copy the text';

  @override
  String get whatsappFailed =>
      'WhatsApp could not be opened: choose another app.';

  @override
  String get noteQuiz => 'Test these passages';

  @override
  String get noteQuizTooFew => 'These passages are too short for a quiz.';

  @override
  String get addPassageHint => 'E.g. John 3:16-18, Ps 23, 1 Cor 13';

  @override
  String get addPassageInvalid =>
      'Reference not recognised. Write the book, chapter, then verses: John 3:16-18.';

  @override
  String get addPassageAdd => 'Add';

  @override
  String get addPassageNumbering =>
      'This passage is numbered differently in some Bibles. Where do these numbers come from?';

  @override
  String get addPassagePrinted => 'My printed Bible (Segond)';

  @override
  String get addPassageApp => 'The app';

  @override
  String get addToNote => 'Add to a note';

  @override
  String addToNoteTitle(String ref) {
    return 'Add $ref to…';
  }

  @override
  String addedToNote(String title) {
    return 'Added to “$title”';
  }

  @override
  String alreadyInNote(String title) {
    return 'Already in “$title”';
  }

  @override
  String get open => 'Open';

  @override
  String get inYourNotes => 'In your notes';

  @override
  String get notesBackup => 'Back up my notes';

  @override
  String get notesRestore => 'Restore a backup';

  @override
  String get notesBackupHint =>
      'Your notes stay on this phone. Back them up from time to time (Drive, email…) to find them on another device.';

  @override
  String get notesBackupEmpty => 'No notes to back up.';

  @override
  String notesRestoreAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new notes',
      one: '1 new note',
      zero: 'no new notes',
    );
    return '$_temp0';
  }

  @override
  String notesRestoreUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count updates',
      one: '1 update',
      zero: 'no updates',
    );
    return '$_temp0';
  }

  @override
  String notesRestoreDone(String result) {
    return 'Restore complete: $result.';
  }

  @override
  String get notesRestoreInvalid =>
      'This file is not a Bible Quiz notes backup.';

  @override
  String get notesRestoreNewer =>
      'This backup comes from a newer version: update the app.';

  @override
  String get notesRestoreError => 'The file could not be read.';

  @override
  String get pathReviewTitle => 'Path review';

  @override
  String pathReviewSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0 from every lesson in the path';
  }

  @override
  String get pathReviewHint => 'Best once you have finished the lessons';

  @override
  String get pathReviewAction => 'Take the path review';

  @override
  String get nextPath => 'Next path';

  @override
  String get next => 'Next';

  @override
  String get seeResult => 'See the result';

  @override
  String get quitTitle => 'Leave?';

  @override
  String get quitBody => 'Your answers in this round will not be saved.';

  @override
  String get quit => 'Leave';

  @override
  String get stay => 'Stay';

  @override
  String resultScore(int score, int total) {
    return '$score / $total';
  }

  @override
  String get resultPerfect => 'Perfect! You understood everything.';

  @override
  String get resultGood => 'Very good! Just one or two points to review.';

  @override
  String get resultFair =>
      'A good start. Reading the passage again helps a lot.';

  @override
  String get resultLow => 'No worries: read the passage again, then try again.';

  @override
  String get takeawayTitle => 'Key point';

  @override
  String get keyVerseTitle => 'Key verse';

  @override
  String get missedTitle => 'To review';

  @override
  String get missedHint => 'These questions will come back in your reviews.';

  @override
  String get rereadPassage => 'Read the passage again';

  @override
  String get retryQuiz => 'Retake the questions';

  @override
  String get nextLesson => 'Next lesson';

  @override
  String get finish => 'Finish';

  @override
  String get reviewEmpty =>
      'Nothing to review today. Missed questions come back here the next day.';

  @override
  String get bookAuthor => 'Author';

  @override
  String get bookPeriod => 'Period';

  @override
  String get bookThemes => 'Themes';

  @override
  String bookChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters',
      one: '1 chapter',
    );
    return '$_temp0';
  }

  @override
  String get readBook => 'Read the book';

  @override
  String bookQuiz(int count) {
    return 'Quiz ($count)';
  }

  @override
  String get bookInfo => 'About this book';

  @override
  String get chooseBook => 'Choose a book';

  @override
  String chooseChapter(String book) {
    return '$book: choose a chapter';
  }

  @override
  String chapterTitle(String book, int chapter) {
    return '$book $chapter';
  }

  @override
  String get previousChapter => 'Previous';

  @override
  String get nextChapter => 'Next';

  @override
  String get textSize => 'Text size';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Words, \"exact phrase\" or reference';

  @override
  String get searchClear => 'Clear';

  @override
  String searchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses',
      one: '1 verse',
      zero: 'No verses',
    );
    return '$_temp0';
  }

  @override
  String searchResultsFiltered(int shown, int total) {
    return '$shown of $total verses';
  }

  @override
  String get searchNoResult =>
      'No verse contains all these words. Try fewer words, or turn off “Whole words”.';

  @override
  String get searchAll => 'Whole Bible';

  @override
  String get searchOld => 'Old Testament';

  @override
  String get searchNew => 'New Testament';

  @override
  String get searchBook => 'Book…';

  @override
  String get searchAllBooks => 'All books';

  @override
  String get searchWholeWords => 'Whole words';

  @override
  String searchIn(String name) {
    return 'Search in: $name';
  }

  @override
  String searchGoTo(String ref) {
    return 'Go to $ref';
  }

  @override
  String get searchRecent => 'Recent searches';

  @override
  String get searchClearRecent => 'Clear all';

  @override
  String get searchTipsTitle => 'How to search';

  @override
  String get searchTipWords =>
      'Several words: verses containing all of them, in any order.';

  @override
  String get searchTipPhrase =>
      'In quotes: the exact phrase, with or without punctuation.';

  @override
  String get searchTipExclude => 'A dash before a word excludes it.';

  @override
  String get searchTipAccents =>
      'Accents and capitals do not matter; a word also finds words starting with it (forgive → forgiveness).';

  @override
  String get searchTipRef => 'A reference opens the passage directly.';

  @override
  String get searchExampleWords => 'shepherd sheep';

  @override
  String get searchExamplePhrase => '\"let there be light\"';

  @override
  String get searchExampleExclude => 'shepherd -wolf';

  @override
  String get searchExampleRef => 'John 3:16';

  @override
  String get searchPreparing => 'Preparing search…';

  @override
  String searchMoreResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more',
      one: '1 more',
    );
    return 'Refine the search to see the other verses ($_temp0).';
  }

  @override
  String get progressTitle => 'Your progress';

  @override
  String get statLessons => 'Lessons completed';

  @override
  String get statAnswered => 'Answers given';

  @override
  String get statAccuracy => 'Correct answers';

  @override
  String get statMastered => 'Questions mastered';

  @override
  String get statStreak => 'Current streak';

  @override
  String get statBestStreak => 'Best streak';

  @override
  String daysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get favoritesTitle => 'Saved verses';

  @override
  String get favoritesEmpty => 'Tap a verse in the Bible to save it.';

  @override
  String get pathsProgressTitle => 'By path';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Phone language';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSystem => 'Phone setting';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get parallelSetting => 'Bilingual reading';

  @override
  String get parallelSettingHint =>
      'Shows the other translation (Segond or KJV) under each verse.';

  @override
  String get textSizePreview =>
      'In the beginning God created the heaven and the earth.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutTexts =>
      'Bible texts: Louis Segond 1910 and King James Version 1769, both in the public domain.';

  @override
  String get aboutContent =>
      'The questions stick to what the text says, without taking sides between churches. Each answer points to the verse that supports it.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get resetProgress => 'Erase my progress';

  @override
  String get resetProgressBody =>
      'Completed lessons, reviews, streak and chapters read will be erased. Your saved verses and settings are kept. This cannot be undone.';

  @override
  String get resetDone => 'Progress erased';

  @override
  String get readingQuizTitle => 'Quiz on my reading';

  @override
  String get readingQuizSubtitle => 'A quiz on the book or books you have read';

  @override
  String get readingQuizIntro =>
      'Choose one or more books. Reviewed questions come first; others, drawn from the text itself, complete the quiz.';

  @override
  String get readingQuizBooks => 'Books in the quiz';

  @override
  String get selectMyReading => 'My reading';

  @override
  String get selectNone => 'None';

  @override
  String get genreLaw => 'Pentateuch';

  @override
  String get genreHistory => 'Historical books';

  @override
  String get genrePoetry => 'Poetry';

  @override
  String get genreProphets => 'Prophets';

  @override
  String get genreGospels => 'Gospels';

  @override
  String get genreActs => 'Acts';

  @override
  String get genreEpistles => 'Epistles';

  @override
  String get genreApocalyptic => 'Revelation';

  @override
  String chaptersReadOf(int done, int total) {
    return '$done / $total chapters read';
  }

  @override
  String get scopeRead => 'Chapters read';

  @override
  String get scopeWhole => 'Whole books';

  @override
  String get scopeReadHint =>
      'Questions cover only the chapters you have read.';

  @override
  String get scopeWholeHint => 'Questions cover the whole of the chosen books.';

  @override
  String get questionCountLabel => 'Number of questions';

  @override
  String startReadingQuiz(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Start · $count books',
      one: 'Start · 1 book',
    );
    return '$_temp0';
  }

  @override
  String get readingQuizPickOne => 'Choose at least one book.';

  @override
  String get readingQuizTooFew =>
      'Not enough material for a quiz: add chapters, or choose “Whole books”.';

  @override
  String readingQuizNamed(String name) {
    return 'Quiz: $name';
  }

  @override
  String readingQuizBooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '1 book',
    );
    return '$_temp0';
  }

  @override
  String get fromTheText => 'From the text';

  @override
  String get aiUnreviewed => 'Written by AI · not reviewed';

  @override
  String get aiReviewed => 'Written by AI · reviewed';

  @override
  String get aiUnreviewedHint =>
      'This question was written by an AI and checked automatically against the text, but nobody has reviewed it yet. The verse is what counts.';

  @override
  String get aiReport => 'Report this question';

  @override
  String get aiReportTitle => 'What is wrong?';

  @override
  String get aiReportWrong => 'The given answer is wrong';

  @override
  String get aiReportSeveral => 'More than one answer is right';

  @override
  String get aiReportUnclear => 'The question is unclear';

  @override
  String get aiReportDoctrine => 'It takes a doctrinal side';

  @override
  String get aiReportOther => 'Something else';

  @override
  String get aiReportNote => 'Details (optional)';

  @override
  String get aiReportSend => 'Send';

  @override
  String get aiReportThanks => 'Thank you: the question will be reviewed.';

  @override
  String get aiReportWithdrawn => 'Thank you: the question has been withdrawn.';

  @override
  String get aiReportOffline =>
      'Cannot report without a connection. Try again later.';

  @override
  String get aiCardTitle => 'Comprehension questions';

  @override
  String get aiCardIntro =>
      'For chapters without reviewed questions, the quiz fills in with missing-word questions. An AI can write real comprehension questions instead, checked against the text.';

  @override
  String get aiCardPrivacy =>
      'A connection is needed. The app sends the server the chosen chapters and an anonymous identifier of this installation, nothing else. Questions received then stay available offline.';

  @override
  String get aiEnable => 'Turn on';

  @override
  String get aiSetting => 'Questions written by AI';

  @override
  String get aiSettingHint =>
      'Quiz on my reading: real comprehension questions for the chosen chapters. Needs a connection; sends the chapters and an anonymous identifier.';

  @override
  String get aiChecking => 'Looking for available questions…';

  @override
  String get aiOffline =>
      'Offline: the quiz uses the questions already received.';

  @override
  String get aiUnavailable =>
      'Questions written by AI are not available at the moment.';

  @override
  String aiCoverage(int done, int total) {
    return 'Chapters with comprehension questions: $done of $total.';
  }

  @override
  String aiPreparing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters being prepared',
      one: '1 chapter being prepared',
    );
    return '$_temp0 (one to two minutes each). You can start the quiz: they will be used next time.';
  }

  @override
  String aiAsk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ask for $count chapters',
      one: 'Ask for 1 chapter',
    );
    return '$_temp0';
  }

  @override
  String aiQuotaLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You can still ask for $count chapters today.',
      one: 'You can still ask for 1 chapter today.',
      zero:
          'You have asked for all your chapters for today. Come back tomorrow.',
    );
    return '$_temp0';
  }

  @override
  String get aiServerQuota =>
      'The service has reached its limit for today. Come back tomorrow.';

  @override
  String get aiAllCovered => 'All chosen chapters have their questions.';

  @override
  String get aiRequestFailed => 'The request failed. Try again later.';

  @override
  String get markChapterRead => 'Mark as read';

  @override
  String get chapterRead => 'Chapter read';

  @override
  String get markBookRead => 'Mark the whole book as read';

  @override
  String get unmarkBookRead => 'Clear “read” for this book';

  @override
  String get quizOnThisBook => 'Quiz on this book';

  @override
  String chaptersReadTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters read',
      one: '1 chapter read',
      zero: 'No chapter read',
    );
    return '$_temp0';
  }

  @override
  String get testThisChapter => 'Test this chapter';

  @override
  String get chapterQuizTooFew =>
      'This chapter is too short for a quiz. Try a quiz on the whole book.';

  @override
  String get bibleReadingTitle => 'My Bible reading';

  @override
  String bibleReadingTotal(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      done,
      locale: localeName,
      other: '$done chapters read out of $total',
      one: '1 chapter read out of $total',
      zero: 'No chapter read out of $total',
    );
    return '$_temp0';
  }

  @override
  String get bibleReadingHint => 'Tap a book to see its chapters.';

  @override
  String bookReadSemantics(String name, int done, int total) {
    return '$name: $done of $total chapters read';
  }

  @override
  String booksStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books started',
      one: '1 book started',
      zero: 'No book started',
    );
    return '$_temp0';
  }

  @override
  String booksFinished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count finished',
      one: '1 finished',
      zero: 'none finished',
    );
    return '$_temp0';
  }

  @override
  String get onlineTitle => 'Play with others';

  @override
  String get onlineCardSubtitle =>
      'Online matches and tournaments on the passages you choose';

  @override
  String get onlineIntro =>
      'Take on other readers, alone or in a team, on one or more Bible passages. The first to grab the hand answers; a right answer earns 10 points, a wrong one costs 5.';

  @override
  String get onlineOptional =>
      'Online play is optional: the rest of the app works without an account or Internet.';

  @override
  String get onlineBecomePlayer => 'Become a player';

  @override
  String get onlineAccountHint =>
      'You need a phone number (code sent by WhatsApp) and a nickname.';

  @override
  String get onlineCreateMatch => 'Create a match';

  @override
  String get onlineJoin => 'Join';

  @override
  String get onlineJoinTitle => 'Join with a code';

  @override
  String get onlineJoinHint => '6-character code';

  @override
  String get onlineCreateTournament => 'Create a tournament';

  @override
  String get onlineOpenMatches => 'Open matches';

  @override
  String get onlineOpenTournaments => 'Open tournaments';

  @override
  String get onlineNoOpenMatch =>
      'No open match right now. Create one and share its code.';

  @override
  String get onlineMyTournaments => 'My tournaments';

  @override
  String get onlineInvitations => 'Invitations';

  @override
  String get onlineHistory => 'My matches';

  @override
  String get onlineNoHistory => 'Your finished matches will show here.';

  @override
  String get onlineProfile => 'My player profile';

  @override
  String get onlineProjection => 'Projection screen';

  @override
  String get onlineProjectionHint =>
      'Show a match or a tournament on a big screen (projector, TV), no account needed.';

  @override
  String get onlineCurrentMatch => 'You have a match in progress';

  @override
  String onlineCurrentTournament(String name) {
    return 'You are in the “$name” tournament';
  }

  @override
  String get onlineResume => 'Resume';

  @override
  String onlineStats(int played, int won) {
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: '$played matches',
      one: '1 match',
      zero: 'No match',
    );
    String _temp1 = intl.Intl.pluralLogic(
      won,
      locale: localeName,
      other: '$won won',
      one: '1 won',
      zero: 'none won',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get onlineOffline =>
      'Cannot reach the server. Check the Internet and try again.';

  @override
  String onlinePlayers(int players, int max) {
    return '$players/$max players';
  }

  @override
  String onlineBy(String name) {
    return 'by $name';
  }

  @override
  String get onlineModeSolo => 'Individual';

  @override
  String get onlineModeTeam => 'Teams';

  @override
  String get onlineRealtimeOff =>
      'Slow connection: the display may lag a little.';

  @override
  String get signInTitle => 'Become a player';

  @override
  String get signInPhone => 'Your phone number';

  @override
  String get signInCountry => 'Country';

  @override
  String get signInSendCode => 'Get the code on WhatsApp';

  @override
  String signInCodeSent(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get signInCode => 'Code received';

  @override
  String get signInVerify => 'Confirm';

  @override
  String get signInResend => 'Send the code again';

  @override
  String get signInChangeNumber => 'Change number';

  @override
  String get signInPrivacy =>
      'Your number only protects your account. Other players only see your nickname.';

  @override
  String get pseudoTitle => 'Choose your nickname';

  @override
  String get pseudoLabel => 'Nickname';

  @override
  String get pseudoHint => '3 to 20 characters, visible to other players';

  @override
  String get pseudoSave => 'Let’s go';

  @override
  String get profileRename => 'Change nickname';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileDelete => 'Delete my player account';

  @override
  String get profileDeleteConfirm =>
      'Your nickname and history will be erased, and you will leave the current game. Your reading and progress in the app are not affected.';

  @override
  String get profileDeleted => 'Player account deleted';

  @override
  String profileTournamentsWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tournaments won',
      one: '1 tournament won',
      zero: 'No tournament won',
    );
    return '$_temp0';
  }

  @override
  String get report => 'Report this nickname';

  @override
  String get reportReason => 'Why? (optional)';

  @override
  String get reportSent => 'Report sent. Thank you.';

  @override
  String get createMatchTitle => 'New match';

  @override
  String get createPassages => 'Passages';

  @override
  String get createAddPassage => 'Add a passage';

  @override
  String get createNoPassage =>
      'Choose at least one passage for the questions.';

  @override
  String createAvailable(int available) {
    return '$available possible questions on these passages';
  }

  @override
  String get createNotEnough =>
      'Not enough questions: add or widen a passage, or lower the number of questions.';

  @override
  String get createBible => 'Bible for the match';

  @override
  String createQuestions(int n) {
    return 'Questions: $n';
  }

  @override
  String createQuestionTime(int seconds) {
    return 'Time per question: $seconds s';
  }

  @override
  String createHandTime(int seconds) {
    return 'Time to answer after grabbing the hand: $seconds s';
  }

  @override
  String createMaxPlayers(int n) {
    return 'Players at most: $n';
  }

  @override
  String get createPublic => 'Listed in open matches';

  @override
  String get createPublicHint =>
      'Otherwise, only people with the code can join.';

  @override
  String get createSubmit => 'Create the match';

  @override
  String get passagePickerTitle => 'Choose a passage';

  @override
  String get passageBook => 'Book';

  @override
  String get passageFromChapter => 'From chapter';

  @override
  String get passageToChapter => 'to chapter';

  @override
  String get passageVerses => 'Only some verses';

  @override
  String get passageFromVerse => 'From verse';

  @override
  String get passageToVerse => 'to verse';

  @override
  String get passageAdd => 'Add';

  @override
  String get lobbyTitle => 'Waiting room';

  @override
  String get lobbyCode => 'Match code';

  @override
  String get lobbyShareHint =>
      'Other players type this code under Play → Join, or scan the QR code with their camera.';

  @override
  String get lobbyShareWhatsApp => 'Invite via WhatsApp';

  @override
  String lobbyShareText(String passages, String code, String link) {
    return 'Join me for a Bible Quiz match ($passages)! Code: $code\n$link';
  }

  @override
  String get lobbyPlayers => 'Players';

  @override
  String lobbyWaitCreator(String name) {
    return 'Waiting for $name to start…';
  }

  @override
  String get lobbyStart => 'Start the match';

  @override
  String get lobbyNeedPlayers => 'At least 2 players are needed.';

  @override
  String get lobbyLeave => 'Leave';

  @override
  String get lobbyLeaveConfirm => 'Leave this match?';

  @override
  String get lobbyLeaveRunning =>
      'Leaving a match in progress means giving up.';

  @override
  String get lobbyKick => 'Remove from the match';

  @override
  String get lobbyCreator => 'creator';

  @override
  String lobbySettings(int n, int seconds, String hand) {
    return '$n questions · $seconds s per question · hand: $hand s';
  }

  @override
  String get lobbyCancelled => 'This match was cancelled.';

  @override
  String get lobbyNoTeam => 'Without a team';

  @override
  String get lobbyNoTeamHint =>
      'Players without a team do not play: ask to join a team, or create one.';

  @override
  String get teamCreate => 'Create a team';

  @override
  String get teamName => 'Team name';

  @override
  String get teamCaptain => 'captain';

  @override
  String get teamInvite => 'Invite a player';

  @override
  String get teamInviteSearch => 'Player’s nickname';

  @override
  String get teamInviteBusy => 'already playing';

  @override
  String get teamInvited => 'invited';

  @override
  String get teamRequested => 'asks to join';

  @override
  String get teamAccept => 'Accept';

  @override
  String get teamDecline => 'Decline';

  @override
  String get teamRemove => 'Remove';

  @override
  String get teamAskJoin => 'Ask to join';

  @override
  String get teamLeave => 'Leave the team';

  @override
  String get teamRename => 'Rename';

  @override
  String teamMembers(int n) {
    return '$n players';
  }

  @override
  String teamInvitation(String captain, String team) {
    return '$captain invites you to the “$team” team';
  }

  @override
  String teamSizeHint(int min, int max) {
    return '$min to $max players per team.';
  }

  @override
  String get playCountdown => 'Ready?';

  @override
  String playQuestion(int index, int total) {
    return 'Question $index of $total';
  }

  @override
  String get playTiebreak => 'Tiebreaker: the first right answer wins';

  @override
  String get playBuzz => 'I’ll answer!';

  @override
  String get playYourHand => 'Your turn! Pick the answer';

  @override
  String playHandOf(String name) {
    return '$name has the hand';
  }

  @override
  String get playLocked => 'You can no longer answer this question';

  @override
  String get playLockedTeam => 'Your team can no longer answer this question';

  @override
  String get playPaused => 'Timer paused';

  @override
  String get playCorrect => 'Right answer! +10';

  @override
  String get playWrong => 'Wrong answer: −5';

  @override
  String playWonBy(String name) {
    return '$name got it';
  }

  @override
  String get playNobody => 'Nobody got it';

  @override
  String playAnswerWas(String answer) {
    return 'Answer: $answer';
  }

  @override
  String get playTimeout => 'Time is up';

  @override
  String get playFromText => 'From the text';

  @override
  String get playSpectator => 'You are watching this match';

  @override
  String get playScores => 'Scores';

  @override
  String playHandLost(String name) {
    return '$name let the hand go: −5';
  }

  @override
  String playAnsweredWrong(String name) {
    return '$name was wrong: −5';
  }

  @override
  String playPoints(int points) {
    return '$points pts';
  }

  @override
  String get playLeft => 'left';

  @override
  String get playOffline => 'offline';

  @override
  String get resultTitle => 'Results';

  @override
  String resultWinner(String name) {
    return '$name wins!';
  }

  @override
  String get resultYouWin => 'You won!';

  @override
  String get resultDraw => 'Draw';

  @override
  String resultRank(int rank) {
    return '#$rank';
  }

  @override
  String get resultFirst => '#1';

  @override
  String get resultAbandon => 'Match stopped: one side left the game.';

  @override
  String get resultIdle => 'Match closed for lack of activity.';

  @override
  String get resultTiebreak => 'Decided by a tiebreaker.';

  @override
  String get resultTiebreakRule =>
      'Perfect tie: decided by the rules (fewer mistakes, then speed).';

  @override
  String get resultReview => 'Review the questions';

  @override
  String get resultRematch => 'Rematch';

  @override
  String get resultRematchSent =>
      'New match created: the other players get the code.';

  @override
  String get resultBack => 'Back';

  @override
  String get resultReadPassage => 'Read the passage';

  @override
  String get projectionCodePrompt => 'Match or tournament code';

  @override
  String get projectionCast => 'Show on a screen';

  @override
  String get projectionHere => 'On this device';

  @override
  String get projectionHereHint =>
      'Full screen, to connect to the projector or TV (cable, screen sharing).';

  @override
  String get projectionOther => 'On a TV or a computer';

  @override
  String get projectionOtherHint =>
      'Open this link in its browser, no account needed:';

  @override
  String projectionOtherApp(String code) {
    return 'Or, in the app: Play online → Projection screen, code $code.';
  }

  @override
  String projectionTourOpen(String code) {
    return 'Registration open — code $code';
  }

  @override
  String get projectionTourScan => 'Scan to sign up';

  @override
  String get projectionLiveDuels => 'Live duels — tap one to show it full size';

  @override
  String get projectionNoLive => 'No duel in progress right now.';

  @override
  String projectionFollowing(String tournament, String stage) {
    return '$tournament · $stage';
  }

  @override
  String get projectionShow => 'Show';

  @override
  String projectionWaiting(String code) {
    return 'Waiting for players — code $code';
  }

  @override
  String eventInvitation(String captain, String team) {
    return '$captain invites you to the “$team” team';
  }

  @override
  String eventRequest(String pseudo) {
    return '$pseudo asks to join your team';
  }

  @override
  String get eventDuelReady => 'Tournament: your duel is waiting!';

  @override
  String eventRematch(String code) {
    return 'Rematch offered: code $code';
  }

  @override
  String get eventSee => 'See';

  @override
  String get errNetwork => 'No Internet connection.';

  @override
  String get errServer =>
      'The server is not responding properly. Try again later.';

  @override
  String get errHandTaken => 'Too late: another player grabbed the hand.';

  @override
  String get errLocked => 'You can no longer answer this question.';

  @override
  String get errTooLate => 'Time is up.';

  @override
  String get errNoHand => 'You no longer have the hand.';

  @override
  String get errFull => 'It is full.';

  @override
  String get errServerBusy =>
      'Too many games in progress right now. Try again in a few minutes.';

  @override
  String get errUnknownCode => 'No match or tournament with this code.';

  @override
  String get errBadCode => 'Wrong or expired code.';

  @override
  String get errBanned => 'Your player account is suspended.';

  @override
  String get errRateLimited => 'Too many attempts. Try again in a few minutes.';

  @override
  String get scanQr => 'Scan the QR code';

  @override
  String get scanHint =>
      'Point at the QR code shown in the match or tournament waiting room.';

  @override
  String get scanNotAGame => 'This QR code is not a Bible Quiz game.';

  @override
  String get scanTorch => 'Flashlight';

  @override
  String get scanFromImage => 'Choose an image';

  @override
  String get scanNoQrInImage => 'No game QR code in this image.';

  @override
  String get scanTypeCode => 'Type the code';

  @override
  String get scanCameraDenied =>
      'Camera access was denied. Allow it in the phone settings, or type the code.';

  @override
  String get scanCameraUnavailable =>
      'The camera is not available. Type the game code.';

  @override
  String get tourCreateTitle => 'New tournament';

  @override
  String get tourName => 'Tournament name';

  @override
  String get tourNameHint => 'E.g. Youth tournament — Gospel of John';

  @override
  String get tourNameTooShort => 'At least 3 characters';

  @override
  String get tourFormat => 'Format';

  @override
  String get tourModeSolo => 'Players';

  @override
  String get tourModeTeam => 'Teams';

  @override
  String get tourModeSoloHint =>
      'Each player registers alone; duels pit two players against each other.';

  @override
  String get tourModeTeamHint =>
      'Players form teams; duels pit two teams against each other.';

  @override
  String get tourBible => 'Bible for the tournament';

  @override
  String get tourBibleFr => 'Louis Segond 1910';

  @override
  String get tourBibleEn => 'King James';

  @override
  String tourEntriesRange(int min, int max) {
    return 'Participants: $min to $max';
  }

  @override
  String get tourEntriesTeamHint => 'A team counts as one participant.';

  @override
  String tourQuestionsPerDuel(int n) {
    return 'Questions per duel: $n';
  }

  @override
  String get tourForfeitDelay => 'Time to confirm “Ready”';

  @override
  String get tourForfeitHint =>
      'When a duel opens, each side has this long to say it is ready. Otherwise it loses by forfeit.';

  @override
  String tourMinutesValue(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String tourHoursValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get tourPublic => 'Listed in open tournaments';

  @override
  String get tourPublicHint =>
      'Otherwise, only people with the code can register.';

  @override
  String get tourPlay => 'I play too';

  @override
  String get tourPlaySoloHint =>
      'You are registered right away. Otherwise, you only organize.';

  @override
  String get tourPlayTeamHint => 'You create your team and are its captain.';

  @override
  String get tourNeedPassage => 'Choose at least one passage.';

  @override
  String get tourCreateSubmit => 'Create the tournament';

  @override
  String get tourTitle => 'Tournament';

  @override
  String get tourCode => 'Tournament code';

  @override
  String tourShareText(String name, String passages, String code) {
    return 'Sign up for the “$name” Bible Quiz tournament ($passages)! Code: $code';
  }

  @override
  String get tourStateRegistration => 'Registration open';

  @override
  String get tourStateRunning => 'In progress';

  @override
  String get tourStateFinished => 'Finished';

  @override
  String get tourStateCancelled => 'Cancelled';

  @override
  String get tourOrganizer => 'Organizer';

  @override
  String tourOrganizedBy(String name) {
    return 'Organized by $name';
  }

  @override
  String get tourRules => 'Rules';

  @override
  String tourRulesDuel(int n, int seconds) {
    return '$n questions per duel · $seconds s per question';
  }

  @override
  String tourRulesHand(int seconds) {
    return 'After grabbing the hand: $seconds s to answer';
  }

  @override
  String tourRulesForfeit(int minutes) {
    return 'Confirm “Ready” within $minutes min, or forfeit';
  }

  @override
  String tourRulesEntries(int min, int max) {
    return '$min to $max participants';
  }

  @override
  String get tourRulesElimination =>
      'Single elimination: the loser of each duel is out.';

  @override
  String tourPlayers(int count, int max) {
    return 'Registered players: $count/$max';
  }

  @override
  String tourTeams(int count, int max) {
    return 'Registered teams: $count/$max';
  }

  @override
  String get tourNoEntries => 'Nobody has registered yet. Share the code!';

  @override
  String get tourYou => 'you';

  @override
  String get tourRegister => 'Register';

  @override
  String get tourUnregister => 'Withdraw';

  @override
  String get tourUnregisterConfirm => 'Withdraw from this tournament?';

  @override
  String get tourRegistered =>
      'You are registered. The tournament starts when the organizer launches it.';

  @override
  String get tourFull => 'The tournament is full.';

  @override
  String get tourTeamHint =>
      'Create your team and invite teammates, or ask to join a team below.';

  @override
  String tourTeamIncomplete(int min) {
    return 'Incomplete team: it needs at least $min players, or it will be left out at the start.';
  }

  @override
  String get tourOrganize => 'Organization';

  @override
  String get tourStart => 'Start the tournament';

  @override
  String get tourStartConfirm => 'Start the tournament?';

  @override
  String get tourStartBody =>
      'Registration will close and the bracket will be drawn.';

  @override
  String tourStartBodyTeam(int min) {
    return 'Registration will close and the bracket will be drawn. Teams with fewer than $min players will be left out.';
  }

  @override
  String tourNeedEntries(int min, int count) {
    return 'At least $min participants are needed to start (registered: $count).';
  }

  @override
  String get tourCancel => 'Cancel the tournament';

  @override
  String get tourCancelConfirm => 'Cancel this tournament?';

  @override
  String get tourCancelBody =>
      'All participants will be notified. This cannot be undone.';

  @override
  String get tourRoundPassages => 'Passages per round';

  @override
  String get tourRoundPassagesHint =>
      'You can choose other passages for a round, as long as its duels have not started. Otherwise, the tournament passages apply.';

  @override
  String get tourRoundDefault => 'Tournament passages';

  @override
  String get tourRoundStarted => 'This round has started';

  @override
  String get tourRoundReset => 'Back to the tournament passages';

  @override
  String get tourSave => 'Save';

  @override
  String get tourSaved => 'Passages saved';

  @override
  String tourRound(int round) {
    return 'Round $round';
  }

  @override
  String get tourFinal => 'Final';

  @override
  String get tourSemiFinals => 'Semi-finals';

  @override
  String get tourQuarterFinals => 'Quarter-finals';

  @override
  String get tourBracket => 'Bracket';

  @override
  String get tourYourDuel => 'Your duel';

  @override
  String tourAgainst(String name) {
    return 'Against $name';
  }

  @override
  String tourForfeitIn(String time) {
    return 'Forfeit in $time';
  }

  @override
  String get tourDeadlinePassed => 'Time is up, settling the result…';

  @override
  String get tourReady => 'Ready!';

  @override
  String get tourReadyHint =>
      'The duel starts as soon as both sides are ready.';

  @override
  String get tourYouReady => 'You are ready';

  @override
  String get tourTeamReady => 'Your team is ready';

  @override
  String tourOpponentReady(String name) {
    return '$name is ready';
  }

  @override
  String tourOpponentWaiting(String name) {
    return '$name has not confirmed yet';
  }

  @override
  String get tourJoinDuel => 'Join the duel';

  @override
  String get tourDuelPlaying => 'Your duel is in progress';

  @override
  String get tourWaitingNext => 'Through! Waiting for your next opponent.';

  @override
  String tourEliminatedAt(int round) {
    return 'You were knocked out in round $round. Thanks for playing!';
  }

  @override
  String get tourEliminated => 'You are knocked out. Thanks for playing!';

  @override
  String get tourSpectator => 'You are following this tournament.';

  @override
  String get tourAbandon => 'Leave the tournament';

  @override
  String get tourAbandonBody => 'Your current or next duel will be lost.';

  @override
  String get tourAbandonTeamBody =>
      'You leave your team; it carries on without you.';

  @override
  String get tourBye => 'Bye';

  @override
  String get tourByeWin => 'Advances on a bye';

  @override
  String get tourTbd => 'To be decided';

  @override
  String get tourForfeitResult => 'Forfeit';

  @override
  String get tourDoubleForfeit => 'Double forfeit';

  @override
  String get tourDuelPending => 'Upcoming';

  @override
  String get tourDuelReadyWait => 'Waiting for players';

  @override
  String get tourDuelLive => 'Live';

  @override
  String tourDuelSemantics(String a, String b) {
    return '$a versus $b';
  }

  @override
  String tourDuelWinnerSemantics(String name) {
    return 'winner: $name';
  }

  @override
  String get tourEliminatedTag => 'out';

  @override
  String tourWinner(String name) {
    return '$name wins the tournament!';
  }

  @override
  String get tourYouWon => 'You won the tournament!';

  @override
  String get tourNoWinner => 'Tournament ended without a winner.';

  @override
  String get tourCancelled => 'This tournament was cancelled.';
}
