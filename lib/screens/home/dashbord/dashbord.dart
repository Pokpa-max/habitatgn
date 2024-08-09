// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';
// import 'package:habitatgn/screens/adversting/adversting.dart';
// import 'package:habitatgn/screens/home/dashbord/widgets/sniper_loading.dart';
// import 'package:habitatgn/utils/appcolors.dart';
// import 'package:url_launcher/url_launcher.dart';

// class DashbordScreen extends ConsumerStatefulWidget {
//   const DashbordScreen({super.key});

//   @override
//   _DashbordScreenState createState() => _DashbordScreenState();
// }

// class _DashbordScreenState extends ConsumerState<DashbordScreen> {
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = ref.watch(dashbordViewModelProvider);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(context, viewModel),
//       body: viewModel.isAdverstingLoading
//           ? _buildLoadingView(viewModel)
//           : _buildMainContent(viewModel),
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: () => _showContactOptions(context),
//       //   backgroundColor: primaryColor,
//       //   child: const Icon(Icons.contact_phone, color: Colors.white),
//       // ),
//     );
//   }

//   Widget _buildLoadingView(DashbordViewModel viewModel) {
//     return Center(
//       child: ListView(
//         children: [
//           ShimmerLoading(
//             categorieLength: viewModel.getHousingCategories().length,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainContent(DashbordViewModel viewModel) {
//     return CustomScrollView(
//       controller: _scrollController,
//       slivers: [
//         SliverToBoxAdapter(
//           child: viewModel.advertisementData.isEmpty
//               ? _buildEmptyAdvertisement()
//               : AdvertisementCarousel(
//                   adverstingData: viewModel.advertisementData,
//                 ),
//         ),
//         SliverPadding(
//           padding: const EdgeInsets.all(16.0),
//           sliver: SliverList(
//             delegate: SliverChildListDelegate(
//               [
//                 _buildSectionTitle('Nos services'),
//                 const SizedBox(height: 10),
//                 _buildServicesSection(ref, context),
//                 const SizedBox(height: 20),
//                 _buildSectionTitle('Nos Categories de Logements'),
//                 const SizedBox(height: 10),
//                 _buildCategoryGrid(viewModel),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyAdvertisement() {
//     return Container(
//       height: 250,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [lightPrimary, primaryColor],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: const Center(
//         child: Text(
//           "HABITATGN",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 30,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   AppBar _buildAppBar(BuildContext context, DashbordViewModel viewModel) {
//     return AppBar(
//       title: const Text(
//         'HABITATGN',
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//         ),
//       ),
//       backgroundColor: primaryColor,
//       actions: [
//         _buildAppBarIcon(
//           icon: Icons.search,
//           onTap: () => viewModel.navigateToSearchPage(context),
//         ),
//         _buildAppBarIcon(
//           icon: Icons.notifications,
//           onTap: () {},
//         ),
//       ],
//     );
//   }

//   Widget _buildAppBarIcon(
//       {required IconData icon, required VoidCallback onTap}) {
//     return IconButton(
//       icon: Icon(
//         icon,
//         color: Colors.white,
//         size: 30,
//       ),
//       onPressed: onTap,
//     );
//   }

//   Widget _buildCategoryGrid(DashbordViewModel viewModel) {
//     final categories = viewModel.getHousingCategories();

//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 3 / 2,
//       ),
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: categories.length,
//       itemBuilder: (context, index) {
//         final category = categories[index];
//         return CategoryCard(
//           icon: category.icon,
//           label: category.label,
//           onTap: () async {
//             await viewModel.navigateToHouseList(context, category);
//           },
//         );
//       },
//     );
//   }

//   Widget _buildServicesSection(WidgetRef ref, context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildServiceCard(
//           icon: Icons.build,
//           title: 'Réparations',
//           onTap: () {
//             ref
//                 .read(dashbordViewModelProvider.notifier)
//                 .navigateToRepairPage(context);
//           },
//         ),
//         _buildServiceCard(
//           icon: Icons.local_shipping,
//           title: 'Déménagement',
//           onTap: () {
//             ref
//                 .read(dashbordViewModelProvider.notifier)
//                 .navigateToMovingPage(context);
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildServiceCard(
//       {required IconData icon,
//       required String title,
//       required VoidCallback onTap}) {
//     return Expanded(
//       child: Card(
//         elevation: 0.5,
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: BorderSide(color: lightPrimary2)),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(icon, size: 30, color: primaryColor),
//                 const SizedBox(height: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }
// }

// class CategoryCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;

//   const CategoryCard({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Card(
//         elevation: 0.5,
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: BorderSide(color: lightPrimary2)),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 30, color: primaryColor),
//               const SizedBox(height: 10),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';
import 'package:habitatgn/screens/adversting/adversting.dart';
import 'package:habitatgn/screens/home/dashbord/widgets/sniper_loading.dart';
import 'package:habitatgn/utils/appcolors.dart';

class DashbordScreen extends ConsumerStatefulWidget {
  const DashbordScreen({Key? key}) : super(key: key);

  @override
  _DashbordScreenState createState() => _DashbordScreenState();
}

class _DashbordScreenState extends ConsumerState<DashbordScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch recent houses when the widget is first built
    ref.read(dashbordViewModelProvider.notifier).fetchRecentHouses();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(dashbordViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        title: _buildSearchBar(),
        backgroundColor: primaryColor,
        elevation: 4,
        actions: [
          // IconButton(
          //   icon: Icon(Icons.notifications, color: Colors.white),
          //   onPressed: () {},
          // ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _performSearch,
          ),
        ],
      ),
      body: viewModel.isAdverstingLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner d'accueil
                  // Container(
                  //   padding: const EdgeInsets.all(16.0),
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(12),
                  //       color: primaryColor
                  //       //     lightPrimary,
                  //       // image: DecorationImage(
                  //       //   image: AssetImage(
                  //       //       'assets/images/maison.jpg'), // Remplacez par le chemin de votre image
                  //       //   fit: BoxFit.cover,
                  //       // ),
                  //       ),
                  //   child: const Center(
                  //     child: Text(
                  //       "Bienvenue sur HABITATGN",
                  //       style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 24,
                  //           fontWeight: FontWeight.bold),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 20),
                  // Slider (Carrousel)
                  Container(
                    height: 250,
                    child: viewModel.advertisementData.isEmpty
                        ? Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [lightPrimary, primaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Text("HABITATGN",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                            ),
                          )
                        : AdvertisementCarousel(
                            adverstingData: viewModel.advertisementData),
                  ),
                  const SizedBox(height: 20),
                  // Services Section
                  _buildSectionTitle('Nos Services'),
                  const SizedBox(height: 10),
                  _buildServicesSection(ref, context),
                  const SizedBox(height: 20),
                  // Logements Récents
                  _buildSectionTitle('Logements Récents'),
                  const SizedBox(height: 10),
                  _buildRecentListings(viewModel),
                  const SizedBox(height: 20),
                  // Voir toutes les annonces Button
                  _buildViewAllButton(viewModel),
                  const SizedBox(height: 20),
                  // Autres Informations
                  _buildOtherInformation(viewModel),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 100,
      child: Column(
        children: [
          const Center(
            child: Text(
              "Bienvenue sur HABITATGN",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _searchController,
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Rechercher ici  une maison,un appartement,terrain ...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    // Add logic to perform the search based on _searchQuery
    print('Searching for: $_searchQuery');
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
    );
  }

  Widget _buildServicesSection(WidgetRef ref, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildServiceCard(
            icon: Icons.build,
            title: 'Réparations',
            onTap: () => ref
                .read(dashbordViewModelProvider.notifier)
                .navigateToRepairPage(context)),
        _buildServiceCard(
            icon: Icons.local_shipping,
            title: 'Déménagement',
            onTap: () => ref
                .read(dashbordViewModelProvider.notifier)
                .navigateToMovingPage(context)),
      ],
    );
  }

  Widget _buildServiceCard(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Expanded(
      child: Card(
        elevation: 0.5,
        color: primaryColor,
        //  Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: primaryColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              gradient: LinearGradient(
                colors: [lightPrimary, primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 30, color: Colors.white),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentListings(DashbordViewModel viewModel) {
    return viewModel.isRecentLoading
        ? const Center(child: CircularProgressIndicator(color: primaryColor))
        : SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.recentHouses.length,
              itemBuilder: (context, index) {
                final house = viewModel.recentHouses[index];
                return InkWell(
                  onTap: () {
                    viewModel.navigateToHousingDetailPage(context, house.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0.5,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: lightPrimary2)),
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: CustomCachedNetworkImage(
                                    imageUrl: house.imageUrl,
                                    width: double.infinity,
                                    height: 150,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  house.houseType!.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                FormattedPrice(
                                  color: Colors.black,
                                  price: house.price,
                                  suffix: house.offerType["value"] == "ALouer"
                                      ? '/mois'
                                      : '',
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  ' ${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),

                            Text(
                              house.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                            // Ajoutez d'autres détails ici si nécessaire
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget _buildViewAllButton(DashbordViewModel viewModel) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Add navigation logic here to view all listings
          print('View all listings');
          viewModel.navigateToHouseListPage(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Background color
          foregroundColor: Colors.white, // Text color
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Voir Toutes les Annonces',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOtherInformation(DashbordViewModel viewModel) {
    // Placeholder for additional information or sections you might want to add
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Autres Informations',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          SizedBox(height: 10),
          Text(
            'Cette section peut être utilisée pour afficher des informations supplémentaires, des actualités ou des annonces importantes.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          // Add more widgets as needed
        ],
      ),
    );
  }
}
