import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitatgn/services/reservation/reservation_service.dart';

// ============= SERVICE PROVIDER =============

final reservationServiceProvider = Provider((ref) => ReservationService());

// ============= DATE FORMATTER =============

class DateFormatter {
  String formatDate(DateTime date) {
    const months = [
      '',
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

final dateFormatterProvider = Provider((ref) => DateFormatter());

// ============= FIRESTORE & AUTH PROVIDERS =============

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final authProvider = Provider((ref) => FirebaseAuth.instance);

// ============= ALL RESERVATIONS PROVIDER (STREAM) =============

final allReservationsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(authProvider);

  final currentUser = auth.currentUser;
  if (currentUser == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('daily_bookings')
      .where('userId', isEqualTo: currentUser.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return {
        'bookingId': doc.id,
        'bookingData': doc.data(),
      };
    }).toList();
  });
});

// ============= ACTIVE RESERVATIONS PROVIDER (STREAM) =============

final activeReservationsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(authProvider);

  final currentUser = auth.currentUser;
  if (currentUser == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('daily_bookings')
      .where('userId', isEqualTo: currentUser.uid)
      .where('status', whereIn: ['pending', 'confirmed'])
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'bookingId': doc.id,
            'bookingData': doc.data(),
          };
        }).toList();
      });
});

// ============= HISTORY RESERVATIONS PROVIDER (STREAM) =============

final historyReservationsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(authProvider);

  final currentUser = auth.currentUser;
  if (currentUser == null) {
    return Stream.value([]);
  }

  return firestore
      .collection('daily_bookings')
      .where('userId', isEqualTo: currentUser.uid)
      .where('status', whereIn: ['cancelled', 'completed'])
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'bookingId': doc.id,
            'bookingData': doc.data(),
          };
        }).toList();
      });
});

// ============= RESERVATION ACTIONS =============

class ReservationActions {
  final ReservationService _reservationService;
  final ProviderRef _ref;

  ReservationActions(this._reservationService, this._ref);

  /// Créer une nouvelle réservation
  Future<bool> createReservation({
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
      final bookingId = await _reservationService.requestReservation(
        houseId: houseId,
        guestName: guestName,
        guestPhone: guestPhone,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        totalPrice: totalPrice,
        houseImageUrl: houseImageUrl,
        notes: notes,
      );

      // Les StreamProviders se mettront à jour automatiquement
      return bookingId != null;
    } catch (e) {
      print('Erreur lors de la création de la réservation: $e');
      return false;
    }
  }

  /// Annuler une réservation
  Future<bool> cancelReservation(String bookingId) async {
    try {
      final success = await _reservationService.cancelReservation(bookingId);
      // Les StreamProviders se mettront à jour automatiquement
      return success;
    } catch (e) {
      print('Erreur lors de l\'annulation: $e');
      return false;
    }
  }

  /// Lancer un appel téléphonique
  Future<void> makePhoneCall(String phoneNumber) async {
    try {
      await _reservationService.launchPhoneCall('tel:$phoneNumber');
    } catch (e) {
      print('Erreur lors de l\'appel: $e');
      rethrow;
    }
  }

  /// Envoyer un SMS
  Future<void> sendSMS(String phoneNumber, {String? message}) async {
    try {
      await _reservationService.launchSMS(phoneNumber, message: message);
    } catch (e) {
      print('Erreur lors de l\'envoi du SMS: $e');
      rethrow;
    }
  }
}

// ============= RESERVATION ACTIONS PROVIDER =============

final reservationActionsProvider = Provider((ref) {
  final reservationService = ref.watch(reservationServiceProvider);
  return ReservationActions(reservationService, ref);
});

// ============= UTILITY FUNCTIONS =============

/// Obtenir le label du statut
String getStatusLabel(String status) {
  switch (status) {
    case 'pending':
      return 'En attente';
    case 'confirmed':
      return 'Confirmée';
    case 'cancelled':
      return 'Annulée';
    case 'completed':
      return 'Complétée';
    default:
      return status;
  }
}

/// Obtenir la couleur du statut
Color getStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'confirmed':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    case 'completed':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

/// Obtenir l'icône du statut
IconData getStatusIcon(String status) {
  switch (status) {
    case 'pending':
      return Icons.hourglass_empty;
    case 'confirmed':
      return Icons.check_circle;
    case 'cancelled':
      return Icons.cancel;
    case 'completed':
      return Icons.task_alt;
    default:
      return Icons.info;
  }
}
