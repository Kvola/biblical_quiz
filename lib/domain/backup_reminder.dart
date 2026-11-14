/// Quand rappeler de sauvegarder les notes de prédication ?
///
/// Les notes ne vivent que sur le téléphone : une sauvegarde est la seule
/// protection contre sa perte. Le rappel reste discret (un bandeau dans
/// l'onglet Notes, jamais une notification) :
/// * jamais sauvegardé : quand la plus ancienne note a [firstAfter] ;
/// * sinon : [every] après la dernière sauvegarde ;
/// * « Plus tard » le fait taire pendant [every].
class BackupReminder {
  static const firstAfter = Duration(days: 7);
  static const every = Duration(days: 30);

  /// [oldestNote] : création de la plus ancienne note (null = aucune note).
  static bool isDue({required DateTime now, DateTime? oldestNote, DateTime? lastBackup, DateTime? dismissed}) {
    if (oldestNote == null) return false;
    final due = lastBackup == null ? oldestNote.add(firstAfter) : lastBackup.add(every);
    if (now.isBefore(due)) return false;
    if (dismissed != null && now.isBefore(dismissed.add(every))) return false;
    return true;
  }

  /// Jours écoulés depuis la dernière sauvegarde (pour le message), au moins 1.
  static int daysSince(DateTime lastBackup, DateTime now) {
    final d = now.difference(lastBackup).inDays;
    return d < 1 ? 1 : d;
  }
}
