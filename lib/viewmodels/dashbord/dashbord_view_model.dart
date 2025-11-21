import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habitatgn/models/adversting.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/models/dailyRental/daily_rental.dart';
import 'package:habitatgn/screens/home/dashbord/call/call_screen.dart';
import 'package:habitatgn/screens/house/houseList.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/screens/servicies/moving.dart';
import 'package:habitatgn/screens/servicies/repair.dart';
import 'package:habitatgn/screens/settings/contact_page.dart';
import 'package:habitatgn/screens/settings/helpsupport_page.dart';
import 'package:habitatgn/services/advertisement/advertisement_service.dart';
import 'package:habitatgn/services/dailyRental/daily_rental_service.dart';
import 'package:habitatgn/services/houses/house_service.dart';
import 'package:habitatgn/services/reservation/reservation_service.dart';

import 'package:habitatgn/viewmodels/notification/notification.dart';

final houseServiceProvider = Provider((ref) => HouseService());
final advertisementServiceProvider = Provider((ref) => AdvertisementService());
final dailyRentalServiceProvider = Provider((ref) => DailyRentalService());

final dashbordViewModelProvider =
    ChangeNotifierProvider((ref) => DashbordViewModel(ref));

class DashbordViewModel extends ChangeNotifier {
  DashbordViewModel(this._read) {
    _init();
  }

  final Ref _read;
  final HouseService _houseService = HouseService();
  final DailyRentalService _dailyRentalService = DailyRentalService();
  final NotificationViewModel notificationViewModel = NotificationViewModel();

  // ────────────────────────────────────────────────────────────────────────────
  // UI State
  // ────────────────────────────────────────────────────────────────────────────
  String title = "Habitat Gn";
  String? lastError;

  // État de recherche et filtres
  bool _isSearchActive = false;
  String _currentQuery = '';
  Map<String, dynamic> _currentFilters = {};

  // Getters publics
  List<AdvertisementData> get advertisementData => _advertisementData;
  List<House> get recentHouses => _recentHouses;
  List<DailyRental> get dailyRentals => _dailyRentals;
  List<House> get houses => _houses;
  List<House> get searchResults => _searchResults;

  bool get isAdverstingLoading => _isAdverstingLoading;
  bool get isRecentLoading => _isRecentLoading;
  bool get isDailyRentalsLoading => _isDailyRentalsLoading;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get hasMoreSearch => _hasMoreSearch;
  bool get isSearchActive => _isSearchActive;
  String get currentQuery => _currentQuery;
  Map<String, dynamic> get currentFilters => Map.from(_currentFilters);

  // Listes privées
  List<AdvertisementData> _advertisementData = [];
  List<House> _recentHouses = [];
  List<DailyRental> _dailyRentals = [];
  final List<House> _houses = [];
  final List<House> _searchResults = [];

  // Pagination
  DocumentSnapshot? _lastDocument;
  DocumentSnapshot? _lastSearchDoc;
  bool _hasMore = true;
  bool _hasMoreSearch = true;

  // États de chargement
  bool _isAdverstingLoading = true;
  bool _isRecentLoading = false;
  bool _isDailyRentalsLoading = false;
  bool _isLoading = false;

  // ────────────────────────────────────────────────────────────────────────────
  // Initialisation
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> _init() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await notificationViewModel.requestUserPermission();
        notificationViewModel.initializeAndListenForTokenChanges(uid);
        notificationViewModel.configureNotificationHandling();
      }
      await fetchAdvertisementData();
      await fetchRecentHouses();
      await fetchDailyRentals();
    } catch (e) {
      print('Error during init: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Gestion des états et resets
  // ────────────────────────────────────────────────────────────────────────────
  void resetHouses() {
    _houses.clear();
    _lastDocument = null;
    _hasMore = true;
    _isLoading = false;
    lastError = null;
    notifyListeners();
  }

  void resetSearch() {
    _searchResults.clear();
    _lastSearchDoc = null;
    _hasMoreSearch = true;
    _isSearchActive = false;
    _currentQuery = '';
    _currentFilters.clear();
    _isLoading = false;
    lastError = null;
    notifyListeners();
  }

  void activateSearchMode() {
    _isSearchActive = true;
    notifyListeners();
  }

  void deactivateSearchMode() {
    resetSearch();
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Publicités
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> fetchAdvertisementData() async {
    _isAdverstingLoading = true;
    lastError = null;
    notifyListeners();

    try {
      _advertisementData = await _read
          .read(advertisementServiceProvider)
          .fetchAdvertisementDatas();
    } catch (e) {
      lastError = 'Erreur chargement publicités: $e';
      print('Error fetching ads: $e');
    } finally {
      _isAdverstingLoading = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Logements récents
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> fetchRecentHouses({int limit = 20}) async {
    _isRecentLoading = true;
    lastError = null;
    notifyListeners();

    try {
      _recentHouses = await _houseService.getRecentHouses(limit: limit);
    } catch (e) {
      lastError = 'Erreur chargement récents: $e';
      print('Error fetching recent houses: $e');
    } finally {
      _isRecentLoading = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 🆕 Locations journalières
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> fetchDailyRentals({int limit = 10}) async {
    _isDailyRentalsLoading = true;
    lastError = null;
    notifyListeners();

    try {
      _dailyRentals = await _dailyRentalService.getAllRentals();
      // Limiter à 'limit' premiers si vous voulez
      if (_dailyRentals.length > limit) {
        _dailyRentals = _dailyRentals.take(limit).toList();
      }
    } catch (e) {
      lastError = 'Erreur chargement locations journalières: $e';
      print('Error fetching daily rentals: $e');
      _dailyRentals = [];
    } finally {
      _isDailyRentalsLoading = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Tous les logements (pagination simple)
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> fetchHouses({int limit = 20}) async {
    if (_isLoading || !_hasMore || _isSearchActive) return;

    _isLoading = true;
    lastError = null;
    notifyListeners();

    try {
      final newHouses = await _houseService.getHouses(
        lastDocument: _lastDocument,
        limit: limit,
      );

      if (newHouses.length < limit) {
        _hasMore = false;
      }

      if (newHouses.isNotEmpty) {
        _lastDocument = newHouses.last.snapshot;
        _houses.addAll(newHouses);
      }
    } catch (e) {
      lastError = 'Erreur chargement logements: $e';
      print('Error fetching houses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 🚀 RECHERCHE ET FILTRES OPTIMISÉS
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> searchAndFilter({
    String query = '',
    double? minPrice,
    double? maxPrice,
    String needType = 'Tous',
    String propertyType = 'Tous',
    String ville = '',
    int bedrooms = 0,
    bool reset = true,
    int limit = 20,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    lastError = null;

    // Si c'est une nouvelle recherche, reset tout
    if (reset) {
      _searchResults.clear();
      _lastSearchDoc = null;
      _hasMoreSearch = true;
      _isSearchActive = true;
      _currentQuery = query;
      _currentFilters = {
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'needType': needType,
        'propertyType': propertyType,
        'ville': ville,
        'bedrooms': bedrooms,
      };
    }

    notifyListeners();

    try {
      final newResults = await _houseService.searchAndFilterHouses(
        query: _currentQuery,
        minPrice: _currentFilters['minPrice'],
        maxPrice: _currentFilters['maxPrice'],
        needType: _currentFilters['needType'] ?? 'Tous',
        propertyType: _currentFilters['propertyType'] ?? 'Tous',
        ville: _currentFilters['ville'] ?? '',
        bedrooms: _currentFilters['bedrooms'] ?? 0,
        lastDocument: _lastSearchDoc,
        limit: limit,
      );

      if (newResults.length < limit) {
        _hasMoreSearch = false;
      }

      if (newResults.isNotEmpty) {
        _lastSearchDoc = newResults.last.snapshot;
        _searchResults.addAll(newResults);
      }

      // Si pas de résultats et c'est une nouvelle recherche
      if (_searchResults.isEmpty && reset) {
        // Optionnel: suggérer des alternatives ou élargir la recherche
        print(
            'Aucun résultat trouvé pour: query="$query", filters=$_currentFilters');
      }
    } catch (e) {
      lastError = 'Erreur recherche: $e';
      print('Error in searchAndFilter: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Chargement de plus de résultats de recherche
  Future<void> loadMoreSearch({int limit = 20}) async {
    if (!_isSearchActive || !_hasMoreSearch) return;

    return searchAndFilter(reset: false, limit: limit);
  }

  /// Recherche rapide par texte uniquement
  Future<void> quickTextSearch(String query) async {
    if (query.trim().isEmpty) {
      deactivateSearchMode();
      return;
    }

    await searchAndFilter(
      query: query,
      reset: true,
    );
  }

  /// Application de filtres avec la recherche actuelle
  Future<void> applyFilters({
    double? minPrice,
    double? maxPrice,
    String needType = 'Tous',
    String propertyType = 'Tous',
    String ville = '',
    int bedrooms = 0,
  }) async {
    await searchAndFilter(
      query: _currentQuery,
      minPrice: minPrice,
      maxPrice: maxPrice,
      needType: needType,
      propertyType: propertyType,
      ville: ville,
      bedrooms: bedrooms,
      reset: true,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // MÉTHODES DE COMPATIBILITÉ (pour ne pas casser l'existant)
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> fetchFilteredHouses({
    required double minPrice,
    required double maxPrice,
    required String needType,
    required String propertyType,
    required String ville,
    required int bedrooms,
  }) async {
    await searchAndFilter(
      minPrice: minPrice > 0 ? minPrice : null,
      maxPrice: (maxPrice.isFinite && maxPrice > 0) ? maxPrice : null,
      needType: needType,
      propertyType: propertyType,
      ville: ville,
      bedrooms: bedrooms,
      reset: true,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Utilitaires et helpers
  // ────────────────────────────────────────────────────────────────────────────
  bool get hasActiveFilters {
    final filters = _currentFilters;
    return _isSearchActive &&
        (_currentQuery.isNotEmpty ||
            (filters['minPrice'] != null && filters['minPrice'] > 0) ||
            (filters['maxPrice'] != null &&
                filters['maxPrice'].isFinite &&
                filters['maxPrice'] > 0) ||
            (filters['needType'] != null && filters['needType'] != 'Tous') ||
            (filters['propertyType'] != null &&
                filters['propertyType'] != 'Tous') ||
            (filters['ville'] != null &&
                filters['ville'].toString().trim().isNotEmpty) ||
            (filters['bedrooms'] != null && filters['bedrooms'] > 0));
  }

  String get filtersDescription {
    if (!hasActiveFilters) return '';

    final parts = <String>[];
    final filters = _currentFilters;

    if (_currentQuery.isNotEmpty) {
      parts.add('"$_currentQuery"');
    }

    if (filters['needType'] != null && filters['needType'] != 'Tous') {
      parts.add(filters['needType']);
    }

    if (filters['propertyType'] != null && filters['propertyType'] != 'Tous') {
      parts.add(filters['propertyType']);
    }

    if (filters['ville'] != null &&
        filters['ville'].toString().trim().isNotEmpty) {
      parts.add(filters['ville']);
    }

    if (filters['bedrooms'] != null && filters['bedrooms'] > 0) {
      parts.add('${filters['bedrooms']} chambre(s)');
    }

    if (filters['minPrice'] != null && filters['minPrice'] > 0) {
      parts.add('≥ ${filters['minPrice']} F');
    }

    if (filters['maxPrice'] != null &&
        filters['maxPrice'].isFinite &&
        filters['maxPrice'] > 0) {
      parts.add('≤ ${filters['maxPrice']} F');
    }

    return parts.join(' • ');
  }

  /// Filtrage local pour les logements récents (optionnel)
  List<House> filterRecentHouses(String query) {
    if (query.isEmpty) return _recentHouses;

    final normalizedQuery = query.toLowerCase();
    return _recentHouses.where((house) {
      final searchFields = [
        house.houseType?.label ?? '',
        house.description,
        house.address?.town['label']?.toString() ?? '',
        house.address?.commune['label']?.toString() ?? '',
      ];

      return searchFields
          .any((field) => field.toLowerCase().contains(normalizedQuery));
    }).toList();
  }

  /// Refresh complet des données
  Future<void> refreshAll() async {
    await Future.wait([
      fetchAdvertisementData(),
      fetchRecentHouses(),
      fetchDailyRentals(),
    ]);

    if (!_isSearchActive) {
      resetHouses();
      await fetchHouses();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Navigation (inchangé)
  // ────────────────────────────────────────────────────────────────────────────
  void navigateToHousingDetailPage(BuildContext context, String houseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HouseDetailScreen(houseId: houseId),
      ),
    );
  }

  void navigateToHouseListPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HouseListScreen()),
    );
  }

  void navigateToSearchPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  void navigateToRepairPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UnifiedServicesScreen(
          serviceType: ServiceType.repair,
        ),
      ),
    );
  }

  void navigateToMovingPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UnifiedServicesScreen(
          serviceType: ServiceType.moving,
        ),
      ),
    );
  }

  void navigateToSupportPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const HelpSupportPage()),
    );
  }

  void navigateToContactPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CallPage()),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Divers
  // ────────────────────────────────────────────────────────────────────────────
  HousingType parseHousingType(String type) {
    return HousingType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => HousingType.apartment,
    );
  }

  @override
  void dispose() {
    // Cleanup si nécessaire
    super.dispose();
  }
}
