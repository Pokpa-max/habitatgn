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
  Future<String?> requestReservation({
    required String houseId,
    required String guestName,
    required String guestPhone,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required double totalPrice,
    required String houseImageUrl,
    String? notes,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Utilisateur non connecté');

      final houseRef = _firestore.collection('houses').doc(houseId);
      final bookingRef = _firestore.collection('daily_bookings').doc();

      // Vérifier que le logement existe toujours
      final houseDoc = await houseRef.get();
      if (!houseDoc.exists) {
        throw Exception('Logement introuvable');
      }

      // Créer la réservation
      await bookingRef.set({
        'userId': currentUser.uid,
        'houseId': houseId,
        'guestName': guestName,
        'guestPhone': guestPhone,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'guests': guests,
        'houseImageUrl': houseImageUrl,
        'notes': notes ?? '',
        'status': 'pending',
        'totalPrice': totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return bookingRef.id;
    } catch (e) {
      print('Erreur lors de la demande de réservation: $e');
      return null;
    }
  }

  /// Annuler une réservation
  Future<bool> cancelReservation(String bookingId) async {
    try {
      final bookingRef = _firestore.collection('daily_bookings').doc(bookingId);

      await bookingRef.update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Erreur lors de l\'annulation: $e');
      return false;
    }
  }

  /// Mettre à jour le statut d'une réservation
  Future<bool> updateReservationStatus(
      String bookingId, String newStatus) async {
    try {
      await _firestore.collection('daily_bookings').doc(bookingId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      return false;
    }
  }

  /// Récupérer les réservations de l'utilisateur actuel
  Future<List<Map<String, dynamic>>> getUserReservations() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final snap = await _firestore
          .collection('daily_bookings')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snap.docs.map((doc) {
        return {
          'bookingId': doc.id,
          'bookingData': doc.data(),
        };
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des réservations: $e');
      return [];
    }
  }

  /// Récupérer les réservations d'un logement spécifique
  Future<List<Map<String, dynamic>>> getHouseReservations(
      String houseId) async {
    try {
      final snap = await _firestore
          .collection('daily_bookings')
          .where('houseId', isEqualTo: houseId)
          .where('status', isNotEqualTo: 'cancelled')
          .orderBy('status')
          .orderBy('checkIn', descending: false)
          .get();

      return snap.docs.map((doc) {
        return {
          'bookingId': doc.id,
          'bookingData': doc.data(),
        };
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des réservations du logement: $e');
      return [];
    }
  }

  /// Vérifier si l'utilisateur peut faire une réservation
  bool canUserReserve(Map<String, dynamic> houseData) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    // Ne peut pas réserver son propre logement
    if (houseData['userId'] == currentUser.uid) return false;

    return true;
  }

  /// Vérifier s'il y a un chevauchement de dates
  bool hasDateConflict(
    List<Map<String, dynamic>> bookings,
    DateTime checkIn,
    DateTime checkOut,
  ) {
    for (var booking in bookings) {
      final bookingData = booking['bookingData'] as Map<String, dynamic>;
      if (bookingData['status'] == 'cancelled') continue;

      final bookingCheckIn = (bookingData['checkIn'] as Timestamp).toDate();
      final bookingCheckOut = (bookingData['checkOut'] as Timestamp).toDate();

      // Vérifier chevauchement
      if (checkIn.isBefore(bookingCheckOut) &&
          checkOut.isAfter(bookingCheckIn)) {
        return true;
      }
    }
    return false;
  }

  /// Obtenir le statut d'une réservation
  String getReservationStatus(Map<String, dynamic> bookingData) {
    return bookingData['status'] ?? 'pending';
  }

  /// Récupérer une réservation par ID
  Future<Map<String, dynamic>?> getReservationById(String bookingId) async {
    try {
      final doc =
          await _firestore.collection('daily_bookings').doc(bookingId).get();
      if (!doc.exists) return null;

      return {
        'bookingId': doc.id,
        'bookingData': doc.data(),
      };
    } catch (e) {
      print('Erreur lors de la récupération de la réservation: $e');
      return null;
    }
  }

  /// Lancer un appel téléphonique
  Future<void> launchPhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Impossible d\'appeler $phoneNumber');
    }
  }

  /// Lancer un SMS
  Future<void> launchSMS(String phoneNumber, {String? message}) async {
    final url = 'sms:$phoneNumber${message != null ? '?body=$message' : ''}';
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Impossible d\'envoyer un SMS à $phoneNumber');
    }
  }
}
