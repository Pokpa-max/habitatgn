import 'package:flutter/material.dart';
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
  final Ref _read;
  bool _isNavigating = false;
  List<String> imageUrls = [];
  List<String> subtitles = [];
  bool isLoading = true;

  DashbordViewModel(this._read) {
    _fetchAdvertisementData();
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
      isLoading = false;
      notifyListeners();
    }
  }

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

    final houses = await _read
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
          results: houses,
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
