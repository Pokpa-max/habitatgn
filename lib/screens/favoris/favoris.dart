import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/skleton/house_list_skleton.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/housings/house_list.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Pour afficher un toast

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final houseListViewModel = ref.read(houseListViewModelProvider.notifier);
    await houseListViewModel.fetchFavorites();
  }

  Future<void> _removeFavorite(House house) async {
    final houseListViewModel = ref.read(houseListViewModelProvider.notifier);
    await houseListViewModel
        .toggleFavorite(house.id); // Assurez-vous d'avoir une méthode pour cela
  }

  @override
  Widget build(BuildContext context) {
    final houseListViewModel = ref.watch(houseListViewModelProvider);

    return Scaffold(
        backgroundColor: lightPrimary,
        appBar: AppBar(
          centerTitle: true,
          title: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTitle(
                text: "Mes coups de cœur",
                textColor: Colors.white,
              ),
              Icon(Icons.favorite, color: Colors.red),
            ],
          ),
          backgroundColor: primaryColor,
        ),
        body: houseListViewModel.isLoading
            ? ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) => const LoadingSkeleton(),
              )
            : houseListViewModel.favoriteHouses.isEmpty
                ? houseCategoryListEmpty()
                : Column(
                    children: [
                      Expanded(
                        child: houseListViewModel.isLoading
                            ? ListView.builder(
                                itemCount: 10,
                                itemBuilder: (context, index) =>
                                    const LoadingSkeleton(),
                              )
                            : houseListViewModel.favoriteHouses.isEmpty
                                ? houseCategoryListEmpty()
                                : NotificationListener<ScrollNotification>(
                                    onNotification:
                                        (ScrollNotification scrollInfo) {
                                      if (!houseListViewModel.isLoading &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo
                                                  .metrics.maxScrollExtent &&
                                          houseListViewModel.hasMore) {
                                        houseListViewModel.fetchHouses();
                                      }
                                      return false;
                                    },
                                    child: ListView.builder(
                                      itemCount: houseListViewModel
                                          .favoriteHouses.length,
                                      itemBuilder: (context, index) {
                                        // double screenWidth =
                                        //     MediaQuery.of(context).size.width;
                                        double screenHeight =
                                            MediaQuery.of(context).size.height;
                                        House house = houseListViewModel
                                            .favoriteHouses[index];

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  spreadRadius: 0,
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HouseDetailScreen(
                                                      houseId: house.id,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Section image avec badges
                                                  Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .vertical(
                                                          top: Radius.circular(
                                                              16),
                                                        ),
                                                        child:
                                                            CustomCachedNetworkImage(
                                                          imageUrl:
                                                              house.imageUrl,
                                                          width:
                                                              double.infinity,
                                                          height: screenHeight *
                                                              0.22,
                                                        ),
                                                      ),
                                                      // Badge type d'offre
                                                      Positioned(
                                                        top: 12,
                                                        right: 12,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: primaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: Text(
                                                            house.offerType[
                                                                "label"],
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Bouton suppression
                                                      Positioned(
                                                        top: 12,
                                                        left: 12,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.8),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                              size: 20,
                                                            ),
                                                            onPressed: () =>
                                                                _removeFavorite(
                                                                    house),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Section informations
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            14),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              house.houseType!
                                                                  .label
                                                                  .toUpperCase(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                            ),
                                                            FormattedPrice(
                                                              color:
                                                                  primaryColor,
                                                              price:
                                                                  house.price,
                                                              size: 18,
                                                              suffix: house.offerType[
                                                                          "value"] ==
                                                                      "ALouer"
                                                                  ? '/mois'
                                                                  : '',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.location_on,
                                                              color:
                                                                  Colors.grey,
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Expanded(
                                                              child: Text(
                                                                '${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black87,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        if (house.houseType
                                                                ?.label !=
                                                            "Terrain")
                                                          _buildBedroomsRow(
                                                              house)
                                                        else
                                                          _buildAreaRow(house),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                      ),
                    ],
                  ));
  }

  Widget _buildBedroomsRow(House house) {
    return Row(
      children: [
        const Icon(Icons.king_bed, color: Colors.grey),
        const SizedBox(width: 8),
        Text('${house.bedrooms} chambres',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAreaRow(House house) {
    return Row(
      children: [
        const Icon(Icons.area_chart_sharp, color: Colors.grey),
        const SizedBox(width: 8),
        Text('${house.area} m²',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
