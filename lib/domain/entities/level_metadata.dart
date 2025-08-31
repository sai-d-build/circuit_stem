// Simplified level metadata for Circuit STEM educational gaming platform
// Temporarily simplified to avoid missing class dependencies

class LevelMetadata {
  // Temporarily empty due to missing dependencies
  String get id => '';
  String get title => '';
  String get description => '';
  String get difficulty => '';
  String get category => '';
  bool get unlocked => false;
  Map<String, dynamic> get statistics => {};
  Map<String, dynamic> get prerequisites => {};
  Map<String, dynamic> get userRating => {};

  // Add missing methods needed by level manager
  Map<String, dynamic> toJson() => {};
  static LevelMetadata fromJson(Map<String, dynamic> json) => LevelMetadata();
  LevelMetadata copyWith({bool? unlocked}) => LevelMetadata();
}

class LevelStatistics {
  // Temporarily empty due to missing dependencies
  int get totalAttempts => 0;
  int get successfulAttempts => 0;
  double get averageCompletionTime => 0.0;
  DateTime get lastPlayed => DateTime.now();
  Map<String, dynamic> get performanceMetrics => {};
}

class UserRating {
  // Temporarily empty due to missing dependencies
  double get averageRating => 0.0;
  int get totalRatings => 0;
  Map<int, int> get ratingDistribution => {};
  DateTime get lastUpdated => DateTime.now();
}