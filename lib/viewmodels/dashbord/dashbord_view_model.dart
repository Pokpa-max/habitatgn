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
import 'package:webview_flutter/webview_flutter.dart';

final houseServiceProvider = Provider((ref) => HouseService());

final advertisementServiceProvider = Provider((ref) => AdvertisementService());

final dashbordViewModelProvider =
    ChangeNotifierProvider((ref) => DashbordViewModel(ref));

class DashbordViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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

  final List<House> _houses = [];
  List<House> get houses => _houses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRecentLoading = false;
  bool get isRecentLoading => _isRecentLoading;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  DashbordViewModel(this._read) {
    _requestPermission();
    fetchAdvertisementData();
    fetchRecentHouses(); // Fetch recent houses initially
    initializeAndListenForTokenChanges(FirebaseAuth.instance.currentUser!.uid);
  }

  // Ajout de la méthode resetHouses
  void resetHouses() async {
    _houses.clear();
    _lastDocument = null;
    _hasMore = true;
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

  // save token to database

  Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> initializeAndListenForTokenChanges(String userId) async {
    try {
      // Obtenez le jeton initial et enregistrez-le dans la base de données
      await _saveOrUpdateToken(userId);

      // Écoutez les changements de jeton et mettez à jour la base de données
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        await _saveOrUpdateToken(userId);
      });
    } catch (e) {
      // Gérer les erreurs
      print("Error managing FCM token: $e");
    }
  }

  Future<void> _saveOrUpdateToken(String userId) async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      DocumentReference docRef = _db.collection('userPreferences').doc(userId);
      await docRef.set({'fcmToken': token}, SetOptions(merge: true));
    }
  }
}
