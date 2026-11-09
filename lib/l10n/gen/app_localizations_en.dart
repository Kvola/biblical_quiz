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
}
