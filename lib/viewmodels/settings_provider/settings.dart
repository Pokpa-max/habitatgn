import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/services/settingService/setting_service.dart';

class SettingViewModel extends StateNotifier<AsyncValue<void>> {
  final SettingService _settingService;

  SettingViewModel(this._settingService) : super(const AsyncData(null));

  Future<void> sendMessage(
      String name, String email, String subject, String message) async {
    state = const AsyncLoading();
    try {
      await _settingService.sendMessage(name, email, subject, message);
      state = const AsyncData(null);
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    state = const AsyncLoading();
    try {
      await _settingService.changePassword(currentPassword, newPassword);
      state = const AsyncData(null);
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    try {
      await _settingService.deleteAccount();
      state = const AsyncData(null);
    } catch (error) {
      state = AsyncError(error, StackTrace.current);
    }
  }

  User? get currentUser => _settingService.getCurrentUser();
}

final settingServiceProvider =
    Provider<SettingService>((ref) => SettingService());
final settingViewModelProvider =
    StateNotifierProvider<SettingViewModel, AsyncValue<void>>(
  (ref) => SettingViewModel(ref.watch(settingServiceProvider)),
);
