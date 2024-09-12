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
