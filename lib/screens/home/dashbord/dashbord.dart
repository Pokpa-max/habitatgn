// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:habitatgn/models/house_result_model.dart';
// import 'package:habitatgn/utils/ui_element.dart';
// import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';
// import 'package:habitatgn/screens/adversting/adversting.dart';
// import 'package:habitatgn/utils/appcolors.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// class DashbordScreen extends ConsumerStatefulWidget {
//   const DashbordScreen({super.key});

//   @override
//   _DashbordScreenState createState() => _DashbordScreenState();
// }

// class _DashbordScreenState extends ConsumerState<DashbordScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> navigateToUrl(String url) async {
//     if (_controller != null) {
//       if (await _controller.canGoBack()) {
//         await _controller.goBack();
//       } else {
//         await _controller.loadRequest(Uri.parse(url));
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = ref.watch(dashbordViewModelProvider);

//     final filteredHouses = viewModel.recentHouses;

//     double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         toolbarHeight: screenHeight * 0.10,
//         title: _buildSearchBar(
//           viewModel,
//         ),
//         backgroundColor: primaryColor,
//       ),
//       body: viewModel.isAdverstingLoading || viewModel.isRecentLoading
//           ? _buildSkeletonLoader()
//           : SingleChildScrollView(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(10.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     height: screenHeight * 0.20,
//                     child: viewModel.advertisementData.isEmpty
//                         ? _buildSkeletonAdvertisement()
//                         : AdvertisementCarousel(
//                             adverstingData: viewModel.advertisementData),
//                   ),
//                   const SizedBox(height: 10),
//                   _buildSectionTitle('Nos Services'),
//                   const SizedBox(height: 5),
//                   _buildServicesSection(ref, context),
//                   const SizedBox(height: 5),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _buildSectionTitle('Nos annonces récentes'),
//                       TextButton(
//                         onPressed: () {
//                           viewModel.navigateToHouseListPage(context);
//                         },
//                         child: const Text(
//                           'Voir tout',
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: primaryColor),
//                         ),
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   _buildRecentListings(viewModel, filteredHouses),
//                   const SizedBox(height: 20),
//                   _buildViewAllButton(viewModel),
//                   const SizedBox(height: 20),
//                   _buildOtherInformation(viewModel),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildSkeletonLoader() {
//     return ListView(
//       padding: EdgeInsets.zero,
//       children: [
//         _buildSkeletonAdvertisement(),
//         const SizedBox(height: 20),
//         _buildSkeletonServices(),
//         const SizedBox(height: 20),
//         _buildSkeletonRecentListings(),
//         const SizedBox(height: 20),
//         _buildSkeletonViewAllButton(),
//         const SizedBox(height: 20),
//         _buildSkeletonOtherInformation(),
//       ],
//     );
//   }

//   Widget _buildSkeletonAdvertisement() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade200,
//       child: Container(
//         width: double.infinity,
//         height: 200,
//         color: Colors.grey.shade300,
//       ),
//     );
//   }

//   Widget _buildSkeletonServices() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildSkeletonCard(),
//         _buildSkeletonCard(),
//       ],
//     );
//   }

//   Widget _buildSkeletonCard() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade200,
//       child: Container(
//         height: 100,
//         color: Colors.grey.shade300,
//         margin: const EdgeInsets.all(8.0),
//       ),
//     );
//   }

//   Widget _buildSkeletonRecentListings() {
//     double screenHeight = MediaQuery.of(context).size.height;
//     return SizedBox(
//       height: screenHeight * 0.25,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 3, // Display 3 skeleton items for demonstration
//         itemBuilder: (context, index) {
//           return Shimmer.fromColors(
//             baseColor: Colors.grey.shade300,
//             highlightColor: Colors.grey.shade200,
//             child: Container(
//               width: 250,
//               height: double.infinity,
//               margin: const EdgeInsets.all(8.0),
//               color: Colors.grey.shade300,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSkeletonViewAllButton() {
//     return Center(
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey.shade300,
//         highlightColor: Colors.grey.shade200,
//         child: Container(
//           width: 200,
//           height: 40,
//           color: Colors.grey.shade300,
//         ),
//       ),
//     );
//   }

//   Widget _buildSkeletonOtherInformation() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Shimmer.fromColors(
//           baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade200,
//           child: Container(
//             width: double.infinity,
//             height: 40,
//             color: Colors.grey.shade300,
//           ),
//         ),
//         const SizedBox(height: 10),
//         for (int i = 0; i < 3; i++)
//           Shimmer.fromColors(
//             baseColor: Colors.grey.shade300,
//             highlightColor: Colors.grey.shade200,
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 16.0),
//               height: 60,
//               color: Colors.grey.shade300,
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildSearchBar(
//     DashbordViewModel viewModel,
//   ) {
//     return Column(
//       children: [
//         TextField(
//           controller: _searchController,
//           autofocus: false,
//           onTap: () {
//             viewModel.navigateToHouseListPage(context);
//           },
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.white,
//             labelStyle: const TextStyle(color: Colors.black54, fontSize: 10),
//             hintText: 'Trouvez ici votre logement selon vos besoins ...',
//             prefixIcon: const Icon(Icons.search, color: Colors.black54),

//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(30),
//               borderSide: BorderSide.none,
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//                 vertical: 10, horizontal: 10), // Augmenter la hauteur du champ
//           ),
//         ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Text(title,
//           style: const TextStyle(
//               fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
//     );
//   }

//   Widget _buildServicesSection(WidgetRef ref, BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 0.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildServiceCard(
//             icon: Icons.build,
//             title: 'Réparations',
//             onTap: () => ref
//                 .read(dashbordViewModelProvider.notifier)
//                 .navigateToRepairPage(context),
//           ),
//           const SizedBox(width: 12),
//           _buildServiceCard(
//             icon: Icons.local_shipping,
//             title: 'Déménagement',
//             onTap: () => ref
//                 .read(dashbordViewModelProvider.notifier)
//                 .navigateToMovingPage(context),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildServiceCard({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: MouseRegion(
//         cursor: SystemMouseCursors.click,
//         child: Card(
//           elevation: 2,
//           shadowColor: primaryColor.withOpacity(0.2),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: InkWell(
//             onTap: onTap,
//             borderRadius: BorderRadius.circular(12),
//             child: Container(
//               padding:
//                   const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 gradient: LinearGradient(
//                   colors: [
//                     primaryColor.withOpacity(0.9),
//                     primaryColor,
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       icon,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentListings(DashbordViewModel viewModel, List<House> houses) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     // double screenWidth = MediaQuery.of(context).size.width;
//     return houses.isEmpty
//         ? houseCategoryListEmpty(
//             title: 'Aucun résultat trouvé',
//           )
//         : SizedBox(
//             height: screenHeight * 0.35,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: houses.length,
//               itemBuilder: (context, index) {
//                 final house = houses[index];
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Container(
//                     width:
//                         screenHeight * 0.35, // Largeur fixe pour chaque carte
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.1),
//                           spreadRadius: 0,
//                           blurRadius: 10,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(16),
//                       onTap: () {
//                         viewModel.navigateToHousingDetailPage(
//                             context, house.id);
//                       },
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Section image avec badges
//                           Expanded(
//                             flex: 3,
//                             child: Stack(
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: const BorderRadius.vertical(
//                                     top: Radius.circular(16),
//                                   ),
//                                   child: CustomCachedNetworkImage(
//                                     imageUrl: house.imageUrl,
//                                     width: double.infinity,
//                                     height: double.infinity,
//                                   ),
//                                 ),
//                                 // Badge type d'offre
//                                 Positioned(
//                                   top: 12,
//                                   right: 12,
//                                   child: Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 6,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: primaryColor,
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Text(
//                                       house.offerType["label"],
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 // Bouton suppression
//                               ],
//                             ),
//                           ),

//                           Padding(
//                             padding: const EdgeInsets.all(14),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       house.houseType!.label.toUpperCase(),
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     FormattedPrice(
//                                       color: primaryColor,
//                                       price: house.price,
//                                       size: 18,
//                                       suffix:
//                                           house.offerType["value"] == "ALouer"
//                                               ? '/mois'
//                                               : '',
//                                     ),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.location_on,
//                                       color: Colors.grey,
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Expanded(
//                                       child: Text(
//                                         '${house.address!.town["label"]} / ${house.address!.commune["label"]}',
//                                         style: const TextStyle(
//                                           fontSize: 16,
//                                           color: Colors.black87,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//   }

//   Widget _buildViewAllButton(DashbordViewModel viewModel) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: () {
//           viewModel.navigateToHouseListPage(context);
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryColor,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: const Text(
//           'Voir Toutes les Annonces',
//           style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   Widget _buildOtherInformation(DashbordViewModel viewModel) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Autres Informations',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 10),
//           InkWell(
//             onTap: () {
//               viewModel.navigateToSupportPage(context);
//             },
//             child: _buildInfoItem(Icons.help, 'Conseils et astuces',
//                 'Consultez nos conseils pour tirer le meilleur parti de notre service.'),
//           ),
//           Divider(thickness: 1, color: Colors.grey[300]),
//           InkWell(
//             onTap: () {
//               viewModel.navigateToContactPage(context);
//             },
//             child: _buildInfoItem(Icons.phone, 'Appelez-nous',
//                 'Contactez notre service client par téléphone pour toute assistance.'),
//           ),
//           Divider(thickness: 1, color: Colors.grey[300]),
//           InkWell(
//             onTap: () async {
//               try {
//                 await navigateToUrl('https://www.example.com');
//               } catch (e) {
//                 print('Failed to open URL: $e');
//               }
//             },
//             child: _buildInfoItem(
//               Icons.trending_up,
//               'Maximisez vos chances',
//               'Découvrez comment améliorer votre annonce pour attirer plus de potentiels locataires.',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoItem(IconData icon, String title, String description) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         children: [
//           Icon(icon, color: primaryColor),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   description,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black54,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';
import 'package:habitatgn/screens/adversting/adversting.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:shimmer/shimmer.dart';

class DashbordScreen extends ConsumerStatefulWidget {
  const DashbordScreen({super.key});

  @override
  _DashbordScreenState createState() => _DashbordScreenState();
}

class _DashbordScreenState extends ConsumerState<DashbordScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(dashbordViewModelProvider);
    final filteredHouses = viewModel.recentHouses;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar with Search
          SliverAppBar(
            expandedHeight: 180.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Trouvez votre logement idéal",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSearchBar(viewModel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: viewModel.isAdverstingLoading || viewModel.isRecentLoading
                ? _buildSkeletonLoader()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Advertisement Carousel
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 200,
                            child: viewModel.advertisementData.isEmpty
                                ? _buildSkeletonAdvertisement()
                                : AdvertisementCarousel(
                                    adverstingData:
                                        viewModel.advertisementData),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Services Section
                        _buildSectionTitle(
                            'Nos Services', 'Explorer nos services'),
                        const SizedBox(height: 16),
                        _buildServicesSection(ref, context),
                        const SizedBox(height: 24),

                        // Recent Listings Section
                        _buildSectionTitle(
                            'Annonces Récentes', 'Voir toutes les annonces',
                            onActionTap: () =>
                                viewModel.navigateToHouseListPage(context)),
                        const SizedBox(height: 16),
                        _buildRecentListings(viewModel, filteredHouses),
                        const SizedBox(height: 24),

                        // Other Information Section
                        _buildOtherInformation(viewModel),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(DashbordViewModel viewModel) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onTap: () => viewModel.navigateToHouseListPage(context),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Rechercher un logement...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: primaryColor),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String action,
      {VoidCallback? onActionTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              action,
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServicesSection(WidgetRef ref, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildServiceCard(
            icon: Icons.build,
            title: 'Réparations',
            description: 'Service de maintenance',
            onTap: () => ref
                .read(dashbordViewModelProvider.notifier)
                .navigateToRepairPage(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildServiceCard(
            icon: Icons.local_shipping,
            title: 'Déménagement',
            description: 'Service de transport',
            onTap: () => ref
                .read(dashbordViewModelProvider.notifier)
                .navigateToMovingPage(context),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.9),
            primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentListings(DashbordViewModel viewModel, List<House> houses) {
    if (houses.isEmpty) {
      return houseCategoryListEmpty(title: 'Aucun résultat trouvé');
    }

    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: houses.length,
        itemBuilder: (context, index) {
          final house = houses[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () =>
                  viewModel.navigateToHousingDetailPage(context, house.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          CustomCachedNetworkImage(
                            imageUrl: house.imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                house.offerType["label"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Details Section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              house.houseType!.label.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            FormattedPrice(
                              color: primaryColor,
                              price: house.price,
                              size: 16,
                              suffix: house.offerType["value"] == "ALouer"
                                  ? '/mois'
                                  : '',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOtherInformation(DashbordViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ressources Utiles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tout ce dont vous avez besoin pour réussir',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildInfoButton(
            icon: Icons.help_outline,
            title: 'Conseils et astuces',
            subtitle: 'Guides et recommandations',
            onTap: () => viewModel.navigateToSupportPage(context),
          ),
          _buildInfoButton(
            icon: Icons.phone_outlined,
            title: 'Service Client',
            subtitle: 'Nous sommes là pour vous aider',
            onTap: () => viewModel.navigateToContactPage(context),
          ),
          _buildInfoButton(
            icon: Icons.trending_up,
            title: 'Optimisez votre annonce',
            subtitle: 'Conseils pour plus de visibilité',
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonAdvertisement(),
          const SizedBox(height: 24),
          _buildSkeletonSection("Services"),
          const SizedBox(height: 16),
          _buildSkeletonServices(),
          const SizedBox(height: 24),
          _buildSkeletonSection("Annonces Récentes"),
          const SizedBox(height: 16),
          _buildSkeletonListings(),
          const SizedBox(height: 24),
          _buildSkeletonInformation(),
        ],
      ),
    );
  }

  Widget _buildSkeletonAdvertisement() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildSkeletonSection(String title) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonServices() {
    return Row(
      children: [
        Expanded(child: _buildSkeletonServiceCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildSkeletonServiceCard()),
      ],
    );
  }

  Widget _buildSkeletonServiceCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildSkeletonListings() {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonInformation() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
