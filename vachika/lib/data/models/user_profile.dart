/// User profile model for VACHIKA.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String preferredLanguage; // 'en', 'hi', 'mr'
  final String role; // 'deaf', 'hearing', 'learner'
  final bool isGuest;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.preferredLanguage = 'en',
    this.role = 'deaf',
    this.isGuest = false,
    required this.createdAt,
  });

  /// Factory for guest / anonymous user
  factory UserProfile.guest({String preferredLanguage = 'en'}) {
    return UserProfile(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Guest User',
      email: 'guest@vachika.local',
      preferredLanguage: preferredLanguage,
      role: 'deaf',
      isGuest: true,
      createdAt: DateTime.now(),
    );
  }

  /// Demo user for testing
  factory UserProfile.demo() {
    return UserProfile(
      id: 'demo_user_001',
      name: 'Aarav Sharma',
      email: 'aarav@vachika.ai',
      preferredLanguage: 'en',
      role: 'deaf',
      isGuest: false,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferredLanguage': preferredLanguage,
      'role': role,
      'isGuest': isGuest,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      role: json['role'] as String? ?? 'deaf',
      isGuest: json['isGuest'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? preferredLanguage,
    String? role,
    bool? isGuest,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      role: role ?? this.role,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt,
    );
  }
}
