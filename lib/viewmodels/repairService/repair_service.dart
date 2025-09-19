// ignore_for_file: avoid_print

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
    }
  }

  Future<String?> getAgentPhoneNumber(String serviceType) async {
    try {
      return await _serviceRequestService.getAgentPhoneNumber(serviceType);
    } catch (e) {
      print('Erreur lors de la récupération du numéro de téléphone: $e');
      return null;
    }
  }

  Future<List<ServiceRequestModel>?> getUserRepairRequest() async {
    try {
      return await _serviceRequestService.getUserRepairRequests();
    } catch (e) {
      print('Error fetching user repair request: $e');
      return null;
    }
  }
}

final serviceRequestServiceProvider =
    Provider<ServiceRequestService>((ref) => ServiceRequestService());

final serviceRequestViewModelProvider =
    StateNotifierProvider<ServiceRequestViewModel, AsyncValue<void>>(
  (ref) => ServiceRequestViewModel(ref.watch(serviceRequestServiceProvider)),
);
