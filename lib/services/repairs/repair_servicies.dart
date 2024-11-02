import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/service.dart';
import 'package:habitatgn/viewmodels/repairService/repair_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late SharedPreferences _prefs;
  static const String _phonePrefix = 'service_phone_';

  ServiceRequestService() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> submitRequest(ServiceRequestModel request) async {
    try {
      await _firestore.collection('serviceRequests').add(request.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la soumission: $e');
    }
  }

  Future<String?> getAgentPhoneNumber(String serviceType) async {
    // Vérifier d'abord dans SharedPreferences
    await _initPrefs();
    String? cachedPhone = _prefs.getString('$_phonePrefix$serviceType');
    if (cachedPhone != null) {
      return cachedPhone;
    }

    try {
      final querySnapshot = await _firestore
          .collection('services')
          .where('type', isEqualTo: serviceType)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String? phoneNumber =
            querySnapshot.docs.first.data()['phoneNumber'] as String?;
        if (phoneNumber != null) {
          // Sauvegarder dans SharedPreferences
          await _prefs.setString('$_phonePrefix$serviceType', phoneNumber);
        }
        return phoneNumber;
      }
    } catch (e) {
      print('Erreur lors de la récupération du numéro de téléphone: $e');
      // En cas d'erreur, retourner le numéro en cache s'il existe
      return cachedPhone;
    }
    return null;
  }
}

// Les providers restent identiques
final serviceRequestServiceProvider = Provider<ServiceRequestService>(
  (ref) => ServiceRequestService(),
);
