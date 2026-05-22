class UserModel {
  final String id;
  final String name;
  final String city;
  final int points;
  final int scans;
  final int badges;
  final int rank;
  final int level;
  final int xp;
  final int xpMax;
  final double co2Saved;
  final double weeklyGoalKg;
  final double weeklyProgress;
  final List<Map<String, dynamic>> recentScans;

  const UserModel({
    required this.id,
    required this.name,
    required this.city,
    required this.points,
    required this.scans,
    required this.badges,
    required this.rank,
    required this.level,
    required this.xp,
    required this.xpMax,
    required this.co2Saved,
    required this.weeklyGoalKg,
    required this.weeklyProgress,
    this.recentScans = const [],
  });

  factory UserModel.empty() => const UserModel(
        id: '',
        name: 'Utilisateur',
        city: 'Maroc',
        points: 0,
        scans: 0,
        badges: 0,
        rank: 0,
        level: 1,
        xp: 0,
        xpMax: 200,
        co2Saved: 0,
        weeklyGoalKg: 10.0,
        weeklyProgress: 0.0,
      );

  UserModel copyWith({
    String? name,
    String? city,
    int? points,
    int? scans,
    int? badges,
    int? rank,
    int? level,
    int? xp,
    int? xpMax,
    double? co2Saved,
    double? weeklyGoalKg,
    double? weeklyProgress,
    List<Map<String, dynamic>>? recentScans,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      city: city ?? this.city,
      points: points ?? this.points,
      scans: scans ?? this.scans,
      badges: badges ?? this.badges,
      rank: rank ?? this.rank,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpMax: xpMax ?? this.xpMax,
      co2Saved: co2Saved ?? this.co2Saved,
      weeklyGoalKg: weeklyGoalKg ?? this.weeklyGoalKg,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      recentScans: recentScans ?? this.recentScans,
    );
  }
}
