class Profile {
  final String id;
  final String? displayName;
  final String? gender;
  final int? birthYear;
  final bool onboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    this.displayName,
    this.gender,
    this.birthYear,
    this.onboardingCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      gender: json['gender'] as String?,
      birthYear: json['birth_year'] as int?,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'gender': gender,
      'birth_year': birthYear,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? displayName,
    String? gender,
    int? birthYear,
    bool? onboardingCompleted,
  }) {
    return Profile(
      id: id,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
