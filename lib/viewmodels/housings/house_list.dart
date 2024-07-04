import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/models/housing.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/services/houses/house_service.dart';

class HouseListViewModel extends ChangeNotifier {
  final HouseService _houseService = HouseService();
  List<House> houses = [];
  bool isLoading = false;
  bool hasMore = true;
  DocumentSnapshot? lastDocument;

  // Future<void> fetchHouses({HousingType? housingType}) async {
  //   if (isLoading) return;

  //   isLoading = true;
  //   notifyListeners();

  //   List<House> newHouses = await _houseService.getHouses(
  //     lastDocument: lastDocument,
  //     housingType: housingType,
  //   );

  //   if (newHouses.length < 20) {
  //     hasMore = false;
  //   }

  //   houses.addAll(newHouses);
  //   if (newHouses.isNotEmpty) {
  //     lastDocument = newHouses.last.snapshot;
  //   }

  //   isLoading = false;
  //   notifyListeners();
  // }

  void natigateToSearch(context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchPage(),
      ),
    );
  }
}

final houseListViewModelProvider =
    ChangeNotifierProvider((ref) => HouseListViewModel());
