#!/usr/bin/env python3
"""Source unique des textes de l'interface -> lib/l10n/app_fr.arb et app_en.arb.

    python3 scripts/gen_arb.py && flutter gen-l10n
"""
import json
import pathlib
import re

S = {
    'appTitle': ('Quiz Biblique', 'Bible Quiz'),
    'tagline': ('Lire et comprendre la Bible', 'Read and understand the Bible'),
    # Navigation
    'navHome': ('Accueil', 'Home'),
    'navPaths': ('Parcours', 'Paths'),
    'navBible': ('Bible', 'Bible'),
    'navProgress': ('Progrès', 'Progress'),
    # Commun
    'close': ('Fermer', 'Close'),
    'cancel': ('Annuler', 'Cancel'),
    'confirm': ('Confirmer', 'Confirm'),
    'retry': ('Réessayer', 'Try again'),
    'loadError': ('Le contenu n’a pas pu être chargé.', 'The content could not be loaded.'),
    'copied': ('Copié', 'Copied'),
    'copy': ('Copier', 'Copy'),
    'share': ('Partager', 'Share'),
    'addFavorite': ('Mettre de côté', 'Save verse'),
    'removeFavorite': ('Retirer des versets mis de côté', 'Remove from saved verses'),
    'favoriteAdded': ('Verset mis de côté', 'Verse saved'),
    'favoriteRemoved': ('Verset retiré', 'Verse removed'),
    'undo': ('Annuler', 'Undo'),
    'questionsCount': ('{count, plural, =1{1 question} other{{count} questions}}',
                       '{count, plural, =1{1 question} other{{count} questions}}'),
    'versesCount': ('{count, plural, =1{1 verset} other{{count} versets}}',
                    '{count, plural, =1{1 verse} other{{count} verses}}'),
    # Premier lancement
    'welcomeTitle': ('Bienvenue', 'Welcome'),
    'welcomeIntro': ('Ce quiz est un compagnon de lecture : il vous aide à découvrir ce dont parle la Bible.',
                     'This quiz is a reading companion: it helps you discover what the Bible is about.'),
    'welcomeStep1': ('Lisez un court passage, directement dans l’application.',
                     'Read a short passage, right in the app.'),
    'welcomeStep2': ('Répondez à quelques questions pour vérifier ce que vous avez compris.',
                     'Answer a few questions to check what you understood.'),
    'welcomeStep3': ('Chaque réponse est expliquée et renvoie au verset.',
                     'Every answer is explained and points to the verse.'),
    'welcomeOffline': ('Tout fonctionne sans Internet. Textes : Louis Segond 1910 (français) et King James 1769 (anglais).',
                       'Everything works offline. Texts: Louis Segond 1910 (French) and King James 1769 (English).'),
    'chooseLanguage': ('Langue', 'Language'),
    'start': ('Commencer', 'Start'),
    # Accueil
    'streakDays': ('{count, plural, =1{1 jour de suite} other{{count} jours de suite}}',
                   '{count, plural, =1{1 day in a row} other{{count} days in a row}}'),
    'streakStart': ('Commencez votre série aujourd’hui', 'Start your streak today'),
    'streakKeep': ('Lisez aujourd’hui pour garder votre série', 'Read today to keep your streak'),
    'streakDone': ('Bravo, vous avez lu aujourd’hui', 'Well done, you read today'),
    'continueTitle': ('Continuer', 'Continue'),
    'startTitle': ('Pour commencer', 'Get started'),
    'allDone': ('Vous avez terminé tous les parcours. Refaites vos leçons préférées ou lisez librement la Bible.',
                'You have finished every path. Revisit your favourite lessons or read the Bible freely.'),
    'lessonStart': ('Lire et répondre', 'Read and answer'),
    'reviewTitle': ('À revoir', 'Review'),
    'reviewDue': ('{count, plural, =1{1 question à revoir aujourd’hui} other{{count} questions à revoir aujourd’hui}}',
                  '{count, plural, =1{1 question to review today} other{{count} questions to review today}}'),
    'reviewStart': ('Réviser', 'Review'),
    'verseOfDay': ('Verset du jour', 'Verse of the day'),
    'challengeTitle': ('Dans quel livre ?', 'Which book?'),
    'challengeSubtitle': ('Retrouvez le livre d’où vient chaque verset.', 'Find the book each verse comes from.'),
    'challengeQuestion': ('Dans quel livre se trouve ce verset ?', 'Which book is this verse from?'),
    'play': ('Jouer', 'Play'),
    'settings': ('Réglages', 'Settings'),
    # Parcours
    'pathsTitle': ('Parcours', 'Paths'),
    'lessonsProgress': ('{done} / {total} leçons', '{done} / {total} lessons'),
    'booksPathTitle': ('Les 66 livres', 'The 66 books'),
    'booksPathSubtitle': ('Une fiche par livre : de quoi il parle, qui l’a écrit, et quelques questions.',
                          'One page per book: what it is about, who wrote it, and a few questions.'),
    'bestScore': ('Meilleur score : {score} / {total}', 'Best score: {score} / {total}'),
    'oldTestament': ('Ancien Testament', 'Old Testament'),
    'newTestament': ('Nouveau Testament', 'New Testament'),
    # Leçon
    'readTitle': ('À lire', 'Read'),
    'introTitle': ('Avant de lire', 'Before you read'),
    'goToQuestions': ('J’ai lu : aux questions ({count})', 'I’ve read it: to the questions ({count})'),
    'showParallel': ('Afficher aussi l’autre traduction', 'Also show the other translation'),
    'questionOf': ('Question {index} sur {total}', 'Question {index} of {total}'),
    'trueLabel': ('Vrai', 'True'),
    'falseLabel': ('Faux', 'False'),
    'correct': ('Bonne réponse !', 'Correct!'),
    'incorrect': ('Pas tout à fait', 'Not quite'),
    'correctAnswerWas': ('La bonne réponse : {answer}', 'The right answer: {answer}'),
    'readVerse': ('Lire {ref}', 'Read {ref}'),
    'next': ('Suivant', 'Next'),
    'seeResult': ('Voir le résultat', 'See the result'),
    'quitTitle': ('Quitter ?', 'Leave?'),
    'quitBody': ('Vos réponses à cette série ne seront pas enregistrées.', 'Your answers in this round will not be saved.'),
    'quit': ('Quitter', 'Leave'),
    'stay': ('Continuer', 'Stay'),
    # Résultat
    'resultScore': ('{score} / {total}', '{score} / {total}'),
    'resultPerfect': ('Parfait ! Vous avez tout compris.', 'Perfect! You understood everything.'),
    'resultGood': ('Très bien ! Il reste un ou deux points à revoir.', 'Very good! Just one or two points to review.'),
    'resultFair': ('C’est un début. Relire le passage aide beaucoup.', 'A good start. Reading the passage again helps a lot.'),
    'resultLow': ('Pas de souci : relisez le passage, puis réessayez.', 'No worries: read the passage again, then try again.'),
    'takeawayTitle': ('À retenir', 'Key point'),
    'keyVerseTitle': ('Verset clé', 'Key verse'),
    'missedTitle': ('À revoir', 'To review'),
    'missedHint': ('Ces questions reviendront dans vos révisions.', 'These questions will come back in your reviews.'),
    'rereadPassage': ('Relire le passage', 'Read the passage again'),
    'retryQuiz': ('Refaire les questions', 'Retake the questions'),
    'nextLesson': ('Leçon suivante', 'Next lesson'),
    'finish': ('Terminer', 'Finish'),
    'reviewEmpty': ('Rien à revoir aujourd’hui. Les questions ratées reviennent ici le lendemain.',
                    'Nothing to review today. Missed questions come back here the next day.'),
    # Livres
    'bookAuthor': ('Auteur', 'Author'),
    'bookPeriod': ('Époque', 'Period'),
    'bookThemes': ('Thèmes', 'Themes'),
    'bookChapters': ('{count, plural, =1{1 chapitre} other{{count} chapitres}}',
                     '{count, plural, =1{1 chapter} other{{count} chapters}}'),
    'readBook': ('Lire le livre', 'Read the book'),
    'bookQuiz': ('Quiz ({count})', 'Quiz ({count})'),
    'bookInfo': ('Fiche du livre', 'About this book'),
    # Bible
    'chooseBook': ('Choisir un livre', 'Choose a book'),
    'chooseChapter': ('{book} : choisir un chapitre', '{book}: choose a chapter'),
    'chapterTitle': ('{book} {chapter}', '{book} {chapter}'),
    'previousChapter': ('Chapitre précédent', 'Previous chapter'),
    'nextChapter': ('Chapitre suivant', 'Next chapter'),
    'textSize': ('Taille du texte', 'Text size'),
    # Recherche
    'searchTitle': ('Rechercher', 'Search'),
    'searchHint': ('Mots, "expression exacte" ou référence', 'Words, "exact phrase" or reference'),
    'searchClear': ('Effacer', 'Clear'),
    'searchResults': ('{count, plural, =0{Aucun verset} =1{1 verset} other{{count} versets}}',
                      '{count, plural, =0{No verses} =1{1 verse} other{{count} verses}}'),
    'searchResultsFiltered': ('{shown} sur {total} versets', '{shown} of {total} verses'),
    'searchNoResult': ('Aucun verset ne contient tous ces mots. Essayez moins de mots, ou désactivez « Mots entiers ».',
                       'No verse contains all these words. Try fewer words, or turn off “Whole words”.'),
    'searchAll': ('Toute la Bible', 'Whole Bible'),
    'searchOld': ('Ancien Testament', 'Old Testament'),
    'searchNew': ('Nouveau Testament', 'New Testament'),
    'searchBook': ('Livre…', 'Book…'),
    'searchAllBooks': ('Tous les livres', 'All books'),
    'searchWholeWords': ('Mots entiers', 'Whole words'),
    'searchIn': ('Chercher dans : {name}', 'Search in: {name}'),
    'searchGoTo': ('Aller à {ref}', 'Go to {ref}'),
    'searchRecent': ('Recherches récentes', 'Recent searches'),
    'searchClearRecent': ('Tout effacer', 'Clear all'),
    'searchTipsTitle': ('Comment chercher', 'How to search'),
    'searchTipWords': ('Plusieurs mots : les versets qui les contiennent tous, dans n’importe quel ordre.',
                       'Several words: verses containing all of them, in any order.'),
    'searchTipPhrase': ('Entre guillemets : l’expression exacte, ponctuation comprise ou non.',
                        'In quotes: the exact phrase, with or without punctuation.'),
    'searchTipExclude': ('Un tiret devant un mot l’exclut.', 'A dash before a word excludes it.'),
    'searchTipAccents': ('Accents et majuscules ne comptent pas ; un mot trouve aussi les mots qui commencent par lui (pardon → pardonne).',
                         'Accents and capitals do not matter; a word also finds words starting with it (forgive → forgiveness).'),
    'searchTipRef': ('Une référence ouvre directement le passage.', 'A reference opens the passage directly.'),
    'searchExampleWords': ('berger brebis', 'shepherd sheep'),
    'searchExamplePhrase': ('"que la lumière soit"', '"let there be light"'),
    'searchExampleExclude': ('berger -loup', 'shepherd -wolf'),
    'searchExampleRef': ('Jean 3:16', 'John 3:16'),
    'searchPreparing': ('Préparation de la recherche…', 'Preparing search…'),
    'searchMoreResults': ('Affiner la recherche pour voir les autres versets ({count, plural, =1{1 de plus} other{{count} de plus}}).',
                          'Refine the search to see the other verses ({count, plural, =1{1 more} other{{count} more}}).'),
    # Progrès
    'progressTitle': ('Vos progrès', 'Your progress'),
    'statLessons': ('Leçons terminées', 'Lessons completed'),
    'statAnswered': ('Réponses données', 'Answers given'),
    'statAccuracy': ('Bonnes réponses', 'Correct answers'),
    'statMastered': ('Questions acquises', 'Questions mastered'),
    'statStreak': ('Série en cours', 'Current streak'),
    'statBestStreak': ('Meilleure série', 'Best streak'),
    'daysShort': ('{count, plural, =1{1 jour} other{{count} jours}}', '{count, plural, =1{1 day} other{{count} days}}'),
    'favoritesTitle': ('Versets mis de côté', 'Saved verses'),
    'favoritesEmpty': ('Touchez un verset dans la Bible pour le mettre de côté.', 'Tap a verse in the Bible to save it.'),
    'pathsProgressTitle': ('Par parcours', 'By path'),
    # Réglages
    'language': ('Langue', 'Language'),
    'languageSystem': ('Celle du téléphone', 'Phone language'),
    'themeTitle': ('Thème', 'Theme'),
    'themeSystem': ('Celui du téléphone', 'Phone setting'),
    'themeLight': ('Clair', 'Light'),
    'themeDark': ('Sombre', 'Dark'),
    'parallelSetting': ('Lecture bilingue', 'Bilingual reading'),
    'parallelSettingHint': ('Affiche sous chaque verset l’autre traduction (KJV ou Segond).',
                            'Shows the other translation (Segond or KJV) under each verse.'),
    'textSizePreview': ('Au commencement, Dieu créa les cieux et la terre.', 'In the beginning God created the heaven and the earth.'),
    'aboutTitle': ('À propos', 'About'),
    'aboutTexts': ('Textes bibliques : Louis Segond 1910 et King James Version 1769, tous deux dans le domaine public.',
                   'Bible texts: Louis Segond 1910 and King James Version 1769, both in the public domain.'),
    'aboutContent': ('Les questions s’en tiennent à ce que dit le texte, sans prendre parti entre les Églises. Chaque réponse renvoie au verset qui la justifie.',
                     'The questions stick to what the text says, without taking sides between churches. Each answer points to the verse that supports it.'),
    'aboutVersion': ('Version {version}', 'Version {version}'),
    'resetProgress': ('Effacer ma progression', 'Erase my progress'),
    'resetProgressBody': ('Leçons terminées, révisions et série seront effacées. Vos versets mis de côté et vos réglages sont conservés. Cette action est définitive.',
                          'Completed lessons, reviews and streak will be erased. Your saved verses and settings are kept. This cannot be undone.'),
    'resetDone': ('Progression effacée', 'Progress erased'),
}


def placeholders(text):
    names = []
    for m in re.finditer(r'\{([A-Za-z]\w*)(?:\}|,\s*plural)', text):
        if m.group(1) not in names and m.group(1) not in ('other',):
            names.append(m.group(1))
    # Dans un pluriel, les {count} intérieurs ne sont pas de nouveaux paramètres.
    return names


def build(index):
    arb = {'@@locale': ('fr', 'en')[index]}
    for key, pair in S.items():
        text = pair[index]
        arb[key] = text
        ph = placeholders(pair[0])
        if ph:
            arb[f'@{key}'] = {'placeholders': {
                p: {'type': 'int'} if p in ('count', 'done', 'total', 'score', 'index', 'chapter', 'shown') else {'type': 'String'}
                for p in ph}}
    return arb


def main():
    out = pathlib.Path(__file__).resolve().parent.parent / 'lib' / 'l10n'
    out.mkdir(parents=True, exist_ok=True)
    for i, lang in enumerate(('fr', 'en')):
        (out / f'app_{lang}.arb').write_text(json.dumps(build(i), ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    for key, (fr, en) in S.items():
        if placeholders(fr) != placeholders(en) and set(placeholders(fr)) != set(placeholders(en)):
            raise SystemExit(f'Paramètres différents pour {key}')
    print(f'{len(S)} textes écrits dans {out}')


if __name__ == '__main__':
    main()
