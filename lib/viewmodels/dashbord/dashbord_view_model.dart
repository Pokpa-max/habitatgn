import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/house/houseList.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  List<String> subtitles = [];
  bool isAdverstingLoading = true;

  final List<House> _houses = [];
  List<House> get houses => _houses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  DashbordViewModel(this._read) {
    _fetchAdvertisementData();
    //  fetchHouses();
  }

  Future<void> _fetchAdvertisementData() async {
    try {
      final data = await _read
          .read(advertisementServiceProvider)
          .fetchAdvertisementData();
      imageUrls = data['imageUrls']!;
      subtitles = data['subtitles']!;
    } catch (e) {
      // Handle error
    } finally {
      isAdverstingLoading = false;
      notifyListeners();
    }
  }

// @@@@@@@@@@@@@@@@@@@@@@@@@1
  // Future<void> fetchHouses() async {
  //   if (_isLoading || !_hasMore) return;

  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     List<House> newHouses = await _houseService.getHouses(lastDocument: _lastDocument);
  //     if (newHouses.isNotEmpty) {
  //       _houses.addAll(newHouses);
  //       _lastDocument = _houses.last.snapshot;  // Assurez-vous que `snapshot` est une propriété de `House`
  //     } else {
  //       _hasMore = false;
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching houses: $e');
  //   }

  //   _isLoading = false;
  //   notifyListeners();
  // }

  // @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2
  //Recuperation des logements selon le type

  //  Future<void> fetchHouses({HousingType? housingType}) async {
  //   if (isLoading) return;

  //   _isLoading = true;
  //   notifyListeners();

  //   List<House> newHouses = await _houseService.getHouses(
  //     lastDocument: _lastDocument,
  //     housingType: housingType,
  //   );

  //   if (newHouses.length < 20) {
  //     _hasMore = false;
  //   }

  //   houses.addAll(newHouses);
  //   if (newHouses.isNotEmpty) {
  //     _lastDocument = newHouses.last.snapshot;
  //   }

  //   _isLoading = false;
  //   notifyListeners();
  // }

  List<CategoryData> getHousingCategories() {
    return [
      CategoryData(Icons.villa, 'Villas'),
      CategoryData(Icons.house, 'Maisons'),
      CategoryData(Icons.home_work, 'Studios'),
      CategoryData(Icons.hotel, 'Hôtels'),
      CategoryData(Icons.store, 'Magasin'),
      CategoryData(Icons.terrain, 'Terrain'),
    ];
  }

  Future<Map<String, List<String>>> fetchAdvertisementData() async {
    return await _read
        .read(advertisementServiceProvider)
        .fetchAdvertisementData();
  }

  Future<void> navigateToHouseList(
      BuildContext context, CategoryData category) async {
    if (_isNavigating) return; // Ignore if already navigating
    _isNavigating = true;

    final categoryHousesData = await _read
        .read(houseServiceProvider)
        .getHousesByCategory(category.label);

    // Ensure _isNavigating is reset even if navigation fails
    _isNavigating = false;

    // ignore: use_build_context_synchronously
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HouselistScreen(
          title: category.label,
          iconData: category.icon,
          isForSale: false,
          results: categoryHousesData,
          onTap: () {
            navigateToSearchPage(context);
          },
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
              Icon(icon, size: 30, color: primary),
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
