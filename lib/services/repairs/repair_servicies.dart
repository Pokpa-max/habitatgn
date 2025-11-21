// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late SharedPreferences _prefs;
  static const String _phonePrefix = 'service_phone_';

  ServiceRequestService() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Soumettre une nouvelle demande de service
  Future<String> submitRequest(ServiceRequestModel request) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Préparer les données avec tous les champs nécessaires
      final data = {
        'userId': currentUser.uid,
        'serviceType': request.serviceType,
        'name': request.name,
        'phone': request.phone,
        'address': request.address,
        'description': request.description,
        'scheduledDate': request.scheduledDate,
        'scheduledTime': request.scheduledTime,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Ajouter le document et récupérer l'ID
      final docRef = await _firestore.collection('service_requests').add(data);

      return docRef.id;
    } catch (e) {
      print('❌ Erreur lors de la soumission: $e');
      throw Exception('Erreur lors de la soumission: $e');
    }
  }

  /// Obtenir le numéro de téléphone de l'agent
  Future<String?> getAgentPhoneNumber(String serviceType) async {
    try {
      await _initPrefs();

      // Vérifier d'abord dans SharedPreferences
      String? cachedPhone = _prefs.getString('$_phonePrefix$serviceType');
      if (cachedPhone != null) {
        print('📱 Numéro trouvé en cache: $cachedPhone');
        return cachedPhone;
      }

      // Chercher dans Firestore
      final querySnapshot = await _firestore
          .collection('services')
          .where('type', isEqualTo: serviceType)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final phoneNumber =
            querySnapshot.docs.first.data()['phoneNumber'] as String?;

        if (phoneNumber != null) {
          // Sauvegarder dans SharedPreferences
          await _prefs.setString('$_phonePrefix$serviceType', phoneNumber);
        }
        return phoneNumber;
      }

      return null;
    } catch (e) {
      print('❌ Erreur lors de la récupération du numéro: $e');
      return null;
    }
  }

  /// Obtenir les demandes de l'utilisateur actuel
  Future<List<ServiceRequestModel>> getUserRepairRequests() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection('service_requests')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final List<ServiceRequestModel> requests = querySnapshot.docs
          .map((doc) {
            try {
              return ServiceRequestModel.fromJson(doc.data());
            } catch (e) {
              print('⚠️ Erreur lors du parsing du document: $e');
              return null;
            }
          })
          .whereType<ServiceRequestModel>()
          .toList();

      return requests;
    } catch (e) {
      print('❌ Erreur lors de la récupération des demandes: $e');
      return [];
    }
  }

  /// Mettre à jour le statut d'une demande
  Future<bool> updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour: $e');
      return false;
    }
  }

  /// Annuler une demande
  Future<bool> cancelRequest(String requestId) async {
    try {
      await _firestore.collection('service_requests').doc(requestId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('❌ Erreur lors de l\'annulation: $e');
      return false;
    }
  }
}

// Provider
final serviceRequestServiceProvider = Provider<ServiceRequestService>(
  (ref) => ServiceRequestService(),
);
