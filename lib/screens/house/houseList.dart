import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/skleton/house_list_skleton.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';

class HouseListScreen extends ConsumerStatefulWidget {
  const HouseListScreen({
    super.key,
  });

  @override
  ConsumerState<HouseListScreen> createState() => _HouseListScreenState();
}

class _HouseListScreenState extends ConsumerState<HouseListScreen> {
  @override
  void initState() {
    super.initState();
    _fetchHouses();
  }

  @override
  void didUpdateWidget(HouseListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    _fetchHouses();
  }

  void _fetchHouses() {
    ref.read(dashbordViewModelProvider.notifier).resetHouses();
    ref.read(dashbordViewModelProvider.notifier).fetchHouses();
  }

  void performSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final houseListViewModel = ref.watch(dashbordViewModelProvider);

    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomTitle(
            text: "Tous les Annonces de Logements", textColor: Colors.white),
      ),
      body: houseListViewModel.isLoading
          ? ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) => const LoadingSkeleton(),
            )
          : houseListViewModel.houses.isEmpty
              ? houseCategoryListEmpty()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (!houseListViewModel.isLoading &&
                              scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent &&
                              houseListViewModel.hasMore) {
                            houseListViewModel.fetchHouses();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          itemCount: houseListViewModel.houses.length + 1,
                          itemBuilder: (context, index) {
                            if (index == houseListViewModel.houses.length) {
                              return houseListViewModel.hasMore
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : Container();
                            }

                            House house = houseListViewModel.houses[index];
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Card(
                                color: Colors.white,
                                elevation: 0.5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: lightPrimary2)),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HousingDetailPage(
                                          houseId: house.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: CustomCachedNetworkImage(
                                          imageUrl: house.imageUrl,
                                          width: 250,
                                          height: 150,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  house.houseType!.label
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 4,
                                                      horizontal: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      house.offerType["label"],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    // size: 16,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  ' ${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey[700]),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.home,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${house.bedrooms} pièces',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey[700]),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.attach_money_outlined,
                                                    color: Colors.grey),
                                                FormattedPrice(
                                                  color: Colors.black,
                                                  price: house.price,
                                                  suffix: house.offerType[
                                                              "value"] ==
                                                          "ALouer"
                                                      ? '/mois'
                                                      : '',
                                                ),
                                              ],
                                            ),
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
                ),
      floatingActionButton: houseListViewModel.houses.isEmpty
          ? null
          : ElevatedButton.icon(
              icon: const Icon(
                Icons.search,
                size: 30,
              ),
              style: ButtonStyle(
                  padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
                  backgroundColor: WidgetStateProperty.all(primaryColor),
                  foregroundColor: WidgetStateProperty.all(Colors.white)),
              onPressed: performSearch,
              label: const Text('Recherche', style: TextStyle(fontSize: 18)),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
