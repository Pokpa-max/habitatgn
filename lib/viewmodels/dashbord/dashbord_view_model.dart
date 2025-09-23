import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habitatgn/models/adversting.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/home/dashbord/call/call_screen.dart';
import 'package:habitatgn/screens/house/houseList.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/screens/servicies/moving.dart';
import 'package:habitatgn/screens/servicies/repair.dart';
import 'package:habitatgn/screens/settings/contact_page.dart';
import 'package:habitatgn/screens/settings/helpsupport_page.dart';
import 'package:habitatgn/services/advertisement/advertisement_service.dart';
import 'package:habitatgn/services/houses/house_service.dart';
import 'package:habitatgn/viewmodels/notification/notification.dart';

final houseServiceProvider = Provider((ref) => HouseService());
final advertisementServiceProvider = Provider((ref) => AdvertisementService());

final dashbordViewModelProvider =
    ChangeNotifierProvider((ref) => DashbordViewModel(ref));

class DashbordViewModel extends ChangeNotifier {
  DashbordViewModel(this._read) {
    _init();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Services / DI
  // ────────────────────────────────────────────────────────────────────────────
  final Ref _read;
  final HouseService _houseService = HouseService();
  final NotificationViewModel notificationViewModel = NotificationViewModel();

  // ────────────────────────────────────────────────────────────────────────────
  // UI State
  // ────────────────────────────────────────────────────────────────────────────
  String title = "Habitat Gn";
  String? lastError;

  // Public getters
  List<AdvertisementData> get advertisementData => _advertisementData;
  List<House> get recentHouses => _recentHouses;
  List<House> get houses => _houses;
  List<House> get searchResults => _searchResults;

  bool get isAdverstingLoading => _isAdverstingLoading;
  bool get isRecentLoading => _isRecentLoading;
  bool get isLoading => _isLoading;

  bool get hasMore => _hasMore;
  bool get hasMoreSearch => _hasMoreSearch;

  // Internals
  List<AdvertisementData> _advertisementData = [];
  List<House> _recentHouses = [];
  final List<House> _houses = [];

  // Liste générale (tous les logements)
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  // Recherche + filtres
  final List<House> _searchResults = [];
  DocumentSnapshot? _lastSearchDoc;
  bool _hasMoreSearch = true;

  // Loaders
  bool _isAdverstingLoading = true;
  bool _isRecentLoading = false;
  bool _isLoading = false;

  // Filtres/recherche en cours (source de vérité)
  String _q = '';
  double? _min;
  double? _max;
  String _need = 'Tous';
  String _type = 'Tous';
  String _ville = '';
  int _bedrooms = 0;

  // ────────────────────────────────────────────────────────────────────────────
  // Bootstrap
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
    } catch (_) {}
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Resets
  // ────────────────────────────────────────────────────────────────────────────
  /// Reset de la liste générale
  void resetHouses() {
    _houses.clear();
    _lastDocument = null;
    _hasMore = true;
    _isLoading = false;
    lastError = null;
    notifyListeners();
  }

  /// Reset du mode recherche/filtres
  void resetSearch() {
    _searchResults.clear();
    _lastSearchDoc = null;
    _hasMoreSearch = true;
    _isLoading = false;
    lastError = null;
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Advertisement
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
      lastError = 'Erreur chargement publicités';
    } finally {
      _isAdverstingLoading = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Recent
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> fetchRecentHouses({int limit = 20}) async {
    _isRecentLoading = true;
    lastError = null;
    notifyListeners();
    try {
      _recentHouses = await _houseService.getRecentHouses(limit: limit);
    } catch (e) {
      lastError = 'Erreur chargement récents';
    } finally {
      _isRecentLoading = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Tous les logements (pagination)
  // ────────────────────────────────────────────────────────────────────────────
  Future<void> fetchHouses({int limit = 20}) async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    lastError = null;
    notifyListeners();
    try {
      final newHouses = await _houseService.getHouses(
          lastDocument: _lastDocument, limit: limit);

      if (newHouses.length < limit) _hasMore = false;
      if (newHouses.isNotEmpty) {
        _lastDocument = newHouses.last.snapshot;
        _houses.addAll(newHouses);
      }
    } catch (e) {
      lastError = 'Erreur chargement logements';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Recherche + filtres (côté Firestore) — API unifiée
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

    if (reset) {
      _q = query;
      _min = minPrice;
      _max = maxPrice;
      _need = needType;
      _type = propertyType;
      _ville = ville;
      _bedrooms = bedrooms;

      _searchResults.clear();
      _lastSearchDoc = null;
      _hasMoreSearch = true;
    }

    notifyListeners();

    try {
      final res = await _houseService.searchAndFilterHouses(
        query: _q,
        minPrice: _min,
        maxPrice: _max,
        needType: _need,
        propertyType: _type,
        ville: _ville,
        bedrooms: _bedrooms,
        lastDocument: _lastSearchDoc,
        limit: limit,
      );

      if (res.length < limit) _hasMoreSearch = false;
      if (res.isNotEmpty) {
        _lastSearchDoc = res.last.snapshot;
        _searchResults.addAll(res);
      }
    } catch (e) {
      lastError = 'Erreur recherche/filtres';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Compat : conserve ta signature existante, redirige vers l’API unifiée
  Future<void> fetchFilteredHouses({
    required double minPrice,
    required double maxPrice,
    required String needType,
    required String propertyType,
    required String ville,
    required int bedrooms,
  }) {
    return searchAndFilter(
      query: _q,
      minPrice: minPrice > 0 ? minPrice : null,
      maxPrice: (maxPrice.isFinite && maxPrice > 0) ? maxPrice : null,
      needType: needType,
      propertyType: propertyType,
      ville: ville,
      bedrooms: bedrooms,
      reset: true,
    );
  }

  /// Chargement incrémental en mode recherche (scroll bas)
  Future<void> loadMoreSearch({int limit = 20}) {
    if (_hasMoreSearch) {
      return searchAndFilter(reset: false, limit: limit);
    }
    return Future.value();
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

  /// Filtre client pour la section "récents" uniquement (facultatif)
  List<House> filterRecentHouses(String query) {
    if (query.isEmpty) return _recentHouses;
    final lower = query.toLowerCase();
    return _recentHouses.where((house) {
      final t = house.houseType?.label.toLowerCase() ?? '';
      final d = house.description.toLowerCase();
      final a = house.address?.town["label"].toLowerCase() ?? '';
      return t.contains(lower) || d.contains(lower) || a.contains(lower);
    }).toList();
  }
}
