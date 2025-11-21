// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/models/dailyRental/daily_rental.dart';
import 'package:habitatgn/screens/daily_rental/daily_rental_detail_screen.dart';
import 'package:habitatgn/screens/daily_rental/daily_rental_screen.dart';
import 'package:habitatgn/screens/house/houseList.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/services/dailyRental/daily_rental_service.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/skleton/house_list_skleton.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/housings/house_list.dart';
import 'package:intl/intl.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DailyRentalService _rentalService = DailyRentalService();

  List<DailyRental> _favoriteRentals = [];
  bool _isLoadingRentals = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && _favoriteRentals.isEmpty) {
        _fetchFavoriteRentals();
      }
    });
    _fetchFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchFavorites() async {
    final houseListViewModel = ref.read(houseListViewModelProvider.notifier);
    await houseListViewModel.fetchFavorites();
  }

  Future<void> _fetchFavoriteRentals() async {
    setState(() => _isLoadingRentals = true);
    try {
      final rentals = await _rentalService.getFavoriteRentals();
      setState(() {
        _favoriteRentals = rentals;
        _isLoadingRentals = false;
      });
    } catch (e) {
      setState(() => _isLoadingRentals = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _removeHouseFavorite(House house) async {
    final houseListViewModel = ref.read(houseListViewModelProvider.notifier);
    bool? shouldRemove = await _showRemoveConfirmationDialog(
      'Retirer ce ${house.houseType?.label.toLowerCase()} de vos favoris ?',
    );

    if (shouldRemove == true) {
      await houseListViewModel.toggleFavorite(house.id);
      _showSuccessSnackBar('Retiré des favoris');
    }
  }

  Future<void> _removeRentalFavorite(DailyRental rental) async {
    bool? shouldRemove = await _showRemoveConfirmationDialog(
      'Retirer cette location de vos favoris ?',
    );

    if (shouldRemove == true) {
      try {
        await _rentalService.toggleFavorite(rental.id);
        setState(() {
          _favoriteRentals.removeWhere((r) => r.id == rental.id);
        });
        _showSuccessSnackBar('Retiré des favoris');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  Future<bool?> _showRemoveConfirmationDialog(String message) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.favorite_outline,
                  color: Colors.red[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Retirer des favoris',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Retirer',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final houseListViewModel = ref.watch(houseListViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        surfaceTintColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Mes coups de cœur',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(
                color: primaryColor,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home_outlined, size: 18),
                          const SizedBox(width: 8),
                          const Text('Logements'),
                          if (houseListViewModel.favoriteHouses.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${houseListViewModel.favoriteHouses.length}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18),
                          const SizedBox(width: 8),
                          const Text('Séjours'),
                          if (_favoriteRentals.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${_favoriteRentals.length}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHousesFavorites(houseListViewModel),
          _buildRentalsFavorites(),
        ],
      ),
    );
  }

  // ==================== ONGLET LOGEMENTS ====================
  Widget _buildHousesFavorites(dynamic houseListViewModel) {
    if (houseListViewModel.isLoading) {
      return _buildLoadingState();
    }

    if (houseListViewModel.favoriteHouses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.home_outlined,
        title: 'Aucun logement favori',
        message: 'Parcourez nos logements et ajoutez-les à vos favoris.',
        buttonText: 'Parcourir les logements',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HouseListScreen()),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: houseListViewModel.favoriteHouses.length,
      itemBuilder: (context, index) {
        House house = houseListViewModel.favoriteHouses[index];
        return _buildHouseCard(house);
      },
    );
  }

  Widget _buildHouseCard(House house) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HouseDetailScreen(houseId: house.id),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHouseImage(house),
              _buildHouseInfo(house),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHouseImage(House house) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: CustomCachedNetworkImage(
            imageUrl: house.imageUrl,
            width: double.infinity,
            height: 200,
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            child: Text(
              house.offerType["label"],
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
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
              icon: Icon(Icons.favorite, color: Colors.red[400], size: 20),
              onPressed: () => _removeHouseFavorite(house),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHouseInfo(House house) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  house.houseType!.label.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              FormattedPrice(
                color: primaryColor,
                price: house.price,
                size: 18,
                suffix: house.offerType["value"] == "ALouer" ? '/mois' : '',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (house.houseType?.label != "Terrain")
            Row(
              children: [
                Icon(Icons.bed_outlined, color: primaryColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${house.bedrooms} chambres',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(Icons.straighten_outlined, color: primaryColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${house.area} m²',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ==================== ONGLET LOCATIONS JOURNALIÈRES ====================
  Widget _buildRentalsFavorites() {
    if (_isLoadingRentals) {
      return _buildLoadingState();
    }

    if (_favoriteRentals.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'Aucune location favorite',
        message:
            'Découvrez nos locations journalières et ajoutez vos préférées.',
        buttonText: 'Voir les locations',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DailyRentalListScreen()),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteRentals.length,
      itemBuilder: (context, index) {
        return _buildRentalCard(_favoriteRentals[index]);
      },
    );
  }

  Widget _buildRentalCard(DailyRental rental) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DailyRentalDetailScreen(rentalId: rental.id),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRentalImage(rental),
              _buildRentalInfo(rental),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRentalImage(DailyRental rental) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: CustomCachedNetworkImage(
            imageUrl: rental.imageUrl.isNotEmpty ? rental.imageUrl : '',
            width: double.infinity,
            height: 200,
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            child: Text(
              'Location journalière',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
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
              icon: Icon(Icons.favorite, color: Colors.red[400], size: 20),
              onPressed: () => _removeRentalFavorite(rental),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRentalInfo(DailyRental rental) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  rental.houseType?.label.toUpperCase() ?? 'LOCATION',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Text(
                '${NumberFormat('#,###').format(rental.pricePerNight)} GNF',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '/nuit',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${rental.address?.town.label ?? ''} / ${rental.address?.commune.label ?? ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.people_outline, color: primaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                '${rental.maxGuests} invités max',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.bed_outlined, color: primaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                '${rental.bedrooms} chambres',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== WIDGETS COMMUNS ====================
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: const LoadingSkeleton(),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.search, size: 20),
              label: Text(
                buttonText,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
