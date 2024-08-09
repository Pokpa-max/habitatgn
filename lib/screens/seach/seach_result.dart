import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/search/search.dart';

class SearchResultPage extends ConsumerWidget {
  const SearchResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: CustomTitle(
            text: 'Résultats de la recherche (${searchState.houses.length})',
            textColor: Colors.white),
      ),
      body: searchState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchState.houses.isEmpty
              ? houseCategoryListEmpty(
                  title: 'Aucun logement correspondant a cette recherche')
              : ListView.builder(
                  itemCount: searchState.houses.length,
                  itemBuilder: (context, index) {
                    final house = searchState.houses[index];
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        color: Colors.white,
                        elevation: 0,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          house.houseType!.label.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
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
                                            size: 16, color: primaryColor),
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
                                            size: 16, color: primaryColor),
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
                                        const Icon(Icons.attach_money_outlined,
                                            color: primaryColor),
                                        FormattedPrice(
                                          color: Colors.black,
                                          price: house.price,
                                          suffix: house.offerType["value"] ==
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
    );
  }
}
