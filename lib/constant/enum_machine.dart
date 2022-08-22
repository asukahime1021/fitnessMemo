enum Machine {
  abdominal,
  rotaryTorso,
  convergingChestPress,
  shoulderPress,
  treadmil,
}

extension MachineExtension on Machine {
  static final names = {
    Machine.abdominal: 'アブドミナル',
    Machine.rotaryTorso: 'ロータリートルソー',
    Machine.convergingChestPress: 'コンバージングチェストプレス',
    Machine.shoulderPress: 'ショルダープレス',
    Machine.treadmil: 'トレッドミル',
  };

  static final numbers = {
    Machine.abdominal: 1,
    Machine.rotaryTorso: 2,
    Machine.convergingChestPress: 3,
    Machine.shoulderPress: 4,
    Machine.treadmil: 5
  };

  String get name => names[this]!;
  int get number => numbers[this]!;
}
