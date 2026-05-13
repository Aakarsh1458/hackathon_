class TimeBucket {
  final int startHourInclusive;
  final int endHourExclusive;
  final String label;

  const TimeBucket(
    this.startHourInclusive,
    this.endHourExclusive,
    this.label,
  );

  bool contains(DateTime t) {
    final h = t.hour;
    if (startHourInclusive <= endHourExclusive) {
      return h >= startHourInclusive && h < endHourExclusive;
    }
    // Wrap-around (e.g., 22 -> 3)
    return h >= startHourInclusive || h < endHourExclusive;
  }
}

const List<TimeBucket> kDefaultVulnerableBuckets = <TimeBucket>[
  TimeBucket(0, 3, '00:00-03:00'),
  TimeBucket(3, 6, '03:00-06:00'),
  TimeBucket(22, 24, '22:00-00:00'),
];

