// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:habitatgn/models/service.dart';
// import 'package:habitatgn/services/repairs/repair_servicies.dart';

// final serviceRequestServiceProvider = Provider<ServiceRequestService>((ref) {
//   return ServiceRequestService();
// });

// final serviceRequestViewModelProvider =
//     ChangeNotifierProvider<ServiceRequestViewModel>((ref) {
//   return ServiceRequestViewModel(ref);
// });

// class ServiceRequestViewModel extends ChangeNotifier {
//   ServiceRequestViewModel(this._ref)
//       : _serviceRequestService = _ref.read(serviceRequestServiceProvider);

//   final ServiceRequestService _serviceRequestService;
//   final Ref _ref;
//   bool _isSubmitting = false;

//   bool get isSubmitting => _isSubmitting;

//   Future<void> submitRequest(ServiceRequestModel request) async {
//     try {
//       _isSubmitting = true;
//       notifyListeners();
//       await _serviceRequestService.submitRequest(request);
//     } catch (e) {
//       throw Exception('Erreur lors de la soumission: $e');
//     } finally {
//       _isSubmitting = false;
//       notifyListeners();
//     }
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/service.dart';
import 'package:habitatgn/services/repairs/repair_servicies.dart';

class ServiceRequestViewModel extends StateNotifier<AsyncValue<void>> {
  final ServiceRequestService _serviceRequestService;

  ServiceRequestViewModel(this._serviceRequestService)
      : super(const AsyncData(null));

  Future<void> submitRequest(ServiceRequestModel request) async {
    try {
      await _serviceRequestService.submitRequest(request);
    } catch (e) {
      throw Exception('Erreur lors de la soumission: $e');
    } finally {}
  }
}

final serviceRequestServiceProvider =
    Provider<ServiceRequestService>((ref) => ServiceRequestService());

final serviceRequestViewModelProvider =
    StateNotifierProvider<ServiceRequestViewModel, AsyncValue<void>>(
  (ref) => ServiceRequestViewModel(ref.watch(serviceRequestServiceProvider)),
);
