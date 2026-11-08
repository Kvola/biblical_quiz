/// Jours civils locaux sous forme d'entier AAAAMMJJ : comparable, stockable,
/// insensible aux fuseaux et aux changements d'heure.
int dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

DateTime fromDayKey(int k) => DateTime(k ~/ 10000, (k ~/ 100) % 100, k % 100);

/// Ajoute [days] jours civils (DateTime normalise les débordements de mois).
int addDays(int key, int days) {
  final d = fromDayKey(key);
  return dayKey(DateTime(d.year, d.month, d.day + days));
}

/// Série en cours : nombre de jours consécutifs d'activité se terminant
/// aujourd'hui, ou hier (la série n'est pas perdue tant que la journée n'est pas finie).
int currentStreak(Set<int> activeDays, int today) {
  var day = activeDays.contains(today) ? today : addDays(today, -1);
  var n = 0;
  while (activeDays.contains(day)) {
    n++;
    day = addDays(day, -1);
  }
  return n;
}

/// Plus longue série jamais réalisée.
int bestStreak(Iterable<int> activeDays) {
  final days = activeDays.toSet().toList()..sort();
  var best = 0, run = 0;
  int? prev;
  for (final d in days) {
    run = (prev != null && addDays(prev, 1) == d) ? run + 1 : 1;
    if (run > best) best = run;
    prev = d;
  }
  return best;
}
