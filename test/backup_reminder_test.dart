import 'package:biblical_quiz/domain/backup_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 12, 15);
  bool due({DateTime? oldest, DateTime? backup, DateTime? dismissed}) =>
      BackupReminder.isDue(now: now, oldestNote: oldest, lastBackup: backup, dismissed: dismissed);

  test('sans note : jamais de rappel', () => expect(due(), isFalse));

  test('jamais sauvegardé : rappel une semaine après la première note', () {
    expect(due(oldest: now.subtract(const Duration(days: 3))), isFalse);
    expect(due(oldest: now.subtract(const Duration(days: 7))), isTrue);
  });

  test('sauvegardé : rappel 30 jours après', () {
    final old = now.subtract(const Duration(days: 200));
    expect(due(oldest: old, backup: now.subtract(const Duration(days: 29))), isFalse);
    expect(due(oldest: old, backup: now.subtract(const Duration(days: 30))), isTrue);
  });

  test('« Plus tard » : silence pendant 30 jours, puis le rappel revient', () {
    final old = now.subtract(const Duration(days: 200));
    expect(due(oldest: old, dismissed: now.subtract(const Duration(days: 10))), isFalse);
    expect(due(oldest: old, dismissed: now.subtract(const Duration(days: 31))), isTrue);
  });

  test('jours écoulés, au moins 1', () {
    expect(BackupReminder.daysSince(now.subtract(const Duration(hours: 3)), now), 1);
    expect(BackupReminder.daysSince(now.subtract(const Duration(days: 45)), now), 45);
  });
}
