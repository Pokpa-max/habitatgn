import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/notification/map/map_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/widgets/dashbord/dashbord.dart';
import 'package:habitatgn/viewmodels/housings/house_list.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart'; // Pour afficher un toast
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:share_plus/share_plus.dart';

// class HouseDetailScreen extends ConsumerStatefulWidget {
//   final String houseId;

//   const HouseDetailScreen({required this.houseId, super.key});

//   @override
//   ConsumerState<HouseDetailScreen> createState() => _HouseDetailScreenState();
// }

// class _HouseDetailScreenState extends ConsumerState<HouseDetailScreen> {
//   House? house;
//   bool isLoading = false;
//   bool isLiked = false;
//   bool showTitle = false;
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     // _scrollController = ScrollController();
//     _scrollController.addListener(_scrollListener);
//     _fetchHouseDetails();
//     _checkIfFavorite();
//   }

//   void _scrollListener() {
//     if (_scrollController.offset > kToolbarHeight && !showTitle) {
//       setState(() {
//         showTitle = true;
//       });
//     } else if (_scrollController.offset <= kToolbarHeight && showTitle) {
//       setState(() {
//         showTitle = false;
//       });
//     }
//   }

//   Future<void> _fetchHouseDetails() async {
//     setState(() => isLoading = true);
//     try {
//       final houseListViewModel = ref.read(houseListViewModelProvider);
//       house = await houseListViewModel.fetchHouseById(widget.houseId);
//     } catch (e) {
//       print('Error fetching house details: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _checkIfFavorite() async {
//     final houseListViewModel = ref.read(houseListViewModelProvider);
//     final liked = await houseListViewModel.isFavorite(widget.houseId);
//     setState(() {
//       isLiked = liked;
//     });
//   }

//   Future<void> _toggleLike() async {
//     final houseListViewModel = ref.read(houseListViewModelProvider);
//     final List<ConnectivityResult> connectivityResult =
//         await (Connectivity().checkConnectivity());
//     // Vérifiez l'état de la connexion Internet
//     if ((connectivityResult.contains(ConnectivityResult.none))) {
//       _showshowToast('Connexion Internet indisponible.', Colors.red);
//       return; // Ne continuez pas si aucune connexion n'est disponible
//     }

//     try {
//       await houseListViewModel.toggleFavorite(widget.houseId);
//       setState(() => isLiked = !isLiked);
//       final successMessage = isLiked
//           ? '${house?.houseType?.label} ajouté à vos coups de cœur !'
//           : '${house?.houseType?.label} retiré de vos coups de cœur!';
//       _showshowToast(successMessage, isLiked ? primaryColor : Colors.black87);
//     } catch (e) {
//       _showshowToast('Erreur: Veuillez réessayer plus tard.', Colors.red);
//     }
//   }

//   void _showshowToast(String message, Color color) {
//     Fluttertoast.showToast(
//       backgroundColor: color,
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.TOP,
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         backgroundColor: backgroundColor,
//         body: Center(
//           child: CircularProgressIndicator(color: primaryColor),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       floatingActionButton: _buildFloatingActionButton(),
//       body: CustomScrollView(
//         controller: _scrollController,
//         slivers: [
//           _buildSliverAppBar(),
//           SliverList(
//             delegate: SliverChildListDelegate(
//               [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child:
//                       house != null ? _buildHouseDetails(house!) : Container(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFloatingActionButton() {
//     return ElevatedButton.icon(
//       icon: const Icon(
//         Icons.phone,
//       ),
//       style: ButtonStyle(
//           padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
//           backgroundColor: WidgetStateProperty.all(primaryColor),
//           foregroundColor: WidgetStateProperty.all(Colors.white)),
//       onPressed: () async {
//         if (house?.phoneNumber != null) {
//           final houseListViewModel = ref.read(houseListViewModelProvider);
//           await houseListViewModel.launchPhoneCall("tel:${house!.phoneNumber}");
//         }
//       },
//       label: const Text("Appeler l'Agence ", style: TextStyle(fontSize: 14)),
//     );
//   }

//   // void _shareHouse() {
//   //   String message =
//   //       'Découvrez ce logement: ${house?.offerType["label"]?.toString() ?? 'Type inconnu'} '
//   //       // 'situé à ${house.address?.toString() ?? 'Adresse non spécifiée'}.\n'
//   //       ' situé à ${house?.address?.commune['label']?.toString()}/${house?.address?.zone}'
//   //       'Superficie: ${house?.area} m²\n'
//   //       'Prix: ${house?.price} GNF\n'
//   //       'Pour plus de détails, contactez le ${house?.phoneNumber}.';

//   //   Share.share(message);
//   // }

//   SliverAppBar _buildSliverAppBar() {
//     double screenHeight = MediaQuery.of(context).size.height * 0.40;
//     double screenWidth = MediaQuery.of(context).size.width;

//     return SliverAppBar(
//       backgroundColor: primaryColor,
//       expandedHeight: screenHeight,
//       floating: false,
//       pinned: true, // AppBar reste en haut lors du scroll
//       title: showTitle && house != null
//           ? Text(
//               '${house?.houseType?.label ?? ''} - ${house?.offerType["label"]}',
//               style: const TextStyle(color: Colors.white),
//             )
//           : null,
//       leading: IconButton(
//         icon: const Icon(
//           Icons.arrow_back_ios_outlined,
//           color: Colors.white,
//         ),
//         onPressed: () => Navigator.pop(context),
//       ),
//       actions: [
//         IconButton(
//           icon: Icon(
//             isLiked ? Icons.favorite : Icons.favorite_border,
//             color: isLiked ? Colors.red : Colors.white,
//             size: 30,
//           ),
//           onPressed: _toggleLike,
//         ),
//         IconButton(
//           icon: const Icon(Icons.share, color: Colors.white, size: 30),
//           onPressed: () {
//             // _shareHouse();
//           }, // Add share functionality here
//         ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         background: FlexibleSpaceBar(
//           background: house != null
//               ? Stack(
//                   children: [
//                     ImageCarousel(
//                       imageUrls: [house!.imageUrl, ...house!.houseInsides],
//                     ),
//                     Positioned(
//                       bottom: 0.0,
//                       left: 0.0,
//                       right: 0.0,
//                       child: Container(
//                         decoration: const BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Color.fromARGB(300, 0, 0, 0),
//                               Color.fromARGB(0, 0, 0, 0)
//                             ],
//                             begin: Alignment.bottomCenter,
//                             end: Alignment.topCenter,
//                           ),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           vertical: screenHeight * 0.01, // 1% of screen height
//                           horizontal: screenWidth * 0.03, // 3% of screen width
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               : const SizedBox.shrink(),
//         ),
//       ),
//     );
//   }

//   Widget _buildHouseDetails(House house) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildTitleAndLocationRow(house),
//         const SizedBox(height: 15),
//         _buildPriceRow(house),
//         const SizedBox(height: 15),
//         if (house.houseType?.label != "Terrain") ...[
//           _buildBedroomsRow(house),
//         ],
//         if (house.houseType?.label == "Terrain") ...[
//           _buildAreaRow(house),
//         ],
//         const SizedBox(height: 15),
//         _buildBathroomRow(house),
//         const SizedBox(height: 15),
//         _buildLocationRow(house),
//         const SizedBox(height: 20),
//         _buildDescriptionSection(house),
//         const SizedBox(height: 20),
//         if (house.houseType?.label != "Terrain") ...[
//           _buildAmenitiesSection(house),
//         ],
//         const SizedBox(height: 20),
//         _buildAdditionalInfoSection(house),
//         const SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildTitleAndLocationRow(House house) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Text('${house.houseType?.label ?? ''} - ',
//                 style:
//                     const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             const SizedBox(width: 8),
//             Text(house.offerType["label"],
//                 style:
//                     const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           ],
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             ElevatedButton.icon(
//               icon: const Icon(
//                 Icons.map,
//               ),
//               style: ButtonStyle(
//                   padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
//                   backgroundColor: WidgetStateProperty.all(primaryColor),
//                   foregroundColor: WidgetStateProperty.all(Colors.white)),
//               onPressed: () async {
//                 var connectivityResult =
//                     await Connectivity().checkConnectivity();
//                 if (connectivityResult == ConnectivityResult.none) {
//                   _showshowToast(
//                       'Connexion Internet indisponible.', Colors.red);
//                   return;
//                 }
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => LocationMapScreen(
//                       latitude: house.address!.lat,
//                       longitude: house.address!.long,
//                       address:
//                           '${house.address?.commune['label']}/${house.address?.zone}',
//                       houseType: house.houseType!,
//                     ),
//                   ),
//                 );
//               },
//               label: const Text('Localisation', style: TextStyle(fontSize: 14)),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildPriceRow(House house) {
//     return Row(
//       children: [
//         Icon(Icons.attach_money_outlined, color: Colors.grey[700]),
//         FormattedPrice(
//           color: Colors.black,
//           price: house.price,
//           size: 18,
//           suffix: house.offerType["value"] == "ALouer" ? '/mois' : '',
//         ),
//       ],
//     );
//   }

//   Widget _buildAreaRow(House house) {
//     return Row(
//       children: [
//         const Icon(Icons.area_chart_sharp, color: Colors.grey),
//         const SizedBox(width: 8),
//         Text('${house.area} m²',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }

//   Widget _buildBedroomsRow(House house) {
//     return Row(
//       children: [
//         const Icon(Icons.king_bed, color: Colors.grey),
//         const SizedBox(width: 8),
//         Text('${house.bedrooms} chambre(s)',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//       ],
//     );
//   }

//   Widget _buildBathroomRow(House house) {
//     return Row(
//       children: [
//         const Icon(Icons.bathroom_outlined, color: Colors.grey),
//         const SizedBox(width: 8),
//         Text(
//           '${house.bedrooms} toilette(s)',
//           style: const TextStyle(
//               fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//       ],
//     );
//   }

//   Widget _buildLocationRow(House house) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             const Icon(Icons.location_city, color: Colors.grey),
//             const SizedBox(width: 8),
//             Text('${house.address?.town['label']}',
//                 style:
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           ],
//         ),
//         const SizedBox(height: 10),
//         Row(
//           children: [
//             const Icon(Icons.location_on, color: Colors.grey),
//             const SizedBox(width: 8),
//             Text('${house.address?.commune['label']}/${house.address?.zone}',
//                 style:
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildDescriptionSection(House house) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Description:',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//         Divider(
//           color: Colors.grey[200],
//         ),
//         const SizedBox(height: 8),
//         Text(house.description, style: const TextStyle(fontSize: 16)),
//       ],
//     );
//   }

//   Widget _buildAmenitiesSection(House house) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Équipements:',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         Divider(
//           color: Colors.grey[200],
//         ),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 10,
//           runSpacing: 10,
//           children: house.commodites
//                   ?.map((amenity) => _buildAmenityCard(amenity['label']))
//                   .toList() ??
//               [],
//         ),
//       ],
//     );
//   }

//   Widget _buildAdditionalInfoSection(House house) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Informations supplémentaires:',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//         Divider(
//           color: Colors.grey[200],
//         ),
//         const SizedBox(height: 8),
//         if (house.houseType?.label != "Terrain") ...[
//           _buildAdditionalInfo(house),
//         ] else ...[
//           const Text(
//             'Documents du terrain',
//           ),
//           //  _buildAdditionalInfo(house),
//         ],
//       ],
//     );
//   }

//   Widget _buildAmenityCard(String label) {
//     return Card(
//       color: lightPrimary,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//           side: BorderSide(color: inputBackground)),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.check, color: Colors.grey),
//             const SizedBox(width: 8),
//             Text(label, style: const TextStyle(fontSize: 18)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAdditionalInfo(House house) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildInfoRow(
//             Icons.attach_money, 'Caution: ${house.housingDeposit} mois'),
//         const SizedBox(height: 10),
//         _buildInfoRow(Icons.calendar_today,
//             'Mois d\'avance: ${house.rentalDeposit} mois'),
//       ],
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String info) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.grey),
//         const SizedBox(
//           height: 15,
//           width: 8,
//         ),
//         Text(info, style: const TextStyle(fontSize: 16)),
//       ],
//     );s
//   }
// }

class HouseDetailScreen extends ConsumerStatefulWidget {
  final String houseId;

  const HouseDetailScreen({required this.houseId, super.key});

  @override
  ConsumerState<HouseDetailScreen> createState() => _HouseDetailScreenState();
}

class _HouseDetailScreenState extends ConsumerState<HouseDetailScreen>
    with SingleTickerProviderStateMixin {
  House? house;
  bool isLoading = false;
  bool isLiked = false;
  bool showTitle = false;
  final PageController _pageController = PageController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupListeners();
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

  void _setupListeners() {
    _scrollController.addListener(_scrollListener);
  }

  void _initializeData() async {
    await _fetchHouseDetails();
    await _checkIfFavorite();
  }

  void _scrollListener() {
    if (_scrollController.offset > kToolbarHeight && !showTitle) {
      setState(() => showTitle = true);
    } else if (_scrollController.offset <= kToolbarHeight && showTitle) {
      setState(() => showTitle = false);
    }
  }

  Future<void> _fetchHouseDetails() async {
    setState(() => isLoading = true);
    try {
      final houseListViewModel = ref.read(houseListViewModelProvider);
      house = await houseListViewModel.fetchHouseById(widget.houseId);
    } catch (e) {
      _showError('Erreur lors du chargement des détails');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkIfFavorite() async {
    final houseListViewModel = ref.read(houseListViewModelProvider);
    final liked = await houseListViewModel.isFavorite(widget.houseId);
    setState(() => isLiked = liked);
  }

  Future<void> _toggleLike() async {
    if (!await _checkConnectivity()) return;

    final houseListViewModel = ref.read(houseListViewModelProvider);
    try {
      await houseListViewModel.toggleFavorite(widget.houseId);
      setState(() => isLiked = !isLiked);
      _showSuccess(
        isLiked
            ? '${house?.houseType?.label} ajouté aux favoris'
            : '${house?.houseType?.label} retiré des favoris',
      );
    } catch (e) {
      _showError('Erreur lors de la modification des favoris');
    }
  }

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showError('Connexion Internet indisponible');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    _showToast(message, Colors.red);
  }

  void _showSuccess(String message) {
    _showToast(message, primaryColor);
  }

  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
    );
  }

  Future<void> _makePhoneCall() async {
    if (!await _checkConnectivity()) return;
    if (house?.phoneNumber == null) {
      _showError('Numéro de téléphone non disponible');
      return;
    }

    final houseListViewModel = ref.read(houseListViewModelProvider);
    await houseListViewModel.launchPhoneCall("tel:${house!.phoneNumber}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _buildAnimatedFAB(),
      body: isLoading
          ? _buildLoadingShimmer()
          : AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) => _buildMainContent(),
            ),
    );
  }

  Widget _buildMainContent() {
    return Opacity(
      opacity: _fadeAnimation.value,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: house != null ? _buildHouseDetails(house!) : Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  10,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildAnimatedFAB() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: showTitle ? const Offset(0, 2) : Offset.zero,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: showTitle ? 0.0 : 1.0,
        child: FloatingActionButton.extended(
          elevation: 4,
          backgroundColor: primaryColor,
          onPressed: _makePhoneCall,
          icon: const Icon(Icons.phone, color: Colors.white),
          label: Text(
            "Appeler l'Agence",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.4,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      leading: _buildBackButton(),
      actions: [
        _buildFavoriteButton(),
        _buildShareButton(),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: house != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageCarousel(),
                  _buildGradientOverlay(),
                  _buildPageIndicator(),
                ],
              )
            : Container(
                color: Colors.grey[200],
              ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : Colors.black,
        ),
        onPressed: _toggleLike,
      ),
    );
  }

  Widget _buildShareButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.share, color: Colors.black),
        onPressed: () {},
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = [
      if (house?.imageUrl != null) house!.imageUrl,
      ...house?.houseInsides ?? [],
    ];
    final customCacheManager = CacheManager(Config(
      'customCacheKey',
      stalePeriod: const Duration(days: 15),
      maxNrOfCacheObjects: 100,
    ));

    return PageView.builder(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Hero(
          tag: 'house-image-$index',
          child: CachedNetworkImage(
            cacheManager: customCacheManager,
            imageUrl: images[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: SmoothPageIndicator(
          controller: _pageController,
          count: (house?.houseInsides.length ?? 0) + 1,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: primaryColor,
            dotColor: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildHouseDetails(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderSection(house),
        const SizedBox(height: 24),
        _buildPriceSection(house),
        const SizedBox(height: 24),
        _buildFeaturesSection(house),
        const SizedBox(height: 24),
        _furnishingSection(house),
        const SizedBox(height: 24),
        _buildLocationSection(house),
        const SizedBox(height: 24),
        _buildDescriptionSection(house),
        if (house.houseType?.label != "Terrain") ...[
          const SizedBox(height: 24),
          _buildAmenitiesSection(house),
        ],
        const SizedBox(height: 24),
        _buildAdditionalInfoSection(house),
      ],
    );
  }

  Widget _buildHeaderSection(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${house.houseType?.label ?? ''} - ${house.offerType["label"]}',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.grey[600], size: 16),
            const SizedBox(width: 4),
            Text(
              '${house.address?.commune["label"]}/${house.address?.zone}',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(House house) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prix',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                FormattedPrice(
                  color: primaryColor,
                  price: house.price,
                  size: 24,
                  suffix: house.offerType["value"] == "ALouer" ? '/mois' : '',
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
              icon: const Icon(
                Icons.map,
                size: 20,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _navigateToMap(house),
              label: SizedBox(
                width: 60, // Ajuste cette largeur selon tes besoins
                child: const Text(
                  'Voir sur la carte',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(House house) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFeatureItem(
            icon: Icons.king_bed,
            label: 'Chambres',
            value: house.bedrooms.toString(),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          _buildFeatureItem(
            icon: Icons.square_foot,
            label: 'Superficie',
            value: '${house.area} m²',
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          _buildFeatureItem(
            icon: Icons.attach_money_sharp,
            label: 'Avance',
            value: '${house.housingDeposit} mois',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
      {required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Localisation',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.map, color: Colors.grey[600], size: 16),
            const SizedBox(width: 4),
            Text(
              '${house.address?.town["label"]}, ${house.address?.zone}',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _furnishingSection(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobilier',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.weekend, color: Colors.grey[600], size: 16),
            const SizedBox(width: 4),
            Text(
              '${house.furnishing["label"]}',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          house.description,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commodités',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: house.commodites!.map((commodity) {
            return Chip(
              label: Text(
                commodity["label"],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              backgroundColor: primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(House house) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations supplémentaires',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            _buildInfoRow('Caution', '${house.rentalDeposit} mois'),
            _buildInfoRow('Frais dagence', '${1} mois'),
            _buildInfoRow('Statut du locataire', house.rentalStatus),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMap(House house) {
    // Logique pour la navigation vers la carte
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationMapScreen(
          latitude: house.address!.lat,
          longitude: house.address!.long,
          address: '${house.address?.commune['label']}/${house.address?.zone}',
          houseType: house.houseType!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
