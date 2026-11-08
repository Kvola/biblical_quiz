import 'days.dart';

/// Révision espacée (boîtes de Leitner).
///
/// Une question ratée revient le lendemain ; chaque bonne réponse l'envoie
/// dans la boîte suivante, revue de plus en plus rarement. Au-delà de la
/// dernière boîte, elle est considérée comme acquise et ne revient plus.
class Leitner {
  /// Délai (jours) avant la prochaine révision, selon la boîte atteinte.
  static const intervals = [1, 3, 7, 16, 35];

  /// Boîte « acquise » : plus de révision.
  static int get mastered => intervals.length;

  /// Nouvel état après une réponse. [box] vaut -1 pour une question jamais vue.
  ///
  /// - Bonne réponse à la première rencontre : directement en boîte 1 (on
  ///   ne fait pas réviser ce que la personne savait déjà le lendemain).
  /// - Erreur : retour en boîte 0, à revoir demain.
  static ({int box, int? dueDay}) next({required int box, required bool correct, required int today}) {
    final int newBox;
    if (!correct) {
      newBox = 0;
    } else if (box < 0) {
      newBox = 1;
    } else {
      newBox = box + 1;
    }
    if (newBox >= mastered) return (box: mastered, dueDay: null);
    return (box: newBox, dueDay: addDays(today, intervals[newBox]));
  }
}
