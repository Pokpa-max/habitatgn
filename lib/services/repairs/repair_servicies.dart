// lib/services/service_request_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitatgn/models/service.dart';

class ServiceRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitRequest(ServiceRequestModel request) async {
    try {
      await _firestore.collection('serviceRequests').add(request.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la soumission: $e');
    }
  }
}
