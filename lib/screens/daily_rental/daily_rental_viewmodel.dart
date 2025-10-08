// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:habitatgn/models/dailyRental/daily_rental.dart';
// import 'package:habitatgn/services/dailyRental/daily_rental_service.dart';

// import 'package:url_launcher/url_launcher.dart';

// // Provider pour le ViewModel
// final dailyRentalViewModelProvider =
//     ChangeNotifierProvider((ref) => DailyRentalViewModel());

// class DailyRentalViewModel extends ChangeNotifier {
//   final DailyRentalService _service = DailyRentalService();

//   List<DailyRental> _rentals = [];
//   List<DailyRental> get rentals => _rentals;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;

//   // Récupérer toutes les locations journalières
//   Future<void> fetchAllRentals() async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       _rentals = await _service.getAllRentals();
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Erreur lors du chargement des locations';
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Récupérer une location par ID
//   Future<DailyRental?> fetchRentalById(String rentalId) async {
//     try {
//       return await _service.getRentalById(rentalId);
//     } catch (e) {
//       _errorMessage = 'Erreur lors du chargement de la location';
//       notifyListeners();
//       return null;
//     }
//   }

//   // Rechercher des locations avec filtres
//   Future<void> searchRentals({
//     String? commune,
//     int? minPrice,
//     int? maxPrice,
//     int? minGuests,
//     int? bedrooms,
//   }) async {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     try {
//       _rentals = await _service.searchRentals(
//         commune: commune,
//         minPrice: minPrice,
//         maxPrice: maxPrice,
//         minGuests: minGuests,
//         bedrooms: bedrooms,
//       );
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Erreur lors de la recherche';
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Vérifier si une location est dans les favoris
//   Future<bool> isFavorite(String rentalId) async {
//     try {
//       return await _service.isFavorite(rentalId);
//     } catch (e) {
//       return false;
//     }
//   }

//   // Ajouter/retirer des favoris
//   Future<void> toggleFavorite(String rentalId) async {
//     try {
//       await _service.toggleFavorite(rentalId);
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Erreur lors de la modification des favoris';
//       notifyListeners();
//       rethrow;
//     }
//   }

//   // Récupérer les favoris de l'utilisateur
//   Future<List<DailyRental>> getFavoriteRentals() async {
//     try {
//       return await _service.getFavoriteRentals();
//     } catch (e) {
//       _errorMessage = 'Erreur lors du chargement des favoris';
//       notifyListeners();
//       return [];
//     }
//   }

//   // Lancer un appel téléphonique
//   Future<void> launchPhoneCall(String phoneUrl) async {
//     try {
//       final Uri uri = Uri.parse(phoneUrl);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri);
//       } else {
//         throw 'Impossible d\'appeler ce numéro';
//       }
//     } catch (e) {
//       _errorMessage = 'Erreur lors de l\'appel';
//       notifyListeners();
//       rethrow;
//     }
//   }

//   // Filtrer les locations disponibles
//   List<DailyRental> getAvailableRentals() {
//     return _rentals.where((rental) => rental.isAvailable).toList();
//   }

//   // Trier les locations par prix
//   void sortByPrice({bool ascending = true}) {
//     _rentals.sort((a, b) => ascending
//         ? a.pricePerNight.compareTo(b.pricePerNight)
//         : b.pricePerNight.compareTo(a.pricePerNight));
//     notifyListeners();
//   }

//   // Trier par capacité d'invités
//   void sortByCapacity({bool ascending = true}) {
//     _rentals.sort((a, b) => ascending
//         ? a.maxGuests.compareTo(b.maxGuests)
//         : b.maxGuests.compareTo(a.maxGuests));
//     notifyListeners();
//   }

//   // Trier par superficie
//   void sortByArea({bool ascending = true}) {
//     _rentals.sort((a, b) =>
//         ascending ? a.area.compareTo(b.area) : b.area.compareTo(a.area));
//     notifyListeners();
//   }

//   // Filtrer par commune
//   List<DailyRental> filterByCommune(String commune) {
//     return _rentals
//         .where((rental) =>
//             rental.address?.commune.label.toLowerCase() ==
//             commune.toLowerCase())
//         .toList();
//   }

//   // Filtrer par nombre de chambres
//   List<DailyRental> filterByBedrooms(int bedrooms) {
//     return _rentals.where((rental) => rental.bedrooms >= bedrooms).toList();
//   }

//   // Filtrer par gamme de prix
//   List<DailyRental> filterByPriceRange(int minPrice, int maxPrice) {
//     return _rentals
//         .where((rental) =>
//             rental.pricePerNight >= minPrice &&
//             rental.pricePerNight <= maxPrice)
//         .toList();
//   }

//   // Obtenir les locations recommandées (les plus populaires/récentes)
//   List<DailyRental> getRecommendedRentals({int limit = 5}) {
//     final available = getAvailableRentals();
//     available.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//     return available.take(limit).toList();
//   }

//   // Réinitialiser les filtres
//   void resetFilters() {
//     fetchAllRentals();
//   }

//   // Nettoyer les erreurs
//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/dailyRental/daily_rental.dart';
import 'package:habitatgn/services/dailyRental/daily_rental_service.dart';
import 'package:url_launcher/url_launcher.dart';

// Provider pour le ViewModel
final dailyRentalViewModelProvider =
    ChangeNotifierProvider((ref) => DailyRentalViewModel());

class DailyRentalViewModel extends ChangeNotifier {
  final DailyRentalService _service = DailyRentalService();

  // ============ État principal ============
  List<DailyRental> _rentals = [];
  List<DailyRental> get rentals => _rentals;

  List<DailyRental> _searchResults = [];
  List<DailyRental> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ============ Pagination ============
  static const int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  DocumentSnapshot? _lastSearchDocument;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _hasMoreSearch = true;
  bool get hasMoreSearch => _hasMoreSearch;

  // ============ Mode recherche ============
  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  // ============ Filtres actifs ============
  Map<String, dynamic> _activeFilters = {};
  bool get hasActiveFilters => _activeFilters.isNotEmpty;

  String get filtersDescription {
    if (_activeFilters.isEmpty) return '';

    List<String> descriptions = [];

    if (_activeFilters['propertyType'] != null &&
        _activeFilters['propertyType'] != 'Tous') {
      descriptions.add(_activeFilters['propertyType']);
    }

    if (_activeFilters['ville'] != null &&
        _activeFilters['ville'].toString().isNotEmpty) {
      descriptions.add(_activeFilters['ville']);
    }

    if (_activeFilters['minGuests'] != null &&
        _activeFilters['minGuests'] > 0) {
      descriptions.add('${_activeFilters['minGuests']}+ invités');
    }

    if (_activeFilters['minPrice'] != null ||
        _activeFilters['maxPrice'] != null) {
      final min = _activeFilters['minPrice']?.toInt() ?? 0;
      final max = _activeFilters['maxPrice']?.toInt() ?? 0;
      if (min > 0 && max > 0) {
        descriptions.add('$min - $max GNF');
      } else if (min > 0) {
        descriptions.add('Min $min GNF');
      } else if (max > 0) {
        descriptions.add('Max $max GNF');
      }
    }

    if (_activeFilters['nights'] != null) {
      descriptions.add('${_activeFilters['nights']} nuits');
    }

    return descriptions.join(' • ');
  }

  // ============ Récupération avec pagination ============

  /// Récupérer les locations avec pagination
  Future<void> fetchRentals() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _service.getRentalsWithPagination(
        limit: _pageSize,
        lastDoc: _lastDocument,
      );

      if (result['rentals'].isEmpty) {
        _hasMore = false;
      } else {
        _rentals.addAll(result['rentals'] as List<DailyRental>);
        _lastDocument = result['lastDoc'];
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des locations';
      debugPrint('Error fetching rentals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialiser et recharger les locations
  void resetRentals() {
    _rentals.clear();
    _lastDocument = null;
    _hasMore = true;
    notifyListeners();
  }

  /// Rafraîchir toutes les données
  Future<void> refreshAll() async {
    resetRentals();
    _searchResults.clear();
    _lastSearchDocument = null;
    _hasMoreSearch = true;
    _isSearchActive = false;
    _activeFilters.clear();
    await fetchRentals();
  }

  // ============ Recherche rapide par texte ============

  /// Recherche rapide par texte (ville, commune, type)
  Future<void> quickTextSearch(String query) async {
    if (query.trim().isEmpty) {
      deactivateSearchMode();
      return;
    }

    _isSearchActive = true;
    _isLoading = true;
    _searchResults.clear();
    _lastSearchDocument = null;
    _hasMoreSearch = true;
    notifyListeners();

    try {
      final result = await _service.quickTextSearch(
        query: query,
        limit: _pageSize,
      );

      _searchResults = result['rentals'] as List<DailyRental>;
      _lastSearchDocument = result['lastDoc'];
      _hasMoreSearch = _searchResults.length >= _pageSize;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors de la recherche';
      debugPrint('Error in quick search: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger plus de résultats de recherche
  Future<void> loadMoreSearch() async {
    if (_isLoading || !_hasMoreSearch) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Ici vous devriez implémenter la logique pour charger plus de résultats
      // Pour l'instant, on désactive juste hasMoreSearch
      _hasMoreSearch = false;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement';
      debugPrint('Error loading more search: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Désactiver le mode recherche
  void deactivateSearchMode() {
    _isSearchActive = false;
    _searchResults.clear();
    _lastSearchDocument = null;
    _hasMoreSearch = true;
    notifyListeners();
  }

  // ============ Filtres avancés ============

  /// Appliquer des filtres
  Future<void> applyFilters({
    double? minPrice,
    double? maxPrice,
    String? propertyType,
    String? ville,
    int? minGuests,
    DateTime? checkIn,
    DateTime? checkOut,
    int? nights,
  }) async {
    _isSearchActive = true;
    _isLoading = true;
    _searchResults.clear();
    _lastSearchDocument = null;
    _hasMoreSearch = true;

    // Sauvegarder les filtres actifs
    _activeFilters = {
      if (minPrice != null && minPrice > 0) 'minPrice': minPrice,
      if (maxPrice != null && maxPrice > 0) 'maxPrice': maxPrice,
      if (propertyType != null && propertyType != 'Tous')
        'propertyType': propertyType,
      if (ville != null && ville.isNotEmpty) 'ville': ville,
      if (minGuests != null && minGuests > 0) 'minGuests': minGuests,
      if (checkIn != null) 'checkIn': checkIn,
      if (checkOut != null) 'checkOut': checkOut,
      if (nights != null && nights > 0) 'nights': nights,
    };

    notifyListeners();

    try {
      final result = await _service.searchWithFilters(
        minPrice: minPrice?.toInt(),
        maxPrice: maxPrice?.toInt(),
        propertyType: propertyType != 'Tous' ? propertyType : null,
        ville: ville?.isNotEmpty == true ? ville : null,
        minGuests: minGuests,
        checkIn: checkIn,
        checkOut: checkOut,
        limit: _pageSize,
      );

      _searchResults = result['rentals'] as List<DailyRental>;
      _lastSearchDocument = result['lastDoc'];
      _hasMoreSearch = _searchResults.length >= _pageSize;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'application des filtres';
      debugPrint('Error applying filters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ Méthodes originales conservées ============

  /// Récupérer toutes les locations (sans pagination)
  Future<void> fetchAllRentals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rentals = await _service.getAllRentals();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des locations';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer une location par ID
  Future<DailyRental?> fetchRentalById(String rentalId) async {
    try {
      return await _service.getRentalById(rentalId);
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement de la location';
      notifyListeners();
      return null;
    }
  }

  /// Rechercher des locations avec filtres (méthode originale)
  Future<void> searchRentals({
    String? commune,
    int? minPrice,
    int? maxPrice,
    int? minGuests,
    int? bedrooms,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rentals = await _service.searchRentals(
        commune: commune,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minGuests: minGuests,
        bedrooms: bedrooms,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la recherche';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============ Favoris ============

  /// Vérifier si une location est dans les favoris
  Future<bool> isFavorite(String rentalId) async {
    try {
      return await _service.isFavorite(rentalId);
    } catch (e) {
      return false;
    }
  }

  /// Ajouter/retirer des favoris
  Future<void> toggleFavorite(String rentalId) async {
    try {
      await _service.toggleFavorite(rentalId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification des favoris';
      notifyListeners();
      rethrow;
    }
  }

  /// Récupérer les favoris de l'utilisateur
  Future<List<DailyRental>> getFavoriteRentals() async {
    try {
      return await _service.getFavoriteRentals();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des favoris';
      notifyListeners();
      return [];
    }
  }

  // ============ Actions externes ============

  /// Lancer un appel téléphonique
  Future<void> launchPhoneCall(String phoneUrl) async {
    try {
      final Uri uri = Uri.parse(phoneUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Impossible d\'appeler ce numéro';
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'appel';
      notifyListeners();
      rethrow;
    }
  }

  // ============ Filtres locaux ============

  /// Filtrer les locations disponibles
  List<DailyRental> getAvailableRentals() {
    return _rentals.where((rental) => rental.isAvailable).toList();
  }

  /// Trier les locations par prix
  void sortByPrice({bool ascending = true}) {
    if (_isSearchActive) {
      _searchResults.sort((a, b) => ascending
          ? a.pricePerNight.compareTo(b.pricePerNight)
          : b.pricePerNight.compareTo(a.pricePerNight));
    } else {
      _rentals.sort((a, b) => ascending
          ? a.pricePerNight.compareTo(b.pricePerNight)
          : b.pricePerNight.compareTo(a.pricePerNight));
    }
    notifyListeners();
  }

  /// Trier par capacité d'invités
  void sortByCapacity({bool ascending = true}) {
    if (_isSearchActive) {
      _searchResults.sort((a, b) => ascending
          ? a.maxGuests.compareTo(b.maxGuests)
          : b.maxGuests.compareTo(a.maxGuests));
    } else {
      _rentals.sort((a, b) => ascending
          ? a.maxGuests.compareTo(b.maxGuests)
          : b.maxGuests.compareTo(a.maxGuests));
    }
    notifyListeners();
  }

  /// Filtrer par commune
  List<DailyRental> filterByCommune(String commune) {
    final source = _isSearchActive ? _searchResults : _rentals;
    return source
        .where((rental) =>
            rental.address?.commune.label.toLowerCase() ==
            commune.toLowerCase())
        .toList();
  }

  /// Filtrer par nombre de chambres
  List<DailyRental> filterByBedrooms(int bedrooms) {
    final source = _isSearchActive ? _searchResults : _rentals;
    return source.where((rental) => rental.bedrooms >= bedrooms).toList();
  }

  /// Filtrer par gamme de prix
  List<DailyRental> filterByPriceRange(int minPrice, int maxPrice) {
    final source = _isSearchActive ? _searchResults : _rentals;
    return source
        .where((rental) =>
            rental.pricePerNight >= minPrice &&
            rental.pricePerNight <= maxPrice)
        .toList();
  }

  /// Obtenir les locations recommandées (les plus populaires/récentes)
  List<DailyRental> getRecommendedRentals({int limit = 5}) {
    final available = getAvailableRentals();
    available.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return available.take(limit).toList();
  }

  // ============ Utilitaires ============

  /// Réinitialiser les filtres
  void resetFilters() {
    _activeFilters.clear();
    deactivateSearchMode();
    resetRentals();
    fetchRentals();
  }

  /// Nettoyer les erreurs
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
