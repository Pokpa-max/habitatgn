// // ignore_for_file: deprecated_member_use
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:habitatgn/models/dailyRental/daily_rental.dart';
// import 'package:habitatgn/screens/daily_rental/daily_rental_viewmodel.dart';

// import 'package:habitatgn/screens/notification/map/map_screen.dart';
// import 'package:habitatgn/utils/appcolors.dart';
// import 'package:habitatgn/utils/ui_element.dart';
// import 'package:habitatgn/widgets/reservation/unifielDaily_rental.dart';

// import 'package:shimmer/shimmer.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:intl/intl.dart';

// class DailyRentalDetailScreen extends ConsumerStatefulWidget {
//   final String rentalId;

//   const DailyRentalDetailScreen({required this.rentalId, super.key});

//   @override
//   ConsumerState<DailyRentalDetailScreen> createState() =>
//       _DailyRentalDetailScreenState();
// }

// class _DailyRentalDetailScreenState
//     extends ConsumerState<DailyRentalDetailScreen>
//     with SingleTickerProviderStateMixin {
//   DailyRental? rental;
//   bool isLoading = false;
//   bool isLiked = false;
//   final PageController _pageController = PageController();

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _initializeData();
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//   }

//   void _initializeData() async {
//     await _fetchRentalDetails();
//     await _checkIfFavorite();
//   }

//   Future<void> _fetchRentalDetails() async {
//     setState(() => isLoading = true);
//     try {
//       final viewModel = ref.read(dailyRentalViewModelProvider);
//       rental = await viewModel.fetchRentalById(widget.rentalId);
//     } catch (e) {
//       _showError('Erreur lors du chargement des détails');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _checkIfFavorite() async {
//     final viewModel = ref.read(dailyRentalViewModelProvider);
//     final liked = await viewModel.isFavorite(widget.rentalId);
//     setState(() => isLiked = liked);
//   }

//   Future<void> _toggleLike() async {
//     if (!await checkConnectivity(context)) return;

//     final viewModel = ref.read(dailyRentalViewModelProvider);
//     try {
//       await viewModel.toggleFavorite(widget.rentalId);
//       setState(() => isLiked = !isLiked);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(
//                 isLiked ? Icons.favorite : Icons.favorite_border,
//                 color: Colors.white,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 isLiked
//                     ? '${rental?.houseType?.label} ajouté aux favoris'
//                     : '${rental?.houseType?.label} retiré des favoris',
//                 style: GoogleFonts.poppins(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: primaryColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     } catch (e) {
//       _showError('Erreur lors de la modification des favoris');
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(
//               Icons.error_outline,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               message,
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.red[600],
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }

//   Future<void> _makePhoneCall() async {
//     if (!await checkConnectivity(context)) return;
//     if (rental?.phoneNumber == null) {
//       _showError('Numéro de téléphone non disponible');
//       return;
//     }

//     final viewModel = ref.read(dailyRentalViewModelProvider);
//     await viewModel.launchPhoneCall("tel:${rental!.phoneNumber}");
//   }

//   void _showBookingModal() {
//     if (rental == null) return;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => UnifiedDailyRentalModal(
//         houseId: widget.rentalId,
//         houseTitle: rental!.houseType?.label ?? 'Location',
//         houseLocation:
//             '${rental!.address?.commune.label}/${rental!.address?.zone}',
//         pricePerNight: rental!.pricePerNight.toDouble(),
//         maxGuests: rental!.maxGuests,
//         minStay: rental!.minStay,
//         maxStay: rental!.maxStay,
//         checkInHour: rental!.checkInHour,
//         checkOutHour: rental!.checkOutHour,
//         houseImageUrl: rental!.imageUrl,
//         onBookingSuccess: () {
//           // Rafraîchir les détails après une réservation réussie
//           _fetchRentalDetails();
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: isLoading
//           ? _buildLoadingState()
//           : AnimatedBuilder(
//               animation: _fadeAnimation,
//               builder: (context, child) => _buildMainContent(),
//             ),
//       bottomNavigationBar: rental != null ? _buildBottomBar() : null,
//     );
//   }

//   Widget _buildLoadingState() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: 300,
//               color: Colors.white,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: List.generate(
//                   8,
//                   (index) => Container(
//                     margin: const EdgeInsets.only(bottom: 16),
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     return Opacity(
//       opacity: _fadeAnimation.value,
//       child: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           _buildSliverAppBar(),
//           SliverToBoxAdapter(
//             child: rental != null ? _buildRentalDetails(rental!) : Container(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       expandedHeight: 300,
//       pinned: true,
//       stretch: true,
//       backgroundColor: Colors.white,
//       surfaceTintColor: Colors.white,
//       leading: Container(
//         margin: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: IconButton(
//           icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.grey[700]),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       actions: [
//         Container(
//           margin: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: IconButton(
//             icon: Icon(
//               isLiked ? Icons.favorite : Icons.favorite_outline,
//               color: isLiked ? Colors.red[400] : Colors.grey[700],
//             ),
//             onPressed: _toggleLike,
//           ),
//         ),
//         Container(
//           margin: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: IconButton(
//             icon: Icon(Icons.share_outlined, color: Colors.grey[700]),
//             onPressed: _shareRental,
//           ),
//         ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         background: rental != null ? _buildImageCarousel() : Container(),
//       ),
//     );
//   }

//   Widget _buildImageCarousel() {
//     final images = [
//       if (rental?.imageUrl != null) rental!.imageUrl,
//       ...rental?.houseInsides ?? [],
//     ];

//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         PageView.builder(
//           controller: _pageController,
//           physics: const BouncingScrollPhysics(),
//           itemCount: images.length,
//           itemBuilder: (context, index) {
//             return CachedNetworkImage(
//               imageUrl: images[index],
//               fit: BoxFit.cover,
//               placeholder: (context, url) => Container(
//                 color: Colors.grey[200],
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     color: primaryColor,
//                     strokeWidth: 2,
//                   ),
//                 ),
//               ),
//               errorWidget: (context, url, error) => Container(
//                 color: Colors.grey[200],
//                 child: Icon(
//                   Icons.image_not_supported_outlined,
//                   color: Colors.grey[400],
//                   size: 48,
//                 ),
//               ),
//             );
//           },
//         ),
//         // Badge "Location journalière"
//         Positioned(
//           top: 16,
//           left: 16,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: primaryColor,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.calendar_today,
//                   color: Colors.white,
//                   size: 14,
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   'Location journalière',
//                   style: GoogleFonts.poppins(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         // Badge de disponibilité
//         if (rental?.isAvailable == false)
//           Positioned(
//             top: 16,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 'Non disponible',
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         if (images.length > 1)
//           Positioned(
//             bottom: 16,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.6),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: SmoothPageIndicator(
//                   controller: _pageController,
//                   count: images.length,
//                   effect: WormEffect(
//                     dotHeight: 8,
//                     dotWidth: 8,
//                     activeDotColor: Colors.white,
//                     dotColor: Colors.white.withOpacity(0.5),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildRentalDetails(DailyRental rental) {
//     return Padding(
//       padding: const EdgeInsets.all(10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _buildHeaderCard(rental),
//           const SizedBox(height: 10),
//           _buildPriceCard(rental),
//           const SizedBox(height: 10),
//           _buildQuickInfoCard(rental),
//           const SizedBox(height: 10),
//           _buildCheckInOutCard(rental),
//           const SizedBox(height: 10),
//           _buildFeaturesCard(rental),
//           const SizedBox(height: 10),
//           _buildAmenitiesCard(rental),
//           const SizedBox(height: 10),
//           _buildLocationCard(rental),
//           const SizedBox(height: 10),
//           _buildDescriptionCard(rental),
//           const SizedBox(height: 10),
//           _buildRulesCard(rental),
//           const SizedBox(height: 100), // Espace pour le bottom bar
//         ],
//       ),
//     );
//   }

//   Widget _buildCard({required Widget child}) {
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
//       child: child,
//     );
//   }

//   Widget _buildHeaderCard(DailyRental rental) {
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             rental.houseType?.label ?? '',
//             style: GoogleFonts.poppins(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(Icons.location_on_outlined,
//                   color: Colors.grey[600], size: 18),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(
//                   '${rental.address?.commune.label}/${rental.address?.zone}',
//                   style: GoogleFonts.poppins(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceCard(DailyRental rental) {
//     return _buildCard(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Prix par nuit',
//                   style: GoogleFonts.poppins(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '${NumberFormat('#,###').format(rental.pricePerNight)} GNF',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: primaryColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.map_outlined, size: 18),
//             label: Text(
//               'Carte',
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primaryColor,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () => _navigateToMap(rental),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickInfoCard(DailyRental rental) {
//     return _buildCard(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildQuickInfoItem(
//             icon: Icons.people_outline,
//             label: 'Invités',
//             value: '${rental.maxGuests}',
//           ),
//           Container(
//             height: 40,
//             width: 1,
//             color: Colors.grey[300],
//           ),
//           _buildQuickInfoItem(
//             icon: Icons.hotel_outlined,
//             label: 'Chambres',
//             value: '${rental.bedrooms}',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickInfoItem({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: primaryColor, size: 24),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey[800],
//           ),
//         ),
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCheckInOutCard(DailyRental rental) {
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.access_time,
//                   color: primaryColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Horaires',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[800],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.green.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Icon(Icons.login, color: Colors.green[700], size: 28),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Check-in',
//                         style: GoogleFonts.poppins(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${rental.checkInHour}:00',
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green[700],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: Colors.orange.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Icon(Icons.logout, color: Colors.orange[700], size: 28),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Check-out',
//                         style: GoogleFonts.poppins(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${rental.checkOutHour}:00',
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.orange[700],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // buid amenities card
//   Widget _buildAmenitiesCard(DailyRental rental) {
//     if (rental.amenities == null || rental.amenities!.isEmpty) {
//       return Container();
//     }

//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.home_repair_service,
//                   color: primaryColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Équipements',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[800],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Wrap(
//             spacing: 10,
//             runSpacing: 10,
//             children: rental.amenities!.map((amenity) {
//               return Chip(
//                 label: Text(
//                   amenity,
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 backgroundColor: Colors.grey[200],
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFeaturesCard(DailyRental rental) {
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.info_outline,
//                   color: primaryColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Informations du séjour',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[800],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildInfoRow(
//             'Séjour minimum',
//             '${rental.minStay} nuit${rental.minStay > 1 ? 's' : ''}',
//           ),
//           _buildInfoRow(
//             'Séjour maximum',
//             '${rental.maxStay} nuits',
//           ),
//           _buildInfoRow(
//             'Nombre d\'invités max',
//             '${rental.maxGuests} personne${rental.maxGuests > 1 ? 's' : ''}',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLocationCard(DailyRental rental) {
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.location_on_outlined,
//                   color: primaryColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Localisation',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[800],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             '${rental.address?.town.label}, ${rental.address?.zone}',
//             style: GoogleFonts.poppins(
//               color: Colors.grey[700],
//               fontSize: 15,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDescriptionCard(DailyRental rental) {
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.description_outlined,
//                   color: primaryColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Description',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[800],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             rental.description,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey[700],
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRulesCard(DailyRental rental) {
//     return _buildCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.rule_outlined,
//                   color: primaryColor,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 'Règlement',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[800],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _buildRuleItem(
//             icon: Icons.schedule,
//             text: 'Arrivée après ${rental.checkInHour}:00',
//           ),
//           _buildRuleItem(
//             icon: Icons.schedule,
//             text: 'Départ avant ${rental.checkOutHour}:00',
//           ),
//           _buildRuleItem(
//             icon: Icons.people,
//             text: 'Maximum ${rental.maxGuests} invités',
//           ),
//           _buildRuleItem(
//             icon: Icons.nights_stay,
//             text: 'Séjour entre ${rental.minStay} et ${rental.maxStay} nuits',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRuleItem({required IconData icon, required String text}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(
//               icon,
//               color: primaryColor,
//               size: 16,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey[800],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomBar() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Expanded(
//               child: OutlinedButton.icon(
//                 onPressed: _makePhoneCall,
//                 icon: const Icon(Icons.phone_outlined, size: 20),
//                 label: Text(
//                   'Appeler',
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: primaryColor,
//                   side: BorderSide(color: primaryColor, width: 2),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               flex: 2,
//               child: ElevatedButton.icon(
//                 onPressed:
//                     rental?.isAvailable == true ? _showBookingModal : null,
//                 icon: const Icon(Icons.calendar_today, size: 20),
//                 label: Text(
//                   rental?.isAvailable == true ? 'Réserver' : 'Indisponible',
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.grey[300],
//                   disabledForegroundColor: Colors.grey[500],
//                   elevation: 0,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _shareRental() {
//     String message =
//         'Découvrez cette location journalière: ${rental?.houseType?.label ?? 'Logement'} '
//         'situé à ${rental?.address?.commune.label}/${rental?.address?.zone}\n'
//         'Prix: ${NumberFormat('#,###').format(rental?.pricePerNight ?? 0)} GNF/nuit\n'
//         'Capacité: ${rental?.maxGuests} personnes\n'
//         'Pour plus de détails, contactez le ${rental?.phoneNumber}.';

//     Share.share(message);
//   }

//   void _navigateToMap(DailyRental rental) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LocationMapScreen(
//           latitude: rental.address!.lat,
//           longitude: rental.address!.long,
//           address: '${rental.address?.commune.label}/${rental.address?.zone}',
//           houseType: rental.houseType!,
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }
// }

// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/dailyRental/daily_rental.dart';
import 'package:habitatgn/screens/daily_rental/daily_rental_viewmodel.dart';

import 'package:habitatgn/screens/notification/map/map_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/widgets/reservation/unifielDaily_rental.dart';

import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class DailyRentalDetailScreen extends ConsumerStatefulWidget {
  final String rentalId;

  const DailyRentalDetailScreen({required this.rentalId, super.key});

  @override
  ConsumerState<DailyRentalDetailScreen> createState() =>
      _DailyRentalDetailScreenState();
}

class _DailyRentalDetailScreenState
    extends ConsumerState<DailyRentalDetailScreen>
    with SingleTickerProviderStateMixin {
  DailyRental? rental;
  bool isLoading = false;
  bool isLiked = false;
  final PageController _pageController = PageController();

  // ✨ NOUVEAU: État pour le type de tarification sélectionné
  late PriceType _selectedPriceType;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _initializeData() async {
    await _fetchRentalDetails();
    await _checkIfFavorite();
  }

  Future<void> _fetchRentalDetails() async {
    setState(() => isLoading = true);
    try {
      final viewModel = ref.read(dailyRentalViewModelProvider);
      rental = await viewModel.fetchRentalById(widget.rentalId);

      // ✨ NOUVEAU: Initialiser le type de prix par défaut
      if (rental != null) {
        _selectedPriceType = rental!.mainPriceType;
      }
    } catch (e) {
      _showError('Erreur lors du chargement des détails');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkIfFavorite() async {
    final viewModel = ref.read(dailyRentalViewModelProvider);
    final liked = await viewModel.isFavorite(widget.rentalId);
    setState(() => isLiked = liked);
  }

  Future<void> _toggleLike() async {
    if (!await checkConnectivity(context)) return;

    final viewModel = ref.read(dailyRentalViewModelProvider);
    try {
      await viewModel.toggleFavorite(widget.rentalId);
      setState(() => isLiked = !isLiked);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isLiked
                    ? '${rental?.houseType?.label} ajouté aux favoris'
                    : '${rental?.houseType?.label} retiré des favoris',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      _showError('Erreur lors de la modification des favoris');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall() async {
    if (!await checkConnectivity(context)) return;
    if (rental?.phoneNumber == null) {
      _showError('Numéro de téléphone non disponible');
      return;
    }

    final viewModel = ref.read(dailyRentalViewModelProvider);
    await viewModel.launchPhoneCall("tel:${rental!.phoneNumber}");
  }

  void _showBookingModal() {
    if (rental == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UnifiedDailyRentalModal(
        houseId: widget.rentalId,
        houseTitle: rental!.houseType?.label ?? 'Location',
        houseLocation:
            '${rental!.address?.commune.label}/${rental!.address?.zone}',
        // ✨ NOUVEAU: Passer le prix selon le type sélectionné
        pricePerNight: (rental!.getPriceForType(_selectedPriceType) ??
                rental!.pricePerNight)
            .toDouble(),
        priceType: _selectedPriceType,
        maxGuests: rental!.maxGuests,
        minStay: rental!.minStay,
        maxStay: rental!.maxStay,
        checkInHour: rental!.checkInHour,
        checkOutHour: rental!.checkOutHour,
        houseImageUrl: rental!.imageUrl,
        onBookingSuccess: () {
          // Rafraîchir les détails après une réservation réussie
          _fetchRentalDetails();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? _buildLoadingState()
          : AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) => _buildMainContent(),
            ),
      bottomNavigationBar: rental != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: List.generate(
                  8,
                  (index) => Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Opacity(
      opacity: _fadeAnimation.value,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: rental != null ? _buildRentalDetails(rental!) : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_outline,
              color: isLiked ? Colors.red[400] : Colors.grey[700],
            ),
            onPressed: _toggleLike,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.share_outlined, color: Colors.grey[700]),
            onPressed: _shareRental,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: rental != null ? _buildImageCarousel() : Container(),
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = [
      if (rental?.imageUrl != null) rental!.imageUrl,
      ...rental?.houseInsides ?? [],
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey[400],
                  size: 48,
                ),
              ),
            );
          },
        ),
        // Badge "Location journalière"
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Location journalière',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Badge de disponibilité
        if (rental?.isAvailable == false)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Non disponible',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: images.length,
                  effect: WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRentalDetails(DailyRental rental) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(rental),
          const SizedBox(height: 10),
          // ✨ NOUVEAU: Remplacer _buildPriceCard par _buildPriceCardWithSelector
          _buildPriceCardWithSelector(rental),
          const SizedBox(height: 10),
          _buildQuickInfoCard(rental),
          const SizedBox(height: 10),
          _buildCheckInOutCard(rental),
          const SizedBox(height: 10),
          _buildFeaturesCard(rental),
          const SizedBox(height: 10),
          _buildAmenitiesCard(rental),
          const SizedBox(height: 10),
          _buildLocationCard(rental),
          const SizedBox(height: 10),
          _buildDescriptionCard(rental),
          const SizedBox(height: 10),
          _buildRulesCard(rental),
          const SizedBox(height: 100), // Espace pour le bottom bar
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
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
      child: child,
    );
  }

  Widget _buildHeaderCard(DailyRental rental) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rental.houseType?.label ?? '',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: Colors.grey[600], size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${rental.address?.commune.label}/${rental.address?.zone}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✨ NOUVEAU: Carte avec sélecteur de prix
  Widget _buildPriceCardWithSelector(DailyRental rental) {
    final availableTypes = rental.availablePriceTypes;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prix principal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rental.priceLabel,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,###').format(rental.getPriceForType(_selectedPriceType) ?? 0)} GNF',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.map_outlined, size: 18),
                label: Text(
                  'Carte',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _navigateToMap(rental),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ✨ NOUVEAU: Sélecteur de type de prix
          if (availableTypes.length > 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choisir le type de tarification:',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableTypes.map((type) {
                    final isSelected = _selectedPriceType == type;
                    final price = rental.getPriceForType(type) ?? 0;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedPriceType = type);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected ? primaryColor : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              type.label,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                            ),
                            Text(
                              '${NumberFormat('#,###').format(price)} GNF',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(DailyRental rental) {
    return _buildCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickInfoItem(
            icon: Icons.people_outline,
            label: 'Invités',
            value: '${rental.maxGuests}',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          _buildQuickInfoItem(
            icon: Icons.hotel_outlined,
            label: 'Chambres',
            value: '${rental.bedrooms}',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInOutCard(DailyRental rental) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.access_time,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Horaires',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.login, color: Colors.green[700], size: 28),
                      const SizedBox(height: 8),
                      Text(
                        'Check-in',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${rental.checkInHour}:00',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.logout, color: Colors.orange[700], size: 28),
                      const SizedBox(height: 8),
                      Text(
                        'Check-out',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${rental.checkOutHour}:00',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesCard(DailyRental rental) {
    if (rental.amenities == null || rental.amenities!.isEmpty) {
      return Container();
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.home_repair_service,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Équipements',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: rental.amenities!.map((amenity) {
              return Chip(
                label: Text(
                  amenity,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(DailyRental rental) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.info_outline,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Informations du séjour',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Séjour minimum',
            '${rental.minStay} nuit${rental.minStay > 1 ? 's' : ''}',
          ),
          _buildInfoRow(
            'Séjour maximum',
            '${rental.maxStay} nuits',
          ),
          _buildInfoRow(
            'Nombre d\'invités max',
            '${rental.maxGuests} personne${rental.maxGuests > 1 ? 's' : ''}',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(DailyRental rental) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.location_on_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Localisation',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${rental.address?.town.label}, ${rental.address?.zone}',
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(DailyRental rental) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.description_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Description',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rental.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard(DailyRental rental) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.rule_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Règlement',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRuleItem(
            icon: Icons.schedule,
            text: 'Arrivée après ${rental.checkInHour}:00',
          ),
          _buildRuleItem(
            icon: Icons.schedule,
            text: 'Départ avant ${rental.checkOutHour}:00',
          ),
          _buildRuleItem(
            icon: Icons.people,
            text: 'Maximum ${rental.maxGuests} invités',
          ),
          _buildRuleItem(
            icon: Icons.nights_stay,
            text: 'Séjour entre ${rental.minStay} et ${rental.maxStay} nuits',
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _makePhoneCall,
                icon: const Icon(Icons.phone_outlined, size: 20),
                label: Text(
                  'Appeler',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed:
                    rental?.isAvailable == true ? _showBookingModal : null,
                icon: const Icon(Icons.calendar_today, size: 20),
                label: Text(
                  rental?.isAvailable == true ? 'Réserver' : 'Indisponible',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareRental() {
    String message =
        'Découvrez cette location journalière: ${rental?.houseType?.label ?? 'Logement'} '
        'situé à ${rental?.address?.commune.label}/${rental?.address?.zone}\n'
        'Prix: ${NumberFormat('#,###').format(rental?.getPriceForType(_selectedPriceType) ?? 0)} GNF${PriceType.getSuffixForType(_selectedPriceType)}\n'
        'Capacité: ${rental?.maxGuests} personnes\n'
        'Pour plus de détails, contactez le ${rental?.phoneNumber}.';

    Share.share(message);
  }

  void _navigateToMap(DailyRental rental) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationMapScreen(
          latitude: rental.address!.lat,
          longitude: rental.address!.long,
          address: '${rental.address?.commune.label}/${rental.address?.zone}',
          houseType: rental.houseType!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
