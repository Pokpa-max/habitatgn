import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/services/search/search_service.dart';

class SearchState {
  final List<House> houses;
  final bool isLoading;
  final DocumentSnapshot? lastDocument;

  SearchState(
      {required this.houses, required this.isLoading, this.lastDocument});
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _searchService;

  SearchNotifier(this._searchService)
      : super(SearchState(houses: [], isLoading: false));

  Future<void> searchHouses({
    required String type,
    required String location,
    required String commune,
    required String quartier,
    required String partNumber,
    required int minPrice,
    required int maxPrice,
    required bool isVente,
    bool isNewSearch = false,
  }) async {
    if (state.isLoading) return;
    state = SearchState(
        houses: state.houses,
        isLoading: true,
        lastDocument: state.lastDocument);

    if (isNewSearch) {
      state = SearchState(houses: [], isLoading: true);
    }

    List<House> results = await _searchService.searchHouses(
      type: type,
      location: location,
      commune: commune,
      quartier: quartier,
      partNumber: partNumber,
      minPrice: minPrice,
      maxPrice: maxPrice,
      isVenteSelected: isVente,
      limit: 10,
      lastDocument: state.lastDocument,
    );

    if (results.isNotEmpty) {
      state = SearchState(
        houses: [...state.houses, ...results],
        isLoading: false,
        lastDocument: results.last.snapshot,
      );
    } else {
      state = SearchState(
          houses: state.houses,
          isLoading: false,
          lastDocument: state.lastDocument);
    }
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(SearchService());
});
