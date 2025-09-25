// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/house/houseList.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/skleton/house_list_skleton.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/housings/house_list.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final houseListViewModel = ref.read(houseListViewModelProvider.notifier);
    await houseListViewModel.fetchFavorites();
  }

  Future<void> _removeFavorite(House house) async {
    final houseListViewModel = ref.read(houseListViewModelProvider.notifier);

    // Afficher un dialog de confirmation
    bool? shouldRemove = await _showRemoveConfirmationDialog(house);

    if (shouldRemove == true) {
      await houseListViewModel.toggleFavorite(house.id);

      // Afficher un feedback de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Retiré des favoris',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<bool?> _showRemoveConfirmationDialog(House house) {
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
              Text(
                'Retirer des favoris',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          content: Text(
            'Êtes-vous sûr de vouloir retirer ce ${house.houseType?.label.toLowerCase()} de vos favoris ?',
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
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final houseListViewModel = ref.watch(houseListViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          'Mes coups de cœur',
          style: GoogleFonts.poppins(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
        actions: [
          if (houseListViewModel.favoriteHouses.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${houseListViewModel.favoriteHouses.length}',
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: houseListViewModel.isLoading
          ? _buildLoadingState()
          : houseListViewModel.favoriteHouses.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesList(houseListViewModel),
    );
  }

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

  Widget _buildEmptyState() {
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
              child: Icon(
                Icons.favorite_outline,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun favori pour le moment',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Parcourez nos logements et ajoutez-les à vos favoris pour les retrouver facilement ici.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HouseListScreen(),
                  ),
                );
                ;
              },
              icon: const Icon(Icons.search, size: 20),
              label: Text(
                'Parcourir les logements',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
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

  Widget _buildFavoritesList(dynamic houseListViewModel) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!houseListViewModel.isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            houseListViewModel.hasMore) {
          houseListViewModel.fetchHouses();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: houseListViewModel.favoriteHouses.length,
        itemBuilder: (context, index) {
          House house = houseListViewModel.favoriteHouses[index];
          return _buildHouseCard(house, index);
        },
      ),
    );
  }

  Widget _buildHouseCard(House house, int index) {
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
                builder: (context) => HouseDetailScreen(
                  houseId: house.id,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(house),
              _buildInfoSection(house),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(House house) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          child: CustomCachedNetworkImage(
            imageUrl: house.imageUrl,
            width: double.infinity,
            height: 200,
          ),
        ),
        // Gradient overlay pour améliorer la lisibilité
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
        // Badge type d'offre
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
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
        // Bouton suppression
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
              icon: Icon(
                Icons.favorite,
                color: Colors.red[400],
                size: 20,
              ),
              onPressed: () => _removeFavorite(house),
              tooltip: 'Retirer des favoris',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(House house) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(width: 12),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (house.houseType?.label != "Terrain")
            _buildModernBedroomsRow(house)
          else
            _buildModernAreaRow(house),
        ],
      ),
    );
  }

  Widget _buildModernBedroomsRow(House house) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.bed_outlined,
            color: primaryColor,
            size: 16,
          ),
        ),
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
    );
  }

  Widget _buildModernAreaRow(House house) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.straighten_outlined,
            color: primaryColor,
            size: 16,
          ),
        ),
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
    );
  }
}
