abstract interface class Clock {
  DateTime get now;
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime get now => DateTime.now();
}

class FixedClock implements Clock {
  const FixedClock(this.now);

  @override
  final DateTime now;
}
