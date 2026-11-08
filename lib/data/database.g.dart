// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LessonProgressTable extends LessonProgress with TableInfo<$LessonProgressTable, LessonProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lessonIdMeta = const VerificationMeta('lessonId');
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta('bestScore');
  @override
  late final GeneratedColumn<int> bestScore = GeneratedColumn<int>(
    'best_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastScoreMeta = const VerificationMeta('lastScore');
  @override
  late final GeneratedColumn<int> lastScore = GeneratedColumn<int>(
    'last_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstCompletedDayMeta = const VerificationMeta('firstCompletedDay');
  @override
  late final GeneratedColumn<int> firstCompletedDay = GeneratedColumn<int>(
    'first_completed_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastDayMeta = const VerificationMeta('lastDay');
  @override
  late final GeneratedColumn<int> lastDay = GeneratedColumn<int>(
    'last_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [lessonId, bestScore, lastScore, total, attempts, firstCompletedDay, lastDay];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_progress';
  @override
  VerificationContext validateIntegrity(Insertable<LessonProgressData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lesson_id')) {
      context.handle(_lessonIdMeta, lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta));
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('best_score')) {
      context.handle(_bestScoreMeta, bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta));
    } else if (isInserting) {
      context.missing(_bestScoreMeta);
    }
    if (data.containsKey('last_score')) {
      context.handle(_lastScoreMeta, lastScore.isAcceptableOrUnknown(data['last_score']!, _lastScoreMeta));
    } else if (isInserting) {
      context.missing(_lastScoreMeta);
    }
    if (data.containsKey('total')) {
      context.handle(_totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta, attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    } else if (isInserting) {
      context.missing(_attemptsMeta);
    }
    if (data.containsKey('first_completed_day')) {
      context.handle(
        _firstCompletedDayMeta,
        firstCompletedDay.isAcceptableOrUnknown(data['first_completed_day']!, _firstCompletedDayMeta),
      );
    } else if (isInserting) {
      context.missing(_firstCompletedDayMeta);
    }
    if (data.containsKey('last_day')) {
      context.handle(_lastDayMeta, lastDay.isAcceptableOrUnknown(data['last_day']!, _lastDayMeta));
    } else if (isInserting) {
      context.missing(_lastDayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lessonId};
  @override
  LessonProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonProgressData(
      lessonId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}lesson_id'])!,
      bestScore: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}best_score'])!,
      lastScore: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}last_score'])!,
      total: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}total'])!,
      attempts: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      firstCompletedDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_completed_day'],
      )!,
      lastDay: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}last_day'])!,
    );
  }

  @override
  $LessonProgressTable createAlias(String alias) {
    return $LessonProgressTable(attachedDatabase, alias);
  }
}

class LessonProgressData extends DataClass implements Insertable<LessonProgressData> {
  final String lessonId;
  final int bestScore;
  final int lastScore;
  final int total;
  final int attempts;
  final int firstCompletedDay;
  final int lastDay;
  const LessonProgressData({
    required this.lessonId,
    required this.bestScore,
    required this.lastScore,
    required this.total,
    required this.attempts,
    required this.firstCompletedDay,
    required this.lastDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lesson_id'] = Variable<String>(lessonId);
    map['best_score'] = Variable<int>(bestScore);
    map['last_score'] = Variable<int>(lastScore);
    map['total'] = Variable<int>(total);
    map['attempts'] = Variable<int>(attempts);
    map['first_completed_day'] = Variable<int>(firstCompletedDay);
    map['last_day'] = Variable<int>(lastDay);
    return map;
  }

  LessonProgressCompanion toCompanion(bool nullToAbsent) {
    return LessonProgressCompanion(
      lessonId: Value(lessonId),
      bestScore: Value(bestScore),
      lastScore: Value(lastScore),
      total: Value(total),
      attempts: Value(attempts),
      firstCompletedDay: Value(firstCompletedDay),
      lastDay: Value(lastDay),
    );
  }

  factory LessonProgressData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonProgressData(
      lessonId: serializer.fromJson<String>(json['lessonId']),
      bestScore: serializer.fromJson<int>(json['bestScore']),
      lastScore: serializer.fromJson<int>(json['lastScore']),
      total: serializer.fromJson<int>(json['total']),
      attempts: serializer.fromJson<int>(json['attempts']),
      firstCompletedDay: serializer.fromJson<int>(json['firstCompletedDay']),
      lastDay: serializer.fromJson<int>(json['lastDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lessonId': serializer.toJson<String>(lessonId),
      'bestScore': serializer.toJson<int>(bestScore),
      'lastScore': serializer.toJson<int>(lastScore),
      'total': serializer.toJson<int>(total),
      'attempts': serializer.toJson<int>(attempts),
      'firstCompletedDay': serializer.toJson<int>(firstCompletedDay),
      'lastDay': serializer.toJson<int>(lastDay),
    };
  }

  LessonProgressData copyWith({
    String? lessonId,
    int? bestScore,
    int? lastScore,
    int? total,
    int? attempts,
    int? firstCompletedDay,
    int? lastDay,
  }) => LessonProgressData(
    lessonId: lessonId ?? this.lessonId,
    bestScore: bestScore ?? this.bestScore,
    lastScore: lastScore ?? this.lastScore,
    total: total ?? this.total,
    attempts: attempts ?? this.attempts,
    firstCompletedDay: firstCompletedDay ?? this.firstCompletedDay,
    lastDay: lastDay ?? this.lastDay,
  );
  LessonProgressData copyWithCompanion(LessonProgressCompanion data) {
    return LessonProgressData(
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      lastScore: data.lastScore.present ? data.lastScore.value : this.lastScore,
      total: data.total.present ? data.total.value : this.total,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      firstCompletedDay: data.firstCompletedDay.present ? data.firstCompletedDay.value : this.firstCompletedDay,
      lastDay: data.lastDay.present ? data.lastDay.value : this.lastDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressData(')
          ..write('lessonId: $lessonId, ')
          ..write('bestScore: $bestScore, ')
          ..write('lastScore: $lastScore, ')
          ..write('total: $total, ')
          ..write('attempts: $attempts, ')
          ..write('firstCompletedDay: $firstCompletedDay, ')
          ..write('lastDay: $lastDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lessonId, bestScore, lastScore, total, attempts, firstCompletedDay, lastDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonProgressData &&
          other.lessonId == this.lessonId &&
          other.bestScore == this.bestScore &&
          other.lastScore == this.lastScore &&
          other.total == this.total &&
          other.attempts == this.attempts &&
          other.firstCompletedDay == this.firstCompletedDay &&
          other.lastDay == this.lastDay);
}

class LessonProgressCompanion extends UpdateCompanion<LessonProgressData> {
  final Value<String> lessonId;
  final Value<int> bestScore;
  final Value<int> lastScore;
  final Value<int> total;
  final Value<int> attempts;
  final Value<int> firstCompletedDay;
  final Value<int> lastDay;
  final Value<int> rowid;
  const LessonProgressCompanion({
    this.lessonId = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.lastScore = const Value.absent(),
    this.total = const Value.absent(),
    this.attempts = const Value.absent(),
    this.firstCompletedDay = const Value.absent(),
    this.lastDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonProgressCompanion.insert({
    required String lessonId,
    required int bestScore,
    required int lastScore,
    required int total,
    required int attempts,
    required int firstCompletedDay,
    required int lastDay,
    this.rowid = const Value.absent(),
  }) : lessonId = Value(lessonId),
       bestScore = Value(bestScore),
       lastScore = Value(lastScore),
       total = Value(total),
       attempts = Value(attempts),
       firstCompletedDay = Value(firstCompletedDay),
       lastDay = Value(lastDay);
  static Insertable<LessonProgressData> custom({
    Expression<String>? lessonId,
    Expression<int>? bestScore,
    Expression<int>? lastScore,
    Expression<int>? total,
    Expression<int>? attempts,
    Expression<int>? firstCompletedDay,
    Expression<int>? lastDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lessonId != null) 'lesson_id': lessonId,
      if (bestScore != null) 'best_score': bestScore,
      if (lastScore != null) 'last_score': lastScore,
      if (total != null) 'total': total,
      if (attempts != null) 'attempts': attempts,
      if (firstCompletedDay != null) 'first_completed_day': firstCompletedDay,
      if (lastDay != null) 'last_day': lastDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonProgressCompanion copyWith({
    Value<String>? lessonId,
    Value<int>? bestScore,
    Value<int>? lastScore,
    Value<int>? total,
    Value<int>? attempts,
    Value<int>? firstCompletedDay,
    Value<int>? lastDay,
    Value<int>? rowid,
  }) {
    return LessonProgressCompanion(
      lessonId: lessonId ?? this.lessonId,
      bestScore: bestScore ?? this.bestScore,
      lastScore: lastScore ?? this.lastScore,
      total: total ?? this.total,
      attempts: attempts ?? this.attempts,
      firstCompletedDay: firstCompletedDay ?? this.firstCompletedDay,
      lastDay: lastDay ?? this.lastDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<int>(bestScore.value);
    }
    if (lastScore.present) {
      map['last_score'] = Variable<int>(lastScore.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (firstCompletedDay.present) {
      map['first_completed_day'] = Variable<int>(firstCompletedDay.value);
    }
    if (lastDay.present) {
      map['last_day'] = Variable<int>(lastDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonProgressCompanion(')
          ..write('lessonId: $lessonId, ')
          ..write('bestScore: $bestScore, ')
          ..write('lastScore: $lastScore, ')
          ..write('total: $total, ')
          ..write('attempts: $attempts, ')
          ..write('firstCompletedDay: $firstCompletedDay, ')
          ..write('lastDay: $lastDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionStatsTable extends QuestionStats with TableInfo<$QuestionStatsTable, QuestionStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boxMeta = const VerificationMeta('box');
  @override
  late final GeneratedColumn<int> box = GeneratedColumn<int>(
    'box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta('correct');
  @override
  late final GeneratedColumn<int> correct = GeneratedColumn<int>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wrongMeta = const VerificationMeta('wrong');
  @override
  late final GeneratedColumn<int> wrong = GeneratedColumn<int>(
    'wrong',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastDayMeta = const VerificationMeta('lastDay');
  @override
  late final GeneratedColumn<int> lastDay = GeneratedColumn<int>(
    'last_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [questionId, box, dueDay, correct, wrong, lastDay];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_stats';
  @override
  VerificationContext validateIntegrity(Insertable<QuestionStat> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(_questionIdMeta, questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('box')) {
      context.handle(_boxMeta, box.isAcceptableOrUnknown(data['box']!, _boxMeta));
    } else if (isInserting) {
      context.missing(_boxMeta);
    }
    if (data.containsKey('due_day')) {
      context.handle(_dueDayMeta, dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta));
    }
    if (data.containsKey('correct')) {
      context.handle(_correctMeta, correct.isAcceptableOrUnknown(data['correct']!, _correctMeta));
    }
    if (data.containsKey('wrong')) {
      context.handle(_wrongMeta, wrong.isAcceptableOrUnknown(data['wrong']!, _wrongMeta));
    }
    if (data.containsKey('last_day')) {
      context.handle(_lastDayMeta, lastDay.isAcceptableOrUnknown(data['last_day']!, _lastDayMeta));
    } else if (isInserting) {
      context.missing(_lastDayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  QuestionStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionStat(
      questionId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}question_id'])!,
      box: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}box'])!,
      dueDay: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}due_day']),
      correct: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}correct'])!,
      wrong: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}wrong'])!,
      lastDay: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}last_day'])!,
    );
  }

  @override
  $QuestionStatsTable createAlias(String alias) {
    return $QuestionStatsTable(attachedDatabase, alias);
  }
}

class QuestionStat extends DataClass implements Insertable<QuestionStat> {
  final String questionId;
  final int box;
  final int? dueDay;
  final int correct;
  final int wrong;
  final int lastDay;
  const QuestionStat({
    required this.questionId,
    required this.box,
    this.dueDay,
    required this.correct,
    required this.wrong,
    required this.lastDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['box'] = Variable<int>(box);
    if (!nullToAbsent || dueDay != null) {
      map['due_day'] = Variable<int>(dueDay);
    }
    map['correct'] = Variable<int>(correct);
    map['wrong'] = Variable<int>(wrong);
    map['last_day'] = Variable<int>(lastDay);
    return map;
  }

  QuestionStatsCompanion toCompanion(bool nullToAbsent) {
    return QuestionStatsCompanion(
      questionId: Value(questionId),
      box: Value(box),
      dueDay: dueDay == null && nullToAbsent ? const Value.absent() : Value(dueDay),
      correct: Value(correct),
      wrong: Value(wrong),
      lastDay: Value(lastDay),
    );
  }

  factory QuestionStat.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionStat(
      questionId: serializer.fromJson<String>(json['questionId']),
      box: serializer.fromJson<int>(json['box']),
      dueDay: serializer.fromJson<int?>(json['dueDay']),
      correct: serializer.fromJson<int>(json['correct']),
      wrong: serializer.fromJson<int>(json['wrong']),
      lastDay: serializer.fromJson<int>(json['lastDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<String>(questionId),
      'box': serializer.toJson<int>(box),
      'dueDay': serializer.toJson<int?>(dueDay),
      'correct': serializer.toJson<int>(correct),
      'wrong': serializer.toJson<int>(wrong),
      'lastDay': serializer.toJson<int>(lastDay),
    };
  }

  QuestionStat copyWith({
    String? questionId,
    int? box,
    Value<int?> dueDay = const Value.absent(),
    int? correct,
    int? wrong,
    int? lastDay,
  }) => QuestionStat(
    questionId: questionId ?? this.questionId,
    box: box ?? this.box,
    dueDay: dueDay.present ? dueDay.value : this.dueDay,
    correct: correct ?? this.correct,
    wrong: wrong ?? this.wrong,
    lastDay: lastDay ?? this.lastDay,
  );
  QuestionStat copyWithCompanion(QuestionStatsCompanion data) {
    return QuestionStat(
      questionId: data.questionId.present ? data.questionId.value : this.questionId,
      box: data.box.present ? data.box.value : this.box,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      correct: data.correct.present ? data.correct.value : this.correct,
      wrong: data.wrong.present ? data.wrong.value : this.wrong,
      lastDay: data.lastDay.present ? data.lastDay.value : this.lastDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionStat(')
          ..write('questionId: $questionId, ')
          ..write('box: $box, ')
          ..write('dueDay: $dueDay, ')
          ..write('correct: $correct, ')
          ..write('wrong: $wrong, ')
          ..write('lastDay: $lastDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questionId, box, dueDay, correct, wrong, lastDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionStat &&
          other.questionId == this.questionId &&
          other.box == this.box &&
          other.dueDay == this.dueDay &&
          other.correct == this.correct &&
          other.wrong == this.wrong &&
          other.lastDay == this.lastDay);
}

class QuestionStatsCompanion extends UpdateCompanion<QuestionStat> {
  final Value<String> questionId;
  final Value<int> box;
  final Value<int?> dueDay;
  final Value<int> correct;
  final Value<int> wrong;
  final Value<int> lastDay;
  final Value<int> rowid;
  const QuestionStatsCompanion({
    this.questionId = const Value.absent(),
    this.box = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.correct = const Value.absent(),
    this.wrong = const Value.absent(),
    this.lastDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionStatsCompanion.insert({
    required String questionId,
    required int box,
    this.dueDay = const Value.absent(),
    this.correct = const Value.absent(),
    this.wrong = const Value.absent(),
    required int lastDay,
    this.rowid = const Value.absent(),
  }) : questionId = Value(questionId),
       box = Value(box),
       lastDay = Value(lastDay);
  static Insertable<QuestionStat> custom({
    Expression<String>? questionId,
    Expression<int>? box,
    Expression<int>? dueDay,
    Expression<int>? correct,
    Expression<int>? wrong,
    Expression<int>? lastDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (box != null) 'box': box,
      if (dueDay != null) 'due_day': dueDay,
      if (correct != null) 'correct': correct,
      if (wrong != null) 'wrong': wrong,
      if (lastDay != null) 'last_day': lastDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionStatsCompanion copyWith({
    Value<String>? questionId,
    Value<int>? box,
    Value<int?>? dueDay,
    Value<int>? correct,
    Value<int>? wrong,
    Value<int>? lastDay,
    Value<int>? rowid,
  }) {
    return QuestionStatsCompanion(
      questionId: questionId ?? this.questionId,
      box: box ?? this.box,
      dueDay: dueDay ?? this.dueDay,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
      lastDay: lastDay ?? this.lastDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (box.present) {
      map['box'] = Variable<int>(box.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (correct.present) {
      map['correct'] = Variable<int>(correct.value);
    }
    if (wrong.present) {
      map['wrong'] = Variable<int>(wrong.value);
    }
    if (lastDay.present) {
      map['last_day'] = Variable<int>(lastDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionStatsCompanion(')
          ..write('questionId: $questionId, ')
          ..write('box: $box, ')
          ..write('dueDay: $dueDay, ')
          ..write('correct: $correct, ')
          ..write('wrong: $wrong, ')
          ..write('lastDay: $lastDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityDaysTable extends ActivityDays with TableInfo<$ActivityDaysTable, ActivityDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answeredMeta = const VerificationMeta('answered');
  @override
  late final GeneratedColumn<int> answered = GeneratedColumn<int>(
    'answered',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lessonsMeta = const VerificationMeta('lessons');
  @override
  late final GeneratedColumn<int> lessons = GeneratedColumn<int>(
    'lessons',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [day, answered, lessons];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_days';
  @override
  VerificationContext validateIntegrity(Insertable<ActivityDay> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    }
    if (data.containsKey('answered')) {
      context.handle(_answeredMeta, answered.isAcceptableOrUnknown(data['answered']!, _answeredMeta));
    }
    if (data.containsKey('lessons')) {
      context.handle(_lessonsMeta, lessons.isAcceptableOrUnknown(data['lessons']!, _lessonsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  ActivityDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityDay(
      day: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}day'])!,
      answered: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}answered'])!,
      lessons: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}lessons'])!,
    );
  }

  @override
  $ActivityDaysTable createAlias(String alias) {
    return $ActivityDaysTable(attachedDatabase, alias);
  }
}

class ActivityDay extends DataClass implements Insertable<ActivityDay> {
  final int day;
  final int answered;
  final int lessons;
  const ActivityDay({required this.day, required this.answered, required this.lessons});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<int>(day);
    map['answered'] = Variable<int>(answered);
    map['lessons'] = Variable<int>(lessons);
    return map;
  }

  ActivityDaysCompanion toCompanion(bool nullToAbsent) {
    return ActivityDaysCompanion(day: Value(day), answered: Value(answered), lessons: Value(lessons));
  }

  factory ActivityDay.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityDay(
      day: serializer.fromJson<int>(json['day']),
      answered: serializer.fromJson<int>(json['answered']),
      lessons: serializer.fromJson<int>(json['lessons']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<int>(day),
      'answered': serializer.toJson<int>(answered),
      'lessons': serializer.toJson<int>(lessons),
    };
  }

  ActivityDay copyWith({int? day, int? answered, int? lessons}) =>
      ActivityDay(day: day ?? this.day, answered: answered ?? this.answered, lessons: lessons ?? this.lessons);
  ActivityDay copyWithCompanion(ActivityDaysCompanion data) {
    return ActivityDay(
      day: data.day.present ? data.day.value : this.day,
      answered: data.answered.present ? data.answered.value : this.answered,
      lessons: data.lessons.present ? data.lessons.value : this.lessons,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityDay(')
          ..write('day: $day, ')
          ..write('answered: $answered, ')
          ..write('lessons: $lessons')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, answered, lessons);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityDay &&
          other.day == this.day &&
          other.answered == this.answered &&
          other.lessons == this.lessons);
}

class ActivityDaysCompanion extends UpdateCompanion<ActivityDay> {
  final Value<int> day;
  final Value<int> answered;
  final Value<int> lessons;
  const ActivityDaysCompanion({
    this.day = const Value.absent(),
    this.answered = const Value.absent(),
    this.lessons = const Value.absent(),
  });
  ActivityDaysCompanion.insert({
    this.day = const Value.absent(),
    this.answered = const Value.absent(),
    this.lessons = const Value.absent(),
  });
  static Insertable<ActivityDay> custom({Expression<int>? day, Expression<int>? answered, Expression<int>? lessons}) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (answered != null) 'answered': answered,
      if (lessons != null) 'lessons': lessons,
    });
  }

  ActivityDaysCompanion copyWith({Value<int>? day, Value<int>? answered, Value<int>? lessons}) {
    return ActivityDaysCompanion(
      day: day ?? this.day,
      answered: answered ?? this.answered,
      lessons: lessons ?? this.lessons,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (answered.present) {
      map['answered'] = Variable<int>(answered.value);
    }
    if (lessons.present) {
      map['lessons'] = Variable<int>(lessons.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityDaysCompanion(')
          ..write('day: $day, ')
          ..write('answered: $answered, ')
          ..write('lessons: $lessons')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [ref, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(Insertable<Favorite> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ref')) {
      context.handle(_refMeta, ref.isAcceptableOrUnknown(data['ref']!, _refMeta));
    } else if (isInserting) {
      context.missing(_refMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ref};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      ref: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}ref'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final String ref;
  final int createdAt;
  const Favorite({required this.ref, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ref'] = Variable<String>(ref);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(ref: Value(ref), createdAt: Value(createdAt));
  }

  factory Favorite.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      ref: serializer.fromJson<String>(json['ref']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'ref': serializer.toJson<String>(ref), 'createdAt': serializer.toJson<int>(createdAt)};
  }

  Favorite copyWith({String? ref, int? createdAt}) =>
      Favorite(ref: ref ?? this.ref, createdAt: createdAt ?? this.createdAt);
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      ref: data.ref.present ? data.ref.value : this.ref,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('ref: $ref, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ref, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Favorite && other.ref == this.ref && other.createdAt == this.createdAt);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<String> ref;
  final Value<int> createdAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.ref = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({required String ref, required int createdAt, this.rowid = const Value.absent()})
    : ref = Value(ref),
      createdAt = Value(createdAt);
  static Insertable<Favorite> custom({Expression<String>? ref, Expression<int>? createdAt, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (ref != null) 'ref': ref,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({Value<String>? ref, Value<int>? createdAt, Value<int>? rowid}) {
    return FavoritesCompanion(ref: ref ?? this.ref, createdAt: createdAt ?? this.createdAt, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('ref: $ref, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsEntriesTable extends SettingsEntries with TableInfo<$SettingsEntriesTable, SettingsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsEntry(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsEntriesTable createAlias(String alias) {
    return $SettingsEntriesTable(attachedDatabase, alias);
  }
}

class SettingsEntry extends DataClass implements Insertable<SettingsEntry> {
  final String key;
  final String value;
  const SettingsEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingsEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingsEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  SettingsEntry copyWith({String? key, String? value}) =>
      SettingsEntry(key: key ?? this.key, value: value ?? this.value);
  SettingsEntry copyWithCompanion(SettingsEntriesCompanion data) {
    return SettingsEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SettingsEntry && other.key == this.key && other.value == this.value);
}

class SettingsEntriesCompanion extends UpdateCompanion<SettingsEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsEntriesCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<SettingsEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsEntriesCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsEntriesCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LessonProgressTable lessonProgress = $LessonProgressTable(this);
  late final $QuestionStatsTable questionStats = $QuestionStatsTable(this);
  late final $ActivityDaysTable activityDays = $ActivityDaysTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $SettingsEntriesTable settingsEntries = $SettingsEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lessonProgress,
    questionStats,
    activityDays,
    favorites,
    settingsEntries,
  ];
}

typedef $$LessonProgressTableCreateCompanionBuilder = LessonProgressCompanion Function({
  required String lessonId,
  required int bestScore,
  required int lastScore,
  required int total,
  required int attempts,
  required int firstCompletedDay,
  required int lastDay,
  Value<int> rowid,
});
typedef $$LessonProgressTableUpdateCompanionBuilder = LessonProgressCompanion Function({
  Value<String> lessonId,
  Value<int> bestScore,
  Value<int> lastScore,
  Value<int> total,
  Value<int> attempts,
  Value<int> firstCompletedDay,
  Value<int> lastDay,
  Value<int> rowid,
});

class $$LessonProgressTableFilterComposer extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastScore =>
      $composableBuilder(column: $table.lastScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get total => $composableBuilder(column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get firstCompletedDay =>
      $composableBuilder(column: $table.firstCompletedDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastDay =>
      $composableBuilder(column: $table.lastDay, builder: (column) => ColumnFilters(column));
}

class $$LessonProgressTableOrderingComposer extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastScore =>
      $composableBuilder(column: $table.lastScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get firstCompletedDay =>
      $composableBuilder(column: $table.firstCompletedDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastDay =>
      $composableBuilder(column: $table.lastDay, builder: (column) => ColumnOrderings(column));
}

class $$LessonProgressTableAnnotationComposer extends Composer<_$AppDatabase, $LessonProgressTable> {
  $$LessonProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId => $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<int> get bestScore => $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<int> get lastScore => $composableBuilder(column: $table.lastScore, builder: (column) => column);

  GeneratedColumn<int> get total => $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get attempts => $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get firstCompletedDay =>
      $composableBuilder(column: $table.firstCompletedDay, builder: (column) => column);

  GeneratedColumn<int> get lastDay => $composableBuilder(column: $table.lastDay, builder: (column) => column);
}

class $$LessonProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonProgressTable,
          LessonProgressData,
          $$LessonProgressTableFilterComposer,
          $$LessonProgressTableOrderingComposer,
          $$LessonProgressTableAnnotationComposer,
          $$LessonProgressTableCreateCompanionBuilder,
          $$LessonProgressTableUpdateCompanionBuilder,
          (LessonProgressData, BaseReferences<_$AppDatabase, $LessonProgressTable, LessonProgressData>),
          LessonProgressData,
          PrefetchHooks Function()
        > {
  $$LessonProgressTableTableManager(_$AppDatabase db, $LessonProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LessonProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LessonProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$LessonProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> lessonId = const Value.absent(),
                Value<int> bestScore = const Value.absent(),
                Value<int> lastScore = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> firstCompletedDay = const Value.absent(),
                Value<int> lastDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressCompanion(
                lessonId: lessonId,
                bestScore: bestScore,
                lastScore: lastScore,
                total: total,
                attempts: attempts,
                firstCompletedDay: firstCompletedDay,
                lastDay: lastDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String lessonId,
                required int bestScore,
                required int lastScore,
                required int total,
                required int attempts,
                required int firstCompletedDay,
                required int lastDay,
                Value<int> rowid = const Value.absent(),
              }) => LessonProgressCompanion.insert(
                lessonId: lessonId,
                bestScore: bestScore,
                lastScore: lastScore,
                total: total,
                attempts: attempts,
                firstCompletedDay: firstCompletedDay,
                lastDay: lastDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LessonProgressTable, LessonProgressData>(table),
                  BaseReferences<_$AppDatabase, $LessonProgressTable, LessonProgressData>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LessonProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonProgressTable,
      LessonProgressData,
      $$LessonProgressTableFilterComposer,
      $$LessonProgressTableOrderingComposer,
      $$LessonProgressTableAnnotationComposer,
      $$LessonProgressTableCreateCompanionBuilder,
      $$LessonProgressTableUpdateCompanionBuilder,
      (LessonProgressData, BaseReferences<_$AppDatabase, $LessonProgressTable, LessonProgressData>),
      LessonProgressData,
      PrefetchHooks Function()
    >;
typedef $$QuestionStatsTableCreateCompanionBuilder = QuestionStatsCompanion Function({
  required String questionId,
  required int box,
  Value<int?> dueDay,
  Value<int> correct,
  Value<int> wrong,
  required int lastDay,
  Value<int> rowid,
});
typedef $$QuestionStatsTableUpdateCompanionBuilder = QuestionStatsCompanion Function({
  Value<String> questionId,
  Value<int> box,
  Value<int?> dueDay,
  Value<int> correct,
  Value<int> wrong,
  Value<int> lastDay,
  Value<int> rowid,
});

class $$QuestionStatsTableFilterComposer extends Composer<_$AppDatabase, $QuestionStatsTable> {
  $$QuestionStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get questionId =>
      $composableBuilder(column: $table.questionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get box => $composableBuilder(column: $table.box, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wrong => $composableBuilder(column: $table.wrong, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastDay =>
      $composableBuilder(column: $table.lastDay, builder: (column) => ColumnFilters(column));
}

class $$QuestionStatsTableOrderingComposer extends Composer<_$AppDatabase, $QuestionStatsTable> {
  $$QuestionStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get questionId =>
      $composableBuilder(column: $table.questionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get box => $composableBuilder(column: $table.box, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wrong =>
      $composableBuilder(column: $table.wrong, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastDay =>
      $composableBuilder(column: $table.lastDay, builder: (column) => ColumnOrderings(column));
}

class $$QuestionStatsTableAnnotationComposer extends Composer<_$AppDatabase, $QuestionStatsTable> {
  $$QuestionStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get questionId => $composableBuilder(column: $table.questionId, builder: (column) => column);

  GeneratedColumn<int> get box => $composableBuilder(column: $table.box, builder: (column) => column);

  GeneratedColumn<int> get dueDay => $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<int> get correct => $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get wrong => $composableBuilder(column: $table.wrong, builder: (column) => column);

  GeneratedColumn<int> get lastDay => $composableBuilder(column: $table.lastDay, builder: (column) => column);
}

class $$QuestionStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionStatsTable,
          QuestionStat,
          $$QuestionStatsTableFilterComposer,
          $$QuestionStatsTableOrderingComposer,
          $$QuestionStatsTableAnnotationComposer,
          $$QuestionStatsTableCreateCompanionBuilder,
          $$QuestionStatsTableUpdateCompanionBuilder,
          (QuestionStat, BaseReferences<_$AppDatabase, $QuestionStatsTable, QuestionStat>),
          QuestionStat,
          PrefetchHooks Function()
        > {
  $$QuestionStatsTableTableManager(_$AppDatabase db, $QuestionStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$QuestionStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$QuestionStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$QuestionStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> questionId = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int?> dueDay = const Value.absent(),
                Value<int> correct = const Value.absent(),
                Value<int> wrong = const Value.absent(),
                Value<int> lastDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionStatsCompanion(
                questionId: questionId,
                box: box,
                dueDay: dueDay,
                correct: correct,
                wrong: wrong,
                lastDay: lastDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String questionId,
                required int box,
                Value<int?> dueDay = const Value.absent(),
                Value<int> correct = const Value.absent(),
                Value<int> wrong = const Value.absent(),
                required int lastDay,
                Value<int> rowid = const Value.absent(),
              }) => QuestionStatsCompanion.insert(
                questionId: questionId,
                box: box,
                dueDay: dueDay,
                correct: correct,
                wrong: wrong,
                lastDay: lastDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestionStatsTable, QuestionStat>(table),
                  BaseReferences<_$AppDatabase, $QuestionStatsTable, QuestionStat>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionStatsTable,
      QuestionStat,
      $$QuestionStatsTableFilterComposer,
      $$QuestionStatsTableOrderingComposer,
      $$QuestionStatsTableAnnotationComposer,
      $$QuestionStatsTableCreateCompanionBuilder,
      $$QuestionStatsTableUpdateCompanionBuilder,
      (QuestionStat, BaseReferences<_$AppDatabase, $QuestionStatsTable, QuestionStat>),
      QuestionStat,
      PrefetchHooks Function()
    >;
typedef $$ActivityDaysTableCreateCompanionBuilder = ActivityDaysCompanion Function({
  Value<int> day,
  Value<int> answered,
  Value<int> lessons,
});
typedef $$ActivityDaysTableUpdateCompanionBuilder = ActivityDaysCompanion Function({
  Value<int> day,
  Value<int> answered,
  Value<int> lessons,
});

class $$ActivityDaysTableFilterComposer extends Composer<_$AppDatabase, $ActivityDaysTable> {
  $$ActivityDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get answered =>
      $composableBuilder(column: $table.answered, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lessons =>
      $composableBuilder(column: $table.lessons, builder: (column) => ColumnFilters(column));
}

class $$ActivityDaysTableOrderingComposer extends Composer<_$AppDatabase, $ActivityDaysTable> {
  $$ActivityDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get day => $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get answered =>
      $composableBuilder(column: $table.answered, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lessons =>
      $composableBuilder(column: $table.lessons, builder: (column) => ColumnOrderings(column));
}

class $$ActivityDaysTableAnnotationComposer extends Composer<_$AppDatabase, $ActivityDaysTable> {
  $$ActivityDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get day => $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get answered => $composableBuilder(column: $table.answered, builder: (column) => column);

  GeneratedColumn<int> get lessons => $composableBuilder(column: $table.lessons, builder: (column) => column);
}

class $$ActivityDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityDaysTable,
          ActivityDay,
          $$ActivityDaysTableFilterComposer,
          $$ActivityDaysTableOrderingComposer,
          $$ActivityDaysTableAnnotationComposer,
          $$ActivityDaysTableCreateCompanionBuilder,
          $$ActivityDaysTableUpdateCompanionBuilder,
          (ActivityDay, BaseReferences<_$AppDatabase, $ActivityDaysTable, ActivityDay>),
          ActivityDay,
          PrefetchHooks Function()
        > {
  $$ActivityDaysTableTableManager(_$AppDatabase db, $ActivityDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ActivityDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ActivityDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ActivityDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> day = const Value.absent(),
            Value<int> answered = const Value.absent(),
            Value<int> lessons = const Value.absent(),
          }) => ActivityDaysCompanion(day: day, answered: answered, lessons: lessons),
          createCompanionCallback: ({
            Value<int> day = const Value.absent(),
            Value<int> answered = const Value.absent(),
            Value<int> lessons = const Value.absent(),
          }) => ActivityDaysCompanion.insert(day: day, answered: answered, lessons: lessons),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivityDaysTable, ActivityDay>(table),
                  BaseReferences<_$AppDatabase, $ActivityDaysTable, ActivityDay>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityDaysTable,
      ActivityDay,
      $$ActivityDaysTableFilterComposer,
      $$ActivityDaysTableOrderingComposer,
      $$ActivityDaysTableAnnotationComposer,
      $$ActivityDaysTableCreateCompanionBuilder,
      $$ActivityDaysTableUpdateCompanionBuilder,
      (ActivityDay, BaseReferences<_$AppDatabase, $ActivityDaysTable, ActivityDay>),
      ActivityDay,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String ref,
  required int createdAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> ref,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ref => $composableBuilder(column: $table.ref, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FavoritesTableOrderingComposer extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FavoritesTableAnnotationComposer extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ref => $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<int> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          Favorite,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
          Favorite,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> ref = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => FavoritesCompanion(ref: ref, createdAt: createdAt, rowid: rowid),
          createCompanionCallback: ({
            required String ref,
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) => FavoritesCompanion.insert(ref: ref, createdAt: createdAt, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, Favorite>(table),
                  BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      Favorite,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
      Favorite,
      PrefetchHooks Function()
    >;
typedef $$SettingsEntriesTableCreateCompanionBuilder = SettingsEntriesCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsEntriesTableUpdateCompanionBuilder = SettingsEntriesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsEntriesTableFilterComposer extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsEntriesTableOrderingComposer extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsEntriesTableAnnotationComposer extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsEntriesTable,
          SettingsEntry,
          $$SettingsEntriesTableFilterComposer,
          $$SettingsEntriesTableOrderingComposer,
          $$SettingsEntriesTableAnnotationComposer,
          $$SettingsEntriesTableCreateCompanionBuilder,
          $$SettingsEntriesTableUpdateCompanionBuilder,
          (SettingsEntry, BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingsEntry>),
          SettingsEntry,
          PrefetchHooks Function()
        > {
  $$SettingsEntriesTableTableManager(_$AppDatabase db, $SettingsEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SettingsEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsEntriesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsEntriesTable, SettingsEntry>(table),
                  BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingsEntry>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsEntriesTable,
      SettingsEntry,
      $$SettingsEntriesTableFilterComposer,
      $$SettingsEntriesTableOrderingComposer,
      $$SettingsEntriesTableAnnotationComposer,
      $$SettingsEntriesTableCreateCompanionBuilder,
      $$SettingsEntriesTableUpdateCompanionBuilder,
      (SettingsEntry, BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingsEntry>),
      SettingsEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LessonProgressTableTableManager get lessonProgress => $$LessonProgressTableTableManager(_db, _db.lessonProgress);
  $$QuestionStatsTableTableManager get questionStats => $$QuestionStatsTableTableManager(_db, _db.questionStats);
  $$ActivityDaysTableTableManager get activityDays => $$ActivityDaysTableTableManager(_db, _db.activityDays);
  $$FavoritesTableTableManager get favorites => $$FavoritesTableTableManager(_db, _db.favorites);
  $$SettingsEntriesTableTableManager get settingsEntries =>
      $$SettingsEntriesTableTableManager(_db, _db.settingsEntries);
}
