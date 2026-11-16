enum GameCategory { rapid, blitz, bullet, classical, offline, aiPractice, custom }

class TimeControl {
  final String name;
  final int baseSeconds;
  final int incrementSeconds;
  final GameCategory category;

  const TimeControl({
    required this.name,
    required this.baseSeconds,
    this.incrementSeconds = 0,
    required this.category,
  });

  bool get isCasual => baseSeconds == 0;

  String get displayLabel {
    if (isCasual) return 'No Clock (Casual)';
    final mins = baseSeconds ~/ 60;
    if (incrementSeconds > 0) {
      return '${mins}m + ${incrementSeconds}s';
    }
    return '${mins} min';
  }

  // Rapid Presets
  static const rapid10 = TimeControl(name: '10 min Rapid', baseSeconds: 600, incrementSeconds: 0, category: GameCategory.rapid);
  static const rapid10_5 = TimeControl(name: '10|5 Rapid', baseSeconds: 600, incrementSeconds: 5, category: GameCategory.rapid);
  static const rapid15_10 = TimeControl(name: '15|10 Rapid', baseSeconds: 900, incrementSeconds: 10, category: GameCategory.rapid);

  // Blitz Presets
  static const blitz3 = TimeControl(name: '3 min Blitz', baseSeconds: 180, incrementSeconds: 0, category: GameCategory.blitz);
  static const blitz3_2 = TimeControl(name: '3|2 Blitz', baseSeconds: 180, incrementSeconds: 2, category: GameCategory.blitz);
  static const blitz5 = TimeControl(name: '5 min Blitz', baseSeconds: 300, incrementSeconds: 0, category: GameCategory.blitz);
  static const blitz5_3 = TimeControl(name: '5|3 Blitz', baseSeconds: 300, incrementSeconds: 3, category: GameCategory.blitz);

  // Bullet Presets
  static const bullet1 = TimeControl(name: '1 min Bullet', baseSeconds: 60, incrementSeconds: 0, category: GameCategory.bullet);
  static const bullet1_1 = TimeControl(name: '1|1 Bullet', baseSeconds: 60, incrementSeconds: 1, category: GameCategory.bullet);
  static const bullet2_1 = TimeControl(name: '2|1 Bullet', baseSeconds: 120, incrementSeconds: 1, category: GameCategory.bullet);

  // Classical Presets
  static const classical30 = TimeControl(name: '30 min Classical', baseSeconds: 1800, incrementSeconds: 0, category: GameCategory.classical);
  static const classical30_20 = TimeControl(name: '30|20 Classical', baseSeconds: 1800, incrementSeconds: 20, category: GameCategory.classical);
  static const classical60 = TimeControl(name: '60 min Classical', baseSeconds: 3600, incrementSeconds: 0, category: GameCategory.classical);

  // Offline / Casual
  static const casual = TimeControl(name: 'Untimed Casual', baseSeconds: 0, incrementSeconds: 0, category: GameCategory.offline);
}
