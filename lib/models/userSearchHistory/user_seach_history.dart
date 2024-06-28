class UserSearchHistory {
  final String query;
  final DateTime timestamp;

  UserSearchHistory({
    required this.query,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'timestamp': timestamp,
    };
  }
}
