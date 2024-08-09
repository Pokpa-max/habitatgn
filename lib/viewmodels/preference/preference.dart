import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitatgn/services/preference/preference.dart';

final userPreferencesServiceProvider = Provider<UserPreferencesService>((ref) {
  return UserPreferencesService(FirebaseFirestore.instance);
});

// Utiliser StreamProvider pour les préférences utilisateur
final userPreferencesProvider =
    StreamProvider.family<Map<String, bool>, String>((ref, userId) {
  final service = ref.watch(userPreferencesServiceProvider);
  return service.getPreferencesStream(userId);
});

final updatePreferenceProvider =
    Provider.family<void, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(userPreferencesServiceProvider);
  final userId = params['userId'] as String;
  final type = params['type'] as String;
  final value = params['value'] as bool;

  await service.updatePreference(userId, type, value);
});
