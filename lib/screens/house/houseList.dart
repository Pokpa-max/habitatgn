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
  final String title;
  final IconData iconData;
  final String housingType;

  const HouseListScreen({
    super.key,
    required this.title,
    required this.iconData,
    required this.housingType,
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
    if (oldWidget.housingType != widget.housingType) {
      _fetchHouses();
    }
  }

  void _fetchHouses() {
    ref.read(dashbordViewModelProvider.notifier).resetHouses();
    ref
        .read(dashbordViewModelProvider.notifier)
        .fetchHouses(housingType: widget.housingType);
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTitle(text: widget.title, textColor: Colors.white),
            const SizedBox(width: 10),
            Icon(
              widget.iconData,
              color: Colors.white,
            ),
          ],
        ),
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
                            houseListViewModel.fetchHouses(
                                housingType: widget.housingType);
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
                                color: backgroundColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                          width: 130,
                                          height: 120,
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
                                                              20),
                                                    ),
                                                    child: SeparatedText(
                                                      text: house
                                                          .offerType["label"],
                                                      firstLetterStyle:
                                                          const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                      restOfTextStyle:
                                                          const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                      spaceBetween: 6.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    size: 16,
                                                    color: primaryColor),
                                                const SizedBox(width: 4),
                                                Text(
                                                  ' ${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.home,
                                                    size: 16,
                                                    color: primaryColor),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${house.bedrooms} pièces',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.attach_money_outlined,
                                                    color: primaryColor),
                                                FormattedPrice(
                                                  color: Colors.black,
                                                  price: house.price,
                                                  suffix: house.offerType[
                                                              "label"] ==
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
          : FloatingActionButton.extended(
              onPressed: performSearch,
              label: const Text(
                'Recherche',
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(Icons.search, color: Colors.white),
              backgroundColor: primaryColor,
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
