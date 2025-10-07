import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitatgn/models/dailyRental/daily_rental.dart';

class DailyRentalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _rentalsCollection =>
      _firestore.collection('daily_rentals');
  CollectionReference get _bookingsCollection =>
      _firestore.collection('daily_bookings');
  CollectionReference get _favoritesCollection =>
      _firestore.collection('favorites');

  String? get _currentUserId => _auth.currentUser?.uid;

  // ==================== RENTALS (basique) ====================

  /// Récupérer toutes les locations journalières (sans pagination)
  Future<List<DailyRental>> getAllRentals() async {
    try {
      final snapshot = await _rentalsCollection
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DailyRental.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des locations: $e');
    }
  }

  /// Récupérer une location par ID
  Future<DailyRental?> getRentalById(String rentalId) async {
    try {
      final doc = await _rentalsCollection.doc(rentalId).get();

      if (!doc.exists) {
        throw Exception('Location non trouvée');
      }

      return DailyRental.fromFirestore(doc);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la location: $e');
    }
  }

  // ==================== PAGINATION ====================

  /// Récupérer les locations avec pagination
  Future<Map<String, dynamic>> getRentalsWithPagination({
    int limit = 10,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query = _rentalsCollection
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();

      final rentals =
          snapshot.docs.map((doc) => DailyRental.fromFirestore(doc)).toList();

      return {
        'rentals': rentals,
        'lastDoc': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des locations: $e');
    }
  }

  // ==================== RECHERCHE RAPIDE ====================

  /// Recherche rapide par texte (ville, commune, type)
  Future<Map<String, dynamic>> quickTextSearch({
    required String query,
    int limit = 10,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      final lowerQuery = query.toLowerCase().trim();

      // Récupérer toutes les locations disponibles
      final snapshot = await _rentalsCollection
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(100) // Limite plus grande pour filtrer côté client
          .get();

      // Filtrer côté client pour recherche flexible
      final rentals = snapshot.docs
          .map((doc) => DailyRental.fromFirestore(doc))
          .where((rental) {
            final houseType = rental.houseType?.label.toLowerCase() ?? '';
            final town = rental.address?.town.label.toLowerCase() ?? '';
            final commune = rental.address?.commune.label.toLowerCase() ?? '';
            final zone = rental.address?.zone.toLowerCase() ?? '';

            return houseType.contains(lowerQuery) ||
                town.contains(lowerQuery) ||
                commune.contains(lowerQuery) ||
                zone.contains(lowerQuery);
          })
          .take(limit)
          .toList();

      return {
        'rentals': rentals,
        'lastDoc': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      };
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  // ==================== FILTRES AVANCÉS ====================

  /// Rechercher avec filtres avancés
  Future<Map<String, dynamic>> searchWithFilters({
    int? minPrice,
    int? maxPrice,
    String? propertyType,
    String? ville,
    int? minGuests,
    DateTime? checkIn,
    DateTime? checkOut,
    int limit = 10,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query = _rentalsCollection.where('isAvailable', isEqualTo: true);

      // Filtres Firestore (limités aux champs indexables)
      if (minPrice != null) {
        query = query.where('pricePerNight', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('pricePerNight', isLessThanOrEqualTo: maxPrice);
      }

      if (minGuests != null) {
        query = query.where('maxGuests', isGreaterThanOrEqualTo: minGuests);
      }

      query = query.orderBy('pricePerNight', descending: false).limit(100);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();

      // Filtrage côté client pour les champs complexes
      List<DailyRental> rentals =
          snapshot.docs.map((doc) => DailyRental.fromFirestore(doc)).toList();

      // Filtrer par type de propriété
      if (propertyType != null && propertyType.isNotEmpty) {
        rentals = rentals.where((rental) {
          return rental.houseType?.label.toLowerCase() ==
              propertyType.toLowerCase();
        }).toList();
      }

      // Filtrer par ville
      if (ville != null && ville.isNotEmpty) {
        rentals = rentals.where((rental) {
          final town = rental.address?.town.label.toLowerCase() ?? '';
          final commune = rental.address?.commune.label.toLowerCase() ?? '';
          final lowerVille = ville.toLowerCase();
          return town.contains(lowerVille) || commune.contains(lowerVille);
        }).toList();
      }

      // Filtrer par disponibilité de dates
      if (checkIn != null && checkOut != null) {
        List<DailyRental> availableRentals = [];
        for (var rental in rentals) {
          final isAvailable = await checkAvailability(
            houseId: rental.id,
            checkIn: checkIn,
            checkOut: checkOut,
          );
          if (isAvailable) {
            availableRentals.add(rental);
          }
        }
        rentals = availableRentals;
      }

      // Limiter les résultats
      final limitedRentals = rentals.take(limit).toList();

      return {
        'rentals': limitedRentals,
        'lastDoc': snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      };
    } catch (e) {
      throw Exception('Erreur lors de la recherche avec filtres: $e');
    }
  }

  /// Rechercher des locations (méthode originale simplifiée)
  Future<List<DailyRental>> searchRentals({
    String? commune,
    int? minPrice,
    int? maxPrice,
    int? minGuests,
    int? bedrooms,
  }) async {
    try {
      Query query = _rentalsCollection.where('isAvailable', isEqualTo: true);

      if (minPrice != null) {
        query = query.where('pricePerNight', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('pricePerNight', isLessThanOrEqualTo: maxPrice);
      }

      if (minGuests != null) {
        query = query.where('maxGuests', isGreaterThanOrEqualTo: minGuests);
      }

      if (bedrooms != null) {
        query = query.where('bedrooms', isGreaterThanOrEqualTo: bedrooms);
      }

      final snapshot = await query.get();
      List<DailyRental> rentals =
          snapshot.docs.map((doc) => DailyRental.fromFirestore(doc)).toList();

      // Filtrer par commune (nested field)
      if (commune != null) {
        rentals = rentals
            .where((rental) =>
                rental.address?.commune.label.toLowerCase() ==
                commune.toLowerCase())
            .toList();
      }

      return rentals;
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  // ==================== AVAILABILITY ====================

  /// Vérifier la disponibilité pour des dates données
  Future<bool> checkAvailability({
    required String houseId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    try {
      // Vérifier si la location existe et est disponible
      final rentalDoc = await _rentalsCollection.doc(houseId).get();
      if (!rentalDoc.exists) {
        return false;
      }

      final rental = DailyRental.fromFirestore(rentalDoc);
      if (!rental.isAvailable) {
        return false;
      }

      // Vérifier s'il y a des réservations qui se chevauchent
      final bookingsSnapshot = await _bookingsCollection
          .where('houseId', isEqualTo: houseId)
          .where('status', whereIn: ['pending', 'confirmed']).get();

      for (var bookingDoc in bookingsSnapshot.docs) {
        final bookingData = bookingDoc.data() as Map<String, dynamic>;
        final bookedCheckIn = (bookingData['checkIn'] as Timestamp).toDate();
        final bookedCheckOut = (bookingData['checkOut'] as Timestamp).toDate();

        // Vérifier le chevauchement
        if (checkIn.isBefore(bookedCheckOut) &&
            checkOut.isAfter(bookedCheckIn)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      throw Exception('Erreur lors de la vérification de disponibilité: $e');
    }
  }

  /// Obtenir les dates réservées pour une location
  Future<List<Map<String, DateTime>>> getBookedDates(String houseId) async {
    try {
      final bookingsSnapshot = await _bookingsCollection
          .where('houseId', isEqualTo: houseId)
          .where('status', whereIn: ['pending', 'confirmed']).get();

      return bookingsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'checkIn': (data['checkIn'] as Timestamp).toDate(),
          'checkOut': (data['checkOut'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des dates: $e');
    }
  }

  // ==================== BOOKINGS ====================

  /// Créer une nouvelle réservation
  Future<String?> createBooking({
    required String houseId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required double totalPrice,
    String? notes,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier la disponibilité avant de créer la réservation
      final isAvailable = await checkAvailability(
        houseId: houseId,
        checkIn: checkIn,
        checkOut: checkOut,
      );

      if (!isAvailable) {
        throw Exception('Cette période n\'est pas disponible');
      }

      // Créer la réservation
      final bookingData = {
        'houseId': houseId,
        'userId': _currentUserId,
        'checkIn': Timestamp.fromDate(checkIn),
        'checkOut': Timestamp.fromDate(checkOut),
        'guests': guests,
        'totalPrice': totalPrice,
        'notes': notes ?? '',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _bookingsCollection.add(bookingData);

      // Créer une notification (optionnel)
      await _createBookingNotification(houseId, docRef.id);

      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de la réservation: $e');
    }
  }

  /// Récupérer les réservations de l'utilisateur
  Future<List<Map<String, dynamic>>> getUserBookings() async {
    try {
      if (_currentUserId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final snapshot = await _bookingsCollection
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> bookings = [];

      for (var doc in snapshot.docs) {
        final bookingData = doc.data() as Map<String, dynamic>;
        final rental = await getRentalById(bookingData['houseId']);

        bookings.add({
          'bookingId': doc.id,
          'rental': rental,
          'checkIn': (bookingData['checkIn'] as Timestamp).toDate(),
          'checkOut': (bookingData['checkOut'] as Timestamp).toDate(),
          'guests': bookingData['guests'],
          'totalPrice': bookingData['totalPrice'],
          'status': bookingData['status'],
          'notes': bookingData['notes'],
          'createdAt': (bookingData['createdAt'] as Timestamp?)?.toDate(),
        });
      }

      return bookings;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réservations: $e');
    }
  }

  /// Annuler une réservation
  Future<void> cancelBooking(String bookingId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('Utilisateur non connecté');
      }

      await _bookingsCollection.doc(bookingId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation: $e');
    }
  }

  // ==================== FAVORITES ====================

  /// Vérifier si une location est dans les favoris
  Future<bool> isFavorite(String rentalId) async {
    try {
      if (_currentUserId == null) return false;

      final doc =
          await _favoritesCollection.doc('${_currentUserId}_$rentalId').get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Ajouter/retirer des favoris
  Future<void> toggleFavorite(String rentalId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final docId = '${_currentUserId}_$rentalId';
      final doc = await _favoritesCollection.doc(docId).get();

      if (doc.exists) {
        await _favoritesCollection.doc(docId).delete();
      } else {
        await _favoritesCollection.doc(docId).set({
          'userId': _currentUserId,
          'rentalId': rentalId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Erreur lors de la modification des favoris: $e');
    }
  }

  /// Récupérer les locations favorites
  Future<List<DailyRental>> getFavoriteRentals() async {
    try {
      if (_currentUserId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final favSnapshot = await _favoritesCollection
          .where('userId', isEqualTo: _currentUserId)
          .get();

      List<DailyRental> favorites = [];

      for (var doc in favSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final rentalId = data['rentalId'] as String;

        try {
          final rental = await getRentalById(rentalId);
          if (rental != null) {
            favorites.add(rental);
          }
        } catch (e) {
          continue;
        }
      }

      return favorites;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des favoris: $e');
    }
  }

  // ==================== NOTIFICATIONS ====================

  Future<void> _createBookingNotification(
      String houseId, String bookingId) async {
    try {
      final rental = await getRentalById(houseId);
      if (rental == null) return;

      await _firestore.collection('notifications').add({
        'type': 'new_booking',
        'bookingId': bookingId,
        'rentalId': houseId,
        'userId': _currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      // Ne pas bloquer la réservation
      print('Erreur notification: $e');
    }
  }

  // ==================== STATISTICS ====================

  Future<Map<String, dynamic>> getRentalStatistics(String rentalId) async {
    try {
      final bookingsSnapshot =
          await _bookingsCollection.where('houseId', isEqualTo: rentalId).get();

      int totalBookings = bookingsSnapshot.docs.length;
      int confirmedBookings = bookingsSnapshot.docs
          .where((doc) =>
              (doc.data() as Map<String, dynamic>)['status'] == 'confirmed')
          .length;

      double totalRevenue = 0;
      for (var doc in bookingsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['status'] == 'confirmed' || data['status'] == 'completed') {
          totalRevenue += (data['totalPrice'] ?? 0).toDouble();
        }
      }

      return {
        'totalBookings': totalBookings,
        'confirmedBookings': confirmedBookings,
        'totalRevenue': totalRevenue,
        'averageBookingValue':
            confirmedBookings > 0 ? totalRevenue / confirmedBookings : 0,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}
