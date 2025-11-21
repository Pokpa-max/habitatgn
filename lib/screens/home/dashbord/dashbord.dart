// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:habitatgn/models/house_result_model.dart';
// import 'package:habitatgn/screens/daily_rental/daily_rental_screen.dart';
// import 'package:habitatgn/utils/skleton/house_list_skleton.dart';
// import 'package:habitatgn/utils/ui_element.dart';
// import 'package:habitatgn/viewmodels/dashbord/dashbord_view_model.dart';
// import 'package:habitatgn/screens/adversting/adversting.dart';
// import 'package:habitatgn/utils/appcolors.dart';
// import 'package:shimmer/shimmer.dart';

// class DashbordScreen extends ConsumerStatefulWidget {
//   const DashbordScreen({super.key});

//   @override
//   _DashbordScreenState createState() => _DashbordScreenState();
// }

// class _DashbordScreenState extends ConsumerState<DashbordScreen>
//     with TickerProviderStateMixin {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//     _animationController.forward();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = ref.watch(dashbordViewModelProvider);
//     final filteredHouses = viewModel.recentHouses;

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: viewModel.isAdverstingLoading || viewModel.isRecentLoading
//           ? buildLoadingDetailState()
//           : CustomScrollView(
//               controller: _scrollController,
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 _buildSliverAppBar(viewModel),
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildAdvertisementSection(viewModel),
//                         const SizedBox(height: 10),
//                         _buildServicesSection(viewModel),
//                         const SizedBox(height: 10),

//                         _buildRecentListingsSection(viewModel, filteredHouses),
//                         const SizedBox(height: 10),
//                         // Nouvelle section locations journalières
//                         _buildDailyRentalsSection(viewModel),
//                         const SizedBox(height: 10),
//                         _buildResourcesSection(viewModel),
//                         const SizedBox(height: 10),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

// // Section locations journalières - Fond couleur primaire
//   Widget _buildDailyRentalsSection(DashbordViewModel viewModel) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: primaryColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Icon(
//                       Icons.access_time_filled,
//                       color: primaryColor,
//                       size: 16,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Locations Journalières',
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey[800],
//                         ),
//                       ),
//                       Text(
//                         'Hébergements de courte durée',
//                         style: GoogleFonts.poppins(
//                           fontSize: 11,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               TextButton(
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const DailyRentalListScreen()),
//                 ),
//                 style: TextButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   minimumSize: Size.zero,
//                   tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 ),
//                 child: Text(
//                   'Voir toutes',
//                   style: GoogleFonts.poppins(
//                     color: primaryColor,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),

//           // Container principal avec fond couleur primaire
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: primaryColor,
//               boxShadow: [
//                 BoxShadow(
//                   color: primaryColor.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const DailyRentalListScreen()),
//                   );
//                 },
//                 borderRadius: BorderRadius.circular(10),
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Row(
//                           children: [
//                             // Badge blanc sur fond primaire
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 3,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 '✨ NOUVEAU',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 8,
//                                   fontWeight: FontWeight.w600,
//                                   color: primaryColor,
//                                   letterSpacing: 0.2,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Locations à la journée',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Appartements • Maisons • Studios',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 10,
//                                       color: Colors.white.withOpacity(0.9),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Container icône blanc
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(8),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 4,
//                               offset: const Offset(0, 1),
//                             ),
//                           ],
//                         ),
//                         child: Icon(
//                           Icons.schedule,
//                           color: primaryColor,
//                           size: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSliverAppBar(DashbordViewModel viewModel) {
//     return SliverAppBar(
//       expandedHeight: 80,
//       floating: true,
//       pinned: true,
//       snap: false,
//       elevation: 0,
//       backgroundColor: Colors.white,
//       surfaceTintColor: Colors.white,
//       automaticallyImplyLeading: false,
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [primaryColor, primaryColor],
//             ),
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(5, 5, 5, 2),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Bonjour !',
//                         style: GoogleFonts.poppins(
//                           fontSize: 18,
//                           color: Colors.white.withOpacity(0.9),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Text(
//                     'Trouvez votre logement idéal',
//                     style: GoogleFonts.poppins(
//                       fontSize: 22,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         collapseMode: CollapseMode.pin,
//       ),
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(1),
//         child: Container(
//           height: 1,
//           color: Colors.grey[200],
//         ),
//       ),
//     );
//   }

//   Widget _buildAdvertisementSection(DashbordViewModel viewModel) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: SizedBox(
//           height: 150,
//           child: viewModel.advertisementData.isEmpty
//               ? _buildAdvertisementPlaceholder()
//               : AdvertisementCarousel(
//                   adverstingData: viewModel.advertisementData,
//                 ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAdvertisementPlaceholder() {
//     return Container(
//       color: Colors.grey[200],
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.image_outlined,
//               size: 48,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Publicités en cours de chargement',
//               style: GoogleFonts.poppins(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// // Section services - Avec fond couleur primaire
//   Widget _buildServicesSection(DashbordViewModel viewModel) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Icon(
//                   Icons.handyman_outlined,
//                   color: primaryColor,
//                   size: 18,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 'Nos Services',
//                 style: GoogleFonts.poppins(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[800],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildCompactServiceCard(
//                   icon: Icons.build_outlined,
//                   title: 'Réparations',
//                   onTap: () => ref
//                       .read(dashbordViewModelProvider.notifier)
//                       .navigateToRepairPage(context),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: _buildCompactServiceCard(
//                   icon: Icons.local_shipping_outlined,
//                   title: 'Déménagement',
//                   onTap: () => ref
//                       .read(dashbordViewModelProvider.notifier)
//                       .navigateToMovingPage(context),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

// // Carte de service compacte avec fond couleur primaire
//   Widget _buildCompactServiceCard({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: primaryColor,
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: [
//               BoxShadow(
//                 color: primaryColor.withOpacity(0.3),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: primaryColor,
//                   size: 16,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.white.withOpacity(0.8),
//                 size: 12,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// // Section annonces récentes avec hauteur réduite
//   Widget _buildRecentListingsSection(
//       DashbordViewModel viewModel, List<House> houses) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: primaryColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       Icons.home_outlined,
//                       color: primaryColor,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Annonces récentes',
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey[800],
//                         ),
//                       ),
//                       Text(
//                         'Découvrez les dernières offres',
//                         style: GoogleFonts.poppins(
//                           fontSize: 13,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               TextButton(
//                 onPressed: () => viewModel.navigateToHouseListPage(context),
//                 child: Text(
//                   'Voir toutes',
//                   style: GoogleFonts.poppins(
//                     color: primaryColor,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           houses.isEmpty
//               ? _buildEmptyListings()
//               : SizedBox(
//                   height: 220, // Réduit de 280 à 220
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: houses.length,
//                     itemBuilder: (context, index) {
//                       final house = houses[index];
//                       return _buildCompactHouseCard(house, viewModel);
//                     },
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

// // Carte de logement compacte
//   Widget _buildCompactHouseCard(House house, DashbordViewModel viewModel) {
//     return Container(
//       width: 250,
//       margin: const EdgeInsets.only(right: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => viewModel.navigateToHousingDetailPage(context, house.id),
//           borderRadius: BorderRadius.circular(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(12),
//                     ),
//                     child: SizedBox(
//                       height: 110, // Réduit de 140 à 110
//                       width: double.infinity,
//                       child: CustomCachedNetworkImage(
//                         imageUrl: house.imageUrl,
//                         width: double.infinity,
//                         height: double.infinity,
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 6,
//                     right: 6,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 3,
//                       ),
//                       decoration: BoxDecoration(
//                         color: primaryColor,
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Text(
//                         house.offerType["label"],
//                         style: GoogleFonts.poppins(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       house.houseType!.label.toUpperCase(),
//                       style: GoogleFonts.poppins(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.location_on_outlined,
//                           color: Colors.grey[500],
//                           size: 12,
//                         ),
//                         const SizedBox(width: 3),
//                         Expanded(
//                           child: Text(
//                             '${house.address!.town["label"]} / ${house.address!.commune["label"]}',
//                             style: GoogleFonts.poppins(
//                               fontSize: 11,
//                               color: Colors.grey[600],
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         if (house.houseType?.label != "Terrain")
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.bed_outlined,
//                                 color: Colors.grey[500],
//                                 size: 12,
//                               ),
//                               const SizedBox(width: 3),
//                               Text(
//                                 '${house.bedrooms}',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                             ],
//                           )
//                         else
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.straighten_outlined,
//                                 color: Colors.grey[500],
//                                 size: 12,
//                               ),
//                               const SizedBox(width: 3),
//                               Text(
//                                 '${house.area} m²',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         FormattedPrice(
//                           color: primaryColor,
//                           price: house.price,
//                           size: 14,
//                           suffix: house.offerType["value"] == "ALouer"
//                               ? '/mois'
//                               : '',
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyListings() {
//     return Container(
//       height: 150,
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.home_outlined,
//               size: 40,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Aucune annonce disponible',
//               style: GoogleFonts.poppins(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildResourcesSection(DashbordViewModel viewModel) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildResourceItem(
//             icon: Icons.headset_mic_outlined,
//             title: 'Service Client',
//             subtitle: 'Nous sommes là pour vous aider',
//             onTap: () => viewModel.navigateToContactPage(context),
//           ),
//           _buildDivider(),
//           _buildResourceItem(
//             icon: Icons.help_outline,
//             title: 'Conseils et astuces',
//             subtitle: 'Guides et recommandations',
//             onTap: () => viewModel.navigateToSupportPage(context),
//           ),
//           _buildDivider(),
//         ],
//       ),
//     );
//   }

//   Widget _buildResourceItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           child: Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: primaryColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[800],
//                       ),
//                     ),
//                     Text(
//                       subtitle,
//                       style: GoogleFonts.poppins(
//                         fontSize: 13,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios_outlined,
//                 color: Colors.grey[400],
//                 size: 16,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       height: 1,
//       color: Colors.grey[100],
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _scrollController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
// }
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/models/dailyRental/daily_rental.dart';
import 'package:habitatgn/screens/daily_rental/daily_rental_screen.dart';
import 'package:habitatgn/screens/daily_rental/daily_rental_detail_screen.dart';
import 'package:habitatgn/utils/priceComponent.dart';
import 'package:habitatgn/utils/skleton/house_list_skleton.dart';
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

class _DashbordScreenState extends ConsumerState<DashbordScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(dashbordViewModelProvider);
    final filteredHouses = viewModel.recentHouses;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: viewModel.isAdverstingLoading || viewModel.isRecentLoading
          ? buildLoadingDetailState()
          : CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(viewModel),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAdvertisementSection(viewModel),
                        const SizedBox(height: 10),
                        _buildServicesSection(viewModel),
                        const SizedBox(height: 10),

                        _buildRecentListingsSection(viewModel, filteredHouses),
                        const SizedBox(height: 10),
                        // Section locations journalières avec aperçu
                        _buildDailyRentalsSection(viewModel),
                        const SizedBox(height: 10),
                        _buildResourcesSection(viewModel),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Section locations journalières - Avec aperçu des listings
  Widget _buildDailyRentalsSection(DashbordViewModel viewModel) {
    final dailyRentals = viewModel.dailyRentals ?? [];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre et "Voir toutes"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.access_time_filled,
                      color: primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Locations Journalières',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Hébergements de courte durée',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DailyRentalListScreen()),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Voir toutes',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Aperçu des locations journalières
          if (dailyRentals.isEmpty)
            _buildDailyRentalsPlaceholder()
          else
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dailyRentals.length,
                itemBuilder: (context, index) {
                  return _buildDailyRentalCard(
                    dailyRentals[index],
                    viewModel,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // Carte de location journalière compacte
  Widget _buildDailyRentalCard(
      DailyRental rental, DashbordViewModel viewModel) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DailyRentalDetailScreen(rentalId: rental.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image avec badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: CustomCachedNetworkImage(
                        imageUrl: rental.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Journée',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Badge disponibilité
                  if (rental.isAvailable == false)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Indisponible',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Contenu
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rental.houseType?.label ?? 'Logement',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey[500],
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${rental.address?.commune.label}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: Colors.grey[500],
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${rental.maxGuests}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.bed_outlined,
                              color: Colors.grey[500],
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${rental.bedrooms}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        RentalCardPricing(rental: rental)
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
  }

  // Placeholder pour locations journalières vides
  Widget _buildDailyRentalsPlaceholder() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune location journalière',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(DashbordViewModel viewModel) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      snap: false,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, primaryColor],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bonjour !',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Trouvez votre logement idéal',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        collapseMode: CollapseMode.pin,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildAdvertisementSection(DashbordViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 150,
          child: viewModel.advertisementData.isEmpty
              ? _buildAdvertisementPlaceholder()
              : AdvertisementCarousel(
                  adverstingData: viewModel.advertisementData,
                ),
        ),
      ),
    );
  }

  Widget _buildAdvertisementPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Publicités en cours de chargement',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section services - Avec fond couleur primaire
  Widget _buildServicesSection(DashbordViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.handyman_outlined,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Nos Services',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompactServiceCard(
                  icon: Icons.build_outlined,
                  title: 'Réparations',
                  onTap: () => ref
                      .read(dashbordViewModelProvider.notifier)
                      .navigateToRepairPage(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactServiceCard(
                  icon: Icons.local_shipping_outlined,
                  title: 'Déménagement',
                  onTap: () => ref
                      .read(dashbordViewModelProvider.notifier)
                      .navigateToMovingPage(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Carte de service compacte avec fond couleur primaire
  Widget _buildCompactServiceCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.8),
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section annonces récentes avec hauteur réduite
  Widget _buildRecentListingsSection(
      DashbordViewModel viewModel, List<House> houses) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.home_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Annonces récentes',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Découvrez les dernières offres',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () => viewModel.navigateToHouseListPage(context),
                child: Text(
                  'Voir toutes',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          houses.isEmpty
              ? _buildEmptyListings()
              : SizedBox(
                  height: 220, // Réduit de 280 à 220
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: houses.length,
                    itemBuilder: (context, index) {
                      final house = houses[index];
                      return _buildCompactHouseCard(house, viewModel);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // Carte de logement compacte
  Widget _buildCompactHouseCard(House house, DashbordViewModel viewModel) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => viewModel.navigateToHousingDetailPage(context, house.id),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SizedBox(
                      height: 110, // Réduit de 140 à 110
                      width: double.infinity,
                      child: CustomCachedNetworkImage(
                        imageUrl: house.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        house.offerType["label"],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      house.houseType!.label.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey[500],
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (house.houseType?.label != "Terrain")
                          Row(
                            children: [
                              Icon(
                                Icons.bed_outlined,
                                color: Colors.grey[500],
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${house.bedrooms}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Icon(
                                Icons.straighten_outlined,
                                color: Colors.grey[500],
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${house.area} m²',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        FormattedPrice(
                          color: primaryColor,
                          price: house.price,
                          size: 14,
                          suffix: house.offerType["value"] == "ALouer"
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
  }

  Widget _buildEmptyListings() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune annonce disponible',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesSection(DashbordViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResourceItem(
            icon: Icons.headset_mic_outlined,
            title: 'Service Client',
            subtitle: 'Nous sommes là pour vous aider',
            onTap: () => viewModel.navigateToContactPage(context),
          ),
          _buildDivider(),
          _buildResourceItem(
            icon: Icons.help_outline,
            title: 'Conseils et astuces',
            subtitle: 'Guides et recommandations',
            onTap: () => viewModel.navigateToSupportPage(context),
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildResourceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: Colors.grey[100],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
