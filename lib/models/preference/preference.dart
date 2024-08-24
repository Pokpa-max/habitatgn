class UserPreferences {
  final bool receiveNotifications;
  final String preferredCategory;

  UserPreferences({
    required this.receiveNotifications,
    required this.preferredCategory,
  });

  UserPreferences copyWith({
    bool? receiveNotifications,
    String? preferredCategory,
  }) {
    return UserPreferences(
      receiveNotifications: receiveNotifications ?? this.receiveNotifications,
      preferredCategory: preferredCategory ?? this.preferredCategory,
    );
  }

  @override
  String toString() {
    return 'UserPreferences(receiveNotifications: $receiveNotifications, preferredCategory: $preferredCategory)';
  }
}
