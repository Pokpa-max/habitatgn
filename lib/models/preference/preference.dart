// // lib/models/user_preferences.dart

// class UserPreferences {
//   final bool receiveNotifications;
//   final String preferredCategory;

//   UserPreferences({
//     required this.receiveNotifications,
//     required this.preferredCategory,
//   });

//   factory UserPreferences.fromMap(Map<String, dynamic> map) {
//     return UserPreferences(
//       receiveNotifications: map['receiveNotifications'] ?? true,
//       preferredCategory: map['preferredCategory'] ?? 'All',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'receiveNotifications': receiveNotifications,
//       'preferredCategory': preferredCategory,
//     };
//   }
// }

// lib/models/preference/user_preferences.dart

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
