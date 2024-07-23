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
//       // lightPrimary,
//       appBar: _buildAppBar(context, viewModel),
//       body: viewModel.isAdverstingLoading
//           ? SingleChildScrollView(
//               child: Column(
//                 children: [
//                   ShimmerLoading(
//                       categorieLength: viewModel.getHousingCategories().length),
//                 ],
//               ),
//             )
//           : Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 viewModel.advertisementData.isEmpty
//                     ? Container(
//                         height: 250,
//                         color: lightPrimary,
//                         child: const Center(
//                           child: Text(
//                             "HABITATGN",
//                             style: TextStyle(
//                                 color: primaryColor,
//                                 fontSize: 30,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       )
//                     : AdvertisementCarousel(
//                         adverstingData: viewModel.advertisementData,
//                       ),
//                 const SizedBox(height: 20),
//                 // Padding(
//                 //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 //   child: _buildSectionTitle('Nos Catégories de Logements'),
//                 // ),
//                 // const SizedBox(height: 10),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Scrollbar(
//                       controller: _scrollController,
//                       thumbVisibility: false,
//                       child: SingleChildScrollView(
//                         controller: _scrollController,
//                         padding: const EdgeInsets.symmetric(horizontal: 5.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _buildSectionTitle('Nos services'),
//                                 const SizedBox(height: 10),
//                                 _buildServicesSection(context),
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 _buildSectionTitle(
//                                   'Nos Categories de Logements',
//                                 ),
//                                 const SizedBox(height: 10),
//                                 _buildCategoryGrid(context, viewModel),
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showContactOptions(context),
//         backgroundColor: primaryColor,
//         child: const Icon(
//           Icons.contact_phone,
//           color: Colors.white,
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
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         height: 30,
//         width: 30,
//         margin: const EdgeInsets.symmetric(horizontal: 5),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(30),
//           color: Colors.white,
//         ),
//         child: Icon(icon, color: primaryColor),
//       ),
//     );
//   }

//   Widget _buildCategoryGrid(BuildContext context, DashbordViewModel viewModel) {
//     final categories = viewModel.getHousingCategories();

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
//         return GridView.count(
//           crossAxisCount: crossAxisCount,
//           shrinkWrap: true,
//           childAspectRatio: 3 / 2,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//           physics: const NeverScrollableScrollPhysics(),
//           children: categories.map((category) {
//             return CategoryCard(
//               icon: category.icon,
//               label: category.label,
//               onTap: () async {
//                 await viewModel.navigateToHouseList(context, category);
//               },
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   Widget _buildServicesSection(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildServiceCard(
//           icon: Icons.build,
//           title: 'Reparations',
//           onTap: () {
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(builder: (context) => RepairServicesPage()),
//             // );
//           },
//         ),
//         _buildServiceCard(
//           icon: Icons.local_shipping,
//           title: 'Déménagement',
//           onTap: () {
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(builder: (context) => MovingServicesPage()),
//             // );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildServiceCard({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: Card(
//         elevation: 0,
//         color: primaryColor,
//         //  Colors.white,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//             side: BorderSide(color: lightPrimary2)),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(15),
//           child: Container(
//             padding: const EdgeInsets.all(5.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(icon, size: 30, color: Colors.white),
//                 const SizedBox(height: 10),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
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
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 18,
//         color: Colors.black,
//       ),
//     );
//   }

//   void _showContactOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(
//                   Icons.phone,
//                   color: primaryColor,
//                 ),
//                 title: const Text('Appeler l\'agent immobilier'),
//                 onTap: () {
//                   _launchPhoneCall(
//                       'tel:+1234567890'); // Remplacez par le numéro de téléphone réel
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(
//                   Icons.email,
//                   color: primaryColor,
//                 ),
//                 title: const Text('Envoyer un email'),
//                 onTap: () {
//                   _launchEmail(
//                       'mailto:agent@example.com'); // Remplacez par l'email réel
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _launchPhoneCall(String url) async {
//     if (!await launchUrl(Uri.parse(url))) {
//       throw Exception('Could not launch $url');
//     }
//   }

//   void _launchEmail(String url) async {
//     if (!await launchUrl(Uri.parse(url))) {
//       throw Exception('Could not launch $url');
//     }
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
//         elevation: 0,
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//             side: BorderSide(color: lightPrimary2)),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 30, color: primaryColor),
//               const SizedBox(height: 5),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 14,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';
import 'package:habitatgn/screens/adversting/adversting.dart';
import 'package:habitatgn/screens/home/dashbord/widgets/sniper_loading.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:url_launcher/url_launcher.dart';

class DashbordScreen extends ConsumerStatefulWidget {
  const DashbordScreen({super.key});

  @override
  _DashbordScreenState createState() => _DashbordScreenState();
}

class _DashbordScreenState extends ConsumerState<DashbordScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(dashbordViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context, viewModel),
      body: viewModel.isAdverstingLoading
          ? _buildLoadingView(viewModel)
          : _buildMainContent(viewModel),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactOptions(context),
        backgroundColor: primaryColor,
        child: const Icon(Icons.contact_phone, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingView(DashbordViewModel viewModel) {
    return Center(
      child: ListView(
        children: [
          ShimmerLoading(
            categorieLength: viewModel.getHousingCategories().length,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(DashbordViewModel viewModel) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: viewModel.advertisementData.isEmpty
              ? _buildEmptyAdvertisement()
              : AdvertisementCarousel(
                  adverstingData: viewModel.advertisementData,
                ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildSectionTitle('Nos services'),
                const SizedBox(height: 10),
                _buildServicesSection(),
                const SizedBox(height: 20),
                _buildSectionTitle('Nos Categories de Logements'),
                const SizedBox(height: 10),
                _buildCategoryGrid(viewModel),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyAdvertisement() {
    return Container(
      height: 250,
      color: lightPrimary,
      child: const Center(
        child: Text(
          "HABITATGN",
          style: TextStyle(
            color: primaryColor,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, DashbordViewModel viewModel) {
    return AppBar(
      title: const Text(
        'HABITATGN',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: primaryColor,
      actions: [
        _buildAppBarIcon(
          icon: Icons.search,
          onTap: () => viewModel.navigateToSearchPage(context),
        ),
        _buildAppBarIcon(
          icon: Icons.notifications,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAppBarIcon(
      {required IconData icon, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
      onPressed: onTap,
    );
  }

  Widget _buildCategoryGrid(DashbordViewModel viewModel) {
    final categories = viewModel.getHousingCategories();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 2,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          icon: category.icon,
          label: category.label,
          onTap: () async {
            await viewModel.navigateToHouseList(context, category);
          },
        );
      },
    );
  }

  Widget _buildServicesSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildServiceCard(
          icon: Icons.build,
          title: 'Réparations',
          onTap: () {
            // Navigate to repair services page
          },
        ),
        _buildServiceCard(
          icon: Icons.local_shipping,
          title: 'Déménagement',
          onTap: () {
            // Navigate to moving services page
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 30, color: primaryColor),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.phone, color: primaryColor),
                title: const Text('Appeler l\'agent immobilier'),
                onTap: () {
                  _launchPhoneCall('tel:+1234567890');
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: primaryColor),
                title: const Text('Envoyer un email'),
                onTap: () {
                  _launchEmail('mailto:agent@example.com');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchPhoneCall(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchEmail(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: primaryColor),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
