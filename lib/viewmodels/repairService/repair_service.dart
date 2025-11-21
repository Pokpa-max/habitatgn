

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitatgn/models/service.dart';
import 'package:habitatgn/services/repairs/repair_servicies.dart';

// ============= SERVICE PROVIDERS =============

final serviceRequestServiceProvider =
    Provider<ServiceRequestService>((ref) => ServiceRequestService());

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final authProvider = Provider((ref) => FirebaseAuth.instance);

// ============= ALL REPAIR REQUESTS PROVIDER (STREAM) =============

final allRepairRequestsProvider =
    StreamProvider<List<ServiceRequestModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(authProvider);

  final currentUser = auth.currentUser;
  if (currentUser == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('service_requests')
      .where('userId', isEqualTo: currentUser.uid)
      .orderBy('scheduledDate', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return ServiceRequestModel.fromJson(doc.data());
    }).toList();
  });
});

// ============= IN PROGRESS REQUESTS PROVIDER (STREAM) =============

final inProgressRequestsProvider =
    StreamProvider<List<ServiceRequestModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(authProvider);

  final currentUser = auth.currentUser;
  if (currentUser == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('service_requests')
      .where('userId', isEqualTo: currentUser.uid)
      .where('status', whereIn: ['pending', 'in_progress'])
      .orderBy('scheduledDate', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ServiceRequestModel.fromJson(doc.data());
        }).toList();
      });
});

// ============= COMPLETED REQUESTS PROVIDER (STREAM) =============

final completedRequestsProvider =
    StreamProvider<List<ServiceRequestModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(authProvider);

  final currentUser = auth.currentUser;
  if (currentUser == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('service_requests')
      .where('userId', isEqualTo: currentUser.uid)
      .where('status', isEqualTo: 'completed')
      .orderBy('scheduledDate', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return ServiceRequestModel.fromJson(doc.data());
    }).toList();
  });
});

// ============= SERVICE ACTIONS =============

class ServiceRequestActions {
  final ServiceRequestService _service;
  // ignore: unused_field
  final ProviderRef _ref;

  ServiceRequestActions(this._service, this._ref);

  /// Soumettre une nouvelle demande de service
  Future<bool> submitRequest(ServiceRequestModel request) async {
    try {
      await _service.submitRequest(request);
      // Les StreamProviders se mettront à jour automatiquement
      return true;
    } catch (e) {
      print('Erreur lors de la soumission: $e');
      return false;
    }
  }

  /// Obtenir le numéro de téléphone de l'agent
  Future<String?> getAgentPhoneNumber(String serviceType) async {
    try {
      return await _service.getAgentPhoneNumber(serviceType);
    } catch (e) {
      print('Erreur lors de la récupération du numéro: $e');
      return null;
    }
  }
}

// ============= SERVICE ACTIONS PROVIDER =============

final serviceRequestActionsProvider = Provider((ref) {
  final service = ref.watch(serviceRequestServiceProvider);
  return ServiceRequestActions(service, ref);
});

// ============= STATUS UTILITIES =============

String getStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 'En attente';
    case 'in_progress':
      return 'En cours';
    case 'completed':
      return 'Terminé';
    case 'cancelled':
      return 'Annulé';
    default:
      return status;
  }
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'in_progress':
      return Colors.blue;
    case 'completed':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

IconData getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Icons.schedule;
    case 'in_progress':
      return Icons.hourglass_bottom;
    case 'completed':
      return Icons.check_circle;
    case 'cancelled':
      return Icons.cancel;
    default:
      return Icons.info;
  }
}
