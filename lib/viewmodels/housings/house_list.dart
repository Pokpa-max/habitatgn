import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/services/houses/house_service.dart';

class HouseListViewModel extends ChangeNotifier {
  final HouseService _houseService = HouseService();
  List<House> houses = [];
  List<House> favoriteHouses = [];

  bool isLoading = false;
  bool isFavorisLoading = false;
  bool hasMore = true;
  DocumentSnapshot? lastDocument;

  Future<House?> fetchHouseById(String houseId) async {
    try {
      isLoading = true;

      House? house = await _houseService.getHouseById(houseId);

      isLoading = false;
      notifyListeners();

      return house;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print('Error fetching house by id: $e');
      return null;
    }
  }

  Future<void> fetchHouses({String? housingType}) async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    List<House> newHouses = await _houseService.getHouses(
      lastDocument: lastDocument,
      housingType: housingType,
    );

    if (newHouses.length < 20) {
      hasMore = false;
    }

    houses.addAll(newHouses);
    if (newHouses.isNotEmpty) {
      lastDocument = newHouses.last.snapshot;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFavorites() async {
    isFavorisLoading = true;

    favoriteHouses = await _houseService.getFavorites();

    isFavorisLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String houseId) async {
    bool isFav = await _houseService.isFavorite(houseId);
    if (isFav) {
      await _houseService.removeFavorite(houseId);
      favoriteHouses.removeWhere((house) => house.id == houseId);
    } else {
      await _houseService.addFavorite(houseId);
      House? house = await _houseService.getHouseById(houseId);
      if (house != null) {
        favoriteHouses.add(house);
      }
    }
    notifyListeners();
  }

  Future<bool> isFavorite(String houseId) async {
    return await _houseService.isFavorite(houseId);
  }

  void navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchPage(),
      ),
    );
  }
}

final houseListViewModelProvider =
    ChangeNotifierProvider((ref) => HouseListViewModel());
