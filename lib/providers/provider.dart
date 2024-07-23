// // providers.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final obscureCurrentPasswordProvider =
//     StateProvider<bool>((ref) => true).notifier;
// final obscureNewPasswordProvider = StateProvider<bool>((ref) => true).notifier;

// provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

final obscureCurrentPasswordProvider = StateProvider<bool>((ref) => true);
final obscureNewPasswordProvider = StateProvider<bool>((ref) => true);
