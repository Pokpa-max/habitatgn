import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habitatgn/models/adversting.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/home/dashbord/call/call_screen.dart';
import 'package:habitatgn/screens/house/houseList.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/screens/servicies/moving.dart';
import 'package:habitatgn/screens/servicies/repair.dart';
import 'package:habitatgn/screens/settings/contact_page.dart';
import 'package:habitatgn/screens/settings/helpsupport_page.dart';
import 'package:habitatgn/services/advertisement/advertisement_service.dart';
import 'package:habitatgn/services/houses/house_service.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/viewmodels/notification/notification.dart';
import 'package:webview_flutter/webview_flutter.dart';

final houseServiceProvider = Provider((ref) => HouseService());

final advertisementServiceProvider = Provider((ref) => AdvertisementService());

final dashbordViewModelProvider =
    ChangeNotifierProvider((ref) => DashbordViewModel(ref));

class DashbordViewModel extends ChangeNotifier {
  NotificationViewModel notificationViewModel = NotificationViewModel();
  // house element

  final HouseService _houseService = HouseService();
  final Ref _read;
  List<String> imageUrls = [];

  List<AdvertisementData> _advertisementData = [];
  List<AdvertisementData> get advertisementData => _advertisementData;

  String title = "Habitat Gn";
  bool _isAdverstingLoading = true;
  bool get isAdverstingLoading => _isAdverstingLoading;

  List<House> _recentHouses = [];
  List<House> get recentHouses => _recentHouses;

  List<House> _houses = [];
  List<House> get houses => _houses;

  List<House> _housesFilter = [];
  List<House> get housefilter => _housesFilter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRecentLoading = false;
  bool get isRecentLoading => _isRecentLoading;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  DashbordViewModel(this._read) {
    notificationViewModel.requestUserPermission();
    notificationViewModel.initializeAndListenForTokenChanges(
        FirebaseAuth.instance.currentUser!.uid);
    notificationViewModel.configureNotificationHandling();
    fetchAdvertisementData();
    fetchRecentHouses(); // Fetch recent houses initially
  }

  // Ajout de la méthode resetHouses
  void resetHouses() async {
    _houses.clear();
    _housesFilter.clear();
    _housesFilter.clear();
    _lastDocument = null;
    // elements ajoutes
    _hasMore = true;
    _isLoading = false;
  }

  Future<void> fetchRecentHouses() async {
    _isRecentLoading = true;
    _recentHouses = await _houseService.getRecentHouses(
        limit: 20); // Ajustez le nombre selon vos besoins
    _isRecentLoading = false;
    notifyListeners();
  }

  Future<void> fetchHouses() async {
    if (isLoading) return;

    _isLoading = true;
    List<House> newHouses = await _houseService.getHouses(
      lastDocument: _lastDocument,
    );

    if (newHouses.length < 20) {
      _hasMore = false;
    }

    _houses.addAll(newHouses);
    if (newHouses.isNotEmpty) {
      _lastDocument = newHouses.last.snapshot;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAdvertisementData() async {
    _isAdverstingLoading = true;
    _advertisementData = await _read
        .read(advertisementServiceProvider)
        .fetchAdvertisementDatas();
    _isAdverstingLoading = false;
    notifyListeners();
  }

  //  house filter in firebase
  // Future<List<House>> filterHousesFromFirebase(String housingType) async {
  //   return await _houseService.searchHouses(housingType);
  // }

  Future<void> fetchFilteredHouses({
    required double minPrice,
    required double maxPrice,
    required String needType,
    required String propertyType,
    required String ville,
    required int bedrooms,
  }) async {
    try {
      if (isLoading) return;
      _isLoading = true;

      _housesFilter = await _houseService.fetchFilteredHouses(
        minPrice: minPrice,
        maxPrice: maxPrice,
        needType: needType,
        propertyType: propertyType,
        ville: ville,
        bedrooms: bedrooms,
      );

      _isLoading = false;
      // _hasMore = _houses.isNotEmpty;
      notifyListeners();
    } catch (e) {
      // Gérer les erreurs ici
    }
  }

  void navigateToHousingDetailPage(BuildContext context, String houseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HouseDetailScreen(
          houseId: houseId,
        ),
      ),
    );
  }

  void navigateToHouseListPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HouseListScreen(),
      ),
    );
  }

  void navigateToSearchPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchPage(),
      ),
    );
  }

  void navigateToRepairPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RepairServicesScreen(),
      ),
    );
  }

  void navigateToMovingPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MovingServicesScreen(),
      ),
    );
  }

  void navigateToSupportPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HelpSupportPage(),
      ),
    );
  }

  void navigateToContactPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CallPage(),
      ),
    );
  }

  HousingType parseHousingType(String type) {
    return HousingType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => HousingType.apartment,
    );
  }

  // Nouvelle méthode pour filtrer les logements
  List<House> filterRecentHouses(String query) {
    if (query.isEmpty) return _recentHouses;

    final lowerCaseQuery = query.toLowerCase();
    return _recentHouses.where((house) {
      final titleMatches =
          house.houseType!.label.toLowerCase().contains(lowerCaseQuery);
      final descriptionMatches =
          house.description.toLowerCase().contains(lowerCaseQuery);
      final addressMatches =
          house.address!.town["label"].toLowerCase().contains(lowerCaseQuery);
      return titleMatches || descriptionMatches || addressMatches;
    }).toList();
  }
}






// class DashbordViewModel extends StateNotifier<DashbordState> {
//   final DashbordService _dashbordService;

//   DashbordViewModel(this._dashbordService) : super(DashbordState.initial());

  
// }
