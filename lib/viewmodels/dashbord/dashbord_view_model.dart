import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitatgn/models/adversting.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/house/houseList.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/screens/servicies/moving.dart';
import 'package:habitatgn/screens/servicies/repair.dart';
import 'package:habitatgn/services/advertisement/advertisement_service.dart';
import 'package:habitatgn/services/houses/house_service.dart';
import 'package:habitatgn/utils/appcolors.dart';

final houseServiceProvider = Provider((ref) => HouseService());

final advertisementServiceProvider = Provider((ref) => AdvertisementService());

final dashbordViewModelProvider =
    ChangeNotifierProvider((ref) => DashbordViewModel(ref));

class DashbordViewModel extends ChangeNotifier {
  final HouseService _houseService = HouseService();
  final Ref _read;
  bool _isNavigating = false;
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
    fetchAdvertisementData();
    fetchHouses();
  }

  // Ajout de la méthode resetHouses
  void resetHouses() async {
    _houses.clear();
    _lastDocument = null;
    _hasMore = true;
    // notifyListeners();
  }

  Future<void> fetchRecentHouses() async {
    _isRecentLoading = true;

    _recentHouses = await _houseService.getRecentHouses(
        limit: 10); // Ajustez le nombre selon vos besoins
    _isRecentLoading = false;

    notifyListeners();
  }

  // Récupération des logements selon le type
  Future<void> fetchHouses() async {
    if (isLoading) return;

    _isLoading = true;
    // notifyListeners();

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

  List<CategoryData> getHousingCategories() {
    return [
      CategoryData(Icons.villa, 'Villas'),
      CategoryData(Icons.house, 'Maisons'),
      CategoryData(Icons.home_filled, 'Duplex'),
      CategoryData(Icons.home_work, 'Studios'),
      CategoryData(Icons.house_siding_rounded, 'Chantiers'),
      CategoryData(Icons.hotel, 'Hôtels'),
      CategoryData(Icons.store, 'Magasins'),
      CategoryData(Icons.terrain, 'Terrains'),
    ];
  }

  void navigateToHousingDetailPage(BuildContext context, String houseId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HousingDetailPage(
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

  Future<void> navigateToHouseList(
      BuildContext context, CategoryData category) async {
    if (_isNavigating) return; // Ignore if already navigating
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HouseListScreen(
            // title: category.label,
            // iconData: category.icon,
            // housingType: category.label,
            ),
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

  HousingType parseHousingType(String type) {
    return HousingType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => HousingType.apartment,
    );
  }
}

class CategoryData {
  final IconData icon;
  final String label;

  CategoryData(this.icon, this.label);
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: primaryColor),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
