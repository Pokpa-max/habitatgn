import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitatgn/models/dailyRental/daily_rental.dart' hide Address;
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/models/reservation/reservation.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Faire une demande de réservation
  Future<bool> requestReservation({
    required String houseId,
    required String userName,
    required String userPhone,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    required int numberOfNights,
    required TimeOfDay checkInTime,
    String? message,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Utilisateur non connecté');

      final houseRef = _firestore.collection('houses').doc(houseId);
      final reservationRref = _firestore.collection('reservations').doc();

      // Vérifier que le logement est toujours disponible
      final houseDoc = await houseRef.get();
      if (!houseDoc.exists) {
        throw Exception('Logement introuvable');
      }

      final houseData = houseDoc.data()!;

      // Créer les détails de réservation
      final reservationDetails = ReservationDetails(
        userId: currentUser.uid,
        houseId: houseId,
        userName: userName,
        userPhone: userPhone,
        requestDate: DateTime.now(),
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numberOfGuests: numberOfGuests,
        numberOfNights: numberOfNights,
        checkInTime: checkInTime,
        message: message,
        status: ReservationStatus.pending,
        imageUrl: houseData['imageUrl'],
        contactPhone: houseData['phoneNumber'],
        houseType: HouseType.fromMap(houseData['houseType']),
        address: Address.fromMap(houseData['address']),
      );

      // Mettre à jour le document house
      await reservationRref.set({
        'details': reservationDetails.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Erreur lors de la demande de réservation: $e');
      return false;
    }
  }

  /// Annuler une réservation
  Future<bool> cancelReservation(String houseId) async {
    try {
      final reservationRref =
          _firestore.collection('reservations').doc(houseId);

      await reservationRref.update({
        'details.status': ReservationStatus.cancelled.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Erreur lors de l\'annulation: $e');
      return false;
    }
  }

  /// Récupérer les réservations de l'utilisateur actuel
  Future<List<Map<String, dynamic>>> getUserReservations() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final snap = await _firestore
          .collection('reservations')
          .where('details.userId', isEqualTo: currentUser.uid)
          .orderBy('details.requestDate', descending: true)
          .get();

      return snap.docs.map((doc) {
        final data = doc.data();
        return {
          'houseId': doc.id,
          'houseData': data,
          'details': ReservationDetails.fromMap(
              data['details'] as Map<String, dynamic>),
        };
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des réservations: $e');
      return [];
    }
  }

  /// Vérifier si l'utilisateur peut faire une réservation
  bool canUserReserve(Map<String, dynamic> houseData) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    // Ne peut pas réserver son propre logement
    if (houseData['userId'] == currentUser.uid) return false;

    // Ne peut réserver que si disponible
    final status = houseData['reservationStatus'] ?? 'available';
    return status == 'available';
  }

  /// Vérifier si l'utilisateur a déjà une réservation pour ce logement
  bool hasUserReserved(Map<String, dynamic> houseData) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final reservationDetails =
        houseData['reservationDetails'] as Map<String, dynamic>?;
    if (reservationDetails == null) return false;

    return reservationDetails['userId'] == currentUser.uid;
  }

  /// Obtenir le statut de réservation d'un logement
  ReservationStatus getReservationStatus(Map<String, dynamic> houseData) {
    final statusValue = houseData['reservationStatus'] ?? 'available';
    return ReservationStatus.values.firstWhere(
      (s) => s.value == statusValue,
      orElse: () => ReservationStatus.available,
    );
  }

  Future<void> launchPhoneCall(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
