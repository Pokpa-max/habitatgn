// import 'package:flutter/material.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:habitatgn/models/house_result_model.dart';
// import 'package:habitatgn/screens/house/house_detail_screen.dart';
// import 'package:habitatgn/screens/seach/seach_screen.dart';
// import 'package:habitatgn/utils/appcolors.dart';
// import 'package:habitatgn/utils/skleton/house_list_skleton.dart';
// import 'package:habitatgn/utils/ui_element.dart';
// import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';

// class HouseListScreen extends ConsumerStatefulWidget {
//   const HouseListScreen({
//     super.key,
//   });

//   @override
//   ConsumerState<HouseListScreen> createState() => _HouseListScreenState();
// }

// class _HouseListScreenState extends ConsumerState<HouseListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _fetchHouses();
//   }

//   @override
//   void didUpdateWidget(HouseListScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     _fetchHouses();
//   }

//   void _fetchHouses() {
//     ref.read(dashbordViewModelProvider.notifier).resetHouses();
//     ref.read(dashbordViewModelProvider.notifier).fetchHouses();
//   }

//   void performSearch() {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => const SearchPage(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final houseListViewModel = ref.watch(dashbordViewModelProvider);

//     return Scaffold(
//       backgroundColor: lightPrimary,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_outlined),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         centerTitle: true,
//         backgroundColor: primaryColor,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const CustomTitle(
//             text: "Tous les Annonces de Logements", textColor: Colors.white),
//       ),
//       body: houseListViewModel.isLoading
//           ? ListView.builder(
//               itemCount: 10,
//               itemBuilder: (context, index) => const LoadingSkeleton(),
//             )
//           : houseListViewModel.houses.isEmpty
//               ? houseCategoryListEmpty()
//               : Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 10),
//                     Expanded(
//                       child: NotificationListener<ScrollNotification>(
//                         onNotification: (ScrollNotification scrollInfo) {
//                           if (!houseListViewModel.isLoading &&
//                               scrollInfo.metrics.pixels ==
//                                   scrollInfo.metrics.maxScrollExtent &&
//                               houseListViewModel.hasMore) {
//                             houseListViewModel.fetchHouses();
//                           }
//                           return false;
//                         },
//                         child: ListView.builder(
//                           itemCount: houseListViewModel.houses.length + 1,
//                           itemBuilder: (context, index) {
//                             if (index == houseListViewModel.houses.length) {
//                               return houseListViewModel.hasMore
//                                   ? const Center(
//                                       child: CircularProgressIndicator())
//                                   : Container();
//                             }

//                             House house = houseListViewModel.houses[index];
//                             return Padding(
//                               padding: const EdgeInsets.all(5.0),
//                               child: Card(
//                                 color: Colors.white,
//                                 elevation: 0.5,
//                                 shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     side: BorderSide(color: lightPrimary2)),
//                                 child: InkWell(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => HousingDetailPage(
//                                           houseId: house.id,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                   child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.all(5.0),
//                                         child: CustomCachedNetworkImage(
//                                           imageUrl: house.imageUrl,
//                                           width: 250,
//                                           height: 150,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   house.houseType!.label
//                                                       .toUpperCase(),
//                                                   style: const TextStyle(
//                                                     fontSize: 16,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 ),
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.all(8.0),
//                                                   child: Container(
//                                                     padding: const EdgeInsets
//                                                         .symmetric(
//                                                       vertical: 4,
//                                                       horizontal: 8,
//                                                     ),
//                                                     decoration: BoxDecoration(
//                                                       color: primaryColor,
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               4),
//                                                     ),
//                                                     child: Text(
//                                                       house.offerType["label"],
//                                                       style: const TextStyle(
//                                                         fontSize: 16,
//                                                         color: Colors.white,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(height: 6),
//                                             Row(
//                                               children: [
//                                                 const Icon(Icons.location_on,
//                                                     // size: 16,
//                                                     color: Colors.grey),
//                                                 const SizedBox(width: 4),
//                                                 Text(
//                                                   ' ${house.address!.town["label"]} / ${house.address!.commune["label"]}',
//                                                   style: TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.grey[700]),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(height: 6),
//                                             Row(
//                                               children: [
//                                                 const Icon(Icons.home,
//                                                     color: Colors.grey),
//                                                 const SizedBox(width: 4),
//                                                 Text(
//                                                   '${house.bedrooms} pièces',
//                                                   style: TextStyle(
//                                                       fontSize: 16,
//                                                       color: Colors.grey[700]),
//                                                 ),
//                                               ],
//                                             ),
//                                             Row(
//                                               children: [
//                                                 const Icon(
//                                                     Icons.attach_money_outlined,
//                                                     color: Colors.grey),
//                                                 FormattedPrice(
//                                                   color: Colors.black,
//                                                   price: house.price,
//                                                   suffix: house.offerType[
//                                                               "value"] ==
//                                                           "ALouer"
//                                                       ? '/mois'
//                                                       : '',
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//       floatingActionButton: houseListViewModel.houses.isEmpty
//           ? null
//           : ElevatedButton.icon(
//               icon: const Icon(
//                 Icons.search,
//                 size: 30,
//               ),
//               style: ButtonStyle(
//                   padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
//                   backgroundColor: WidgetStateProperty.all(primaryColor),
//                   foregroundColor: WidgetStateProperty.all(Colors.white)),
//               onPressed: performSearch,
//               label: const Text('Recherche', style: TextStyle(fontSize: 18)),
//             ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }

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
  const HouseListScreen({super.key});

  @override
  ConsumerState<HouseListScreen> createState() => _HouseListScreenState();
}

class _HouseListScreenState extends ConsumerState<HouseListScreen> {
  bool _isFilterApplied = false;

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

  void showFilterModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FilterModal();
      },
    ).whenComplete(() {
      setState(() {
        _isFilterApplied =
            true; // Met à jour l'état lorsque le filtre est appliqué
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final houseListViewModel = ref.watch(dashbordViewModelProvider);

    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomTitle(
          text: "Tous les Annonces de Logements",
          textColor: primaryColor,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la liste
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        ToggleButtons(
                          isSelected: [_isFilterApplied, !_isFilterApplied],
                          onPressed: (int index) {
                            setState(() {
                              _isFilterApplied = index == 0;
                            });
                            if (index == 1) {
                              showFilterModal();
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          selectedColor: Colors.white,
                          fillColor: primaryColor,
                          color: primaryColor,
                          borderColor: primaryColor,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text("Toutes les annonces",
                                  style: TextStyle(fontSize: 16)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text("Appliquer le Filtre",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Liste des maisons
          Expanded(
            child: houseListViewModel.isLoading
                ? ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) => const LoadingSkeleton(),
                  )
                : houseListViewModel.houses.isEmpty
                    ? houseCategoryListEmpty()
                    : NotificationListener<ScrollNotification>(
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
                                  side: BorderSide(color: lightPrimary2),
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
                                                        horizontal: 8),
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
    );
  }
}

class FilterModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Filtrer les Annonces',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Prix maximum',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Nombre de chambres',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // Ajoutez d'autres filtres si nécessaire
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Appliquer les filtres ici
                  Navigator.of(context).pop();
                },
                child: const Text('Appliquer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
