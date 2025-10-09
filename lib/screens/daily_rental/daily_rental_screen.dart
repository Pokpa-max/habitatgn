

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/dailyRental/daily_rental.dart';
import 'package:habitatgn/screens/daily_rental/daily_rental_viewmodel.dart';
import 'package:habitatgn/screens/daily_rental/daily_rental_detail_screen.dart';
import 'package:habitatgn/screens/reservation/reservation_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/skleton/house_list_skleton.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/utils/widgets.dart';
import 'package:habitatgn/widgets/reservation/unifielDaily_rental.dart';
import 'package:intl/intl.dart';

class DailyRentalListScreen extends ConsumerStatefulWidget {
  const DailyRentalListScreen({super.key});

  @override
  ConsumerState<DailyRentalListScreen> createState() =>
      _DailyRentalListScreenState();
}

class _DailyRentalListScreenState extends ConsumerState<DailyRentalListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // État local de l'interface
  bool _isFilterApplied = false;
  Timer? _debounce;

  // Filtres locaux (pour l'UI)
  double _minPrice = 0;
  double _maxPrice = double.infinity;
  String _propertyType = 'Tous';
  String _ville = '';
  int _minGuests = 0;
  DateTime? _checkIn;
  DateTime? _checkOut;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  void _bootstrap() {
    final vm = ref.read(dailyRentalViewModelProvider);
    if (!vm.isSearchActive) {
      ref.read(dailyRentalViewModelProvider.notifier).resetRentals();
      ref.read(dailyRentalViewModelProvider.notifier).fetchRentals();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final vm = ref.read(dailyRentalViewModelProvider);
    if (!_scrollController.hasClients || vm.isLoading) return;

    final atBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;

    if (!atBottom) return;

    if (vm.isSearchActive && vm.hasMoreSearch) {
      ref.read(dailyRentalViewModelProvider.notifier).loadMoreSearch();
    } else if (!vm.isSearchActive && vm.hasMore) {
      ref.read(dailyRentalViewModelProvider.notifier).fetchRentals();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().isEmpty) {
        _resetToNormalMode();
      } else {
        ref.read(dailyRentalViewModelProvider.notifier).quickTextSearch(query);
      }
    });
  }

  void _resetToNormalMode() {
    ref.read(dailyRentalViewModelProvider.notifier).deactivateSearchMode();
    ref.read(dailyRentalViewModelProvider.notifier).resetRentals();
    ref.read(dailyRentalViewModelProvider.notifier).fetchRentals();

    setState(() {
      _isFilterApplied = false;
      _resetLocalFilters();
    });
  }

  void _resetLocalFilters() {
    _propertyType = 'Tous';
    _ville = '';
    _minGuests = 0;
    _minPrice = 0;
    _maxPrice = double.infinity;
    _checkIn = null;
    _checkOut = null;
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DailyRentalFilterModal(
        currentMinPrice: _minPrice,
        currentMaxPrice: _maxPrice,
        currentPropertyType: _propertyType,
        currentVille: _ville,
        currentMinGuests: _minGuests,
        currentCheckIn: _checkIn,
        currentCheckOut: _checkOut,
        onApplyFilter: (minPrice, maxPrice, propertyType, ville, minGuests,
            checkIn, checkOut) {
          setState(() {
            _isFilterApplied = true;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _propertyType = propertyType;
            _ville = ville.trim();
            _minGuests = minGuests;
            _checkIn = checkIn;
            _checkOut = checkOut;
          });

          int? nights;
          if (checkIn != null && checkOut != null) {
            nights = checkOut.difference(checkIn).inDays;
          }

          ref.read(dailyRentalViewModelProvider.notifier).applyFilters(
                minPrice: _minPrice > 0 ? _minPrice : null,
                maxPrice:
                    (_maxPrice.isFinite && _maxPrice > 0) ? _maxPrice : null,
                propertyType: _propertyType,
                ville: _ville,
                minGuests: _minGuests,
                checkIn: _checkIn,
                checkOut: _checkOut,
                nights: nights,
              );
        },
      ),
    );
  }

  void _resetAllFilters() {
    _searchController.clear();
    setState(() {
      _isFilterApplied = false;
      _resetLocalFilters();
    });
    _resetToNormalMode();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(dailyRentalViewModelProvider);

    final List<DailyRental> displayedItems =
        vm.isSearchActive ? vm.searchResults : vm.rentals;
    final bool showLoadingTail =
        vm.isSearchActive ? vm.hasMoreSearch : vm.hasMore;
    final bool isEmpty = displayedItems.isEmpty && !vm.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilterBar(vm),
          if (vm.hasActiveFilters) _buildActiveFiltersIndicator(vm),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(dailyRentalViewModelProvider.notifier)
                    .refreshAll();
              },
              child: _buildMainContent(
                  vm, displayedItems, showLoadingTail, isEmpty),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_outlined),
        color: Colors.grey[700],
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Locations journalières',
                style: GoogleFonts.poppins(
                  color: Colors.grey[800],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            'Séjours flexibles et confortables',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.book_online, color: primaryColor),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReservationsPage()),
            );
          },
          tooltip: 'Mes réservations',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey[200]),
      ),
    );
  }

  Widget _buildSearchAndFilterBar(vm) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Où voulez-vous séjourner ?',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_outlined,
                  color: primaryColor,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: Colors.grey[400], size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  label: 'Tous',
                  isSelected: !vm.isSearchActive && !_isFilterApplied,
                  onTap: _resetAllFilters,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  label: 'Filtres',
                  icon: Icons.tune_outlined,
                  isSelected: _isFilterApplied || vm.hasActiveFilters,
                  onTap: _showFilterModal,
                ),
              ),
              const SizedBox(width: 12),
              _buildIconButton(
                icon: Icons.refresh_outlined,
                onTap: _resetAllFilters,
                tooltip: 'Réinitialiser',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersIndicator(vm) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_list, color: primaryColor, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                vm.filtersDescription.isNotEmpty
                    ? vm.filtersDescription
                    : 'Filtres appliqués',
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _resetAllFilters,
              child: Icon(Icons.close, color: primaryColor, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
      vm, List<DailyRental> items, bool showLoadingTail, bool isEmpty) {
    if (vm.isLoading && items.isEmpty) {
      return _buildLoadingState();
    }

    if (isEmpty) {
      return _buildEmptyState(vm);
    }

    return _buildRentalList(items, showLoadingTail, vm.isLoading);
  }

  Widget _buildFilterButton({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 18),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey[600], size: 20),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: LoadingSkeleton(),
      ),
    );
  }

  Widget _buildEmptyState(vm) {
    final isSearchMode = vm.isSearchActive;

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
                isSearchMode
                    ? Icons.search_off_outlined
                    : Icons.home_work_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchMode
                  ? 'Aucun logement trouvé'
                  : 'Aucune location disponible',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSearchMode
                  ? 'Essayez de modifier vos critères de recherche ou supprimez certains filtres.'
                  : 'Il n\'y a actuellement aucune location journalière disponible.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _resetAllFilters,
              icon: Icon(
                isSearchMode
                    ? Icons.refresh_outlined
                    : Icons.home_work_outlined,
                size: 20,
              ),
              label: Text(
                isSearchMode ? 'Réinitialiser la recherche' : 'Actualiser',
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

  Widget _buildRentalList(
      List<DailyRental> rentals, bool showLoadingTail, bool isLoading) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: rentals.length + (showLoadingTail && isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == rentals.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final rental = rentals[index];
        return _buildDailyRentalCard(context, rental);
      },
    );
  }

  Widget _buildDailyRentalCard(BuildContext context, DailyRental rental) {
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
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // ✅ CORRECTION: Navigation vers l'écran de détail spécifique aux locations journalières
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DailyRentalDetailScreen(
                  rentalId: rental.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: CustomCachedNetworkImage(
                        imageUrl: rental.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  // Badge Location journalière
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Journalière',
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
                  // Badge disponibilité (optionnel)
                  if (rental.isAvailable == false)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Non disponible',
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (rental.houseType!.label).toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.bed_outlined,
                                      color: Colors.grey[600], size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${rental.bedrooms} chambre${rental.bedrooms > 1 ? 's' : ''}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              NumberFormat('#,###')
                                  .format(rental.pricePerNight),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              'GNF/nuit',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
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
                            '${rental.address!.town.label} / ${rental.address!.commune.label}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.people_outline,
                          label:
                              '${rental.maxGuests ?? 2} invité${(rental.maxGuests ?? 2) > 1 ? 's' : ''}',
                          color: primaryColor,
                        ),
                        const SizedBox(width: 12),
                        if (rental.minStay != null && rental.minStay! > 0)
                          _buildInfoChip(
                            icon: Icons.event_note,
                            label:
                                'Min ${rental.minStay} nuit${rental.minStay! > 1 ? 's' : ''}',
                            color: Colors.grey[700]!,
                          ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          icon: Icons.access_time,
                          label:
                              '${rental.checkInHour}h - ${rental.checkOutHour}h',
                          color: Colors.grey[700]!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DailyRentalDetailScreen(
                                    rentalId: rental.id,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.info_outline, size: 18),
                            label: Text(
                              'Détails',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryColor,
                              side: BorderSide(color: primaryColor, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: rental.isAvailable
                                ? () => _showBookingModal(context, rental)
                                : null,
                            icon: const Icon(Icons.book_online, size: 18),
                            label: Text(
                              rental.isAvailable ? 'Réserver' : 'Indisponible',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              disabledForegroundColor: Colors.grey[500],
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingModal(BuildContext context, DailyRental rental) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UnifiedDailyRentalModal(
        houseId: rental.id,
        houseTitle: rental.houseType!.label,
        houseLocation:
            '${rental.address!.town.label} / ${rental.address!.commune.label}',
        pricePerNight: rental.pricePerNight.toDouble(),
        maxGuests: rental.maxGuests,
        minStay: rental.minStay,
        maxStay: rental.maxStay,
        checkInHour: rental.checkInHour,
        checkOutHour: rental.checkOutHour,
        houseImageUrl: rental.imageUrl,
        onBookingSuccess: () {
          ref.read(dailyRentalViewModelProvider.notifier).refreshAll();
        },
      ),
    );
  }
}

class DailyRentalFilterModal extends StatefulWidget {
  final double currentMinPrice;
  final double currentMaxPrice;
  final String currentPropertyType;
  final String currentVille;
  final int currentMinGuests;
  final DateTime? currentCheckIn;
  final DateTime? currentCheckOut;
  final Function(
    double minPrice,
    double maxPrice,
    String propertyType,
    String ville,
    int minGuests,
    DateTime? checkIn,
    DateTime? checkOut,
  ) onApplyFilter;

  const DailyRentalFilterModal({
    super.key,
    required this.currentMinPrice,
    required this.currentMaxPrice,
    required this.currentPropertyType,
    required this.currentVille,
    required this.currentMinGuests,
    this.currentCheckIn,
    this.currentCheckOut,
    required this.onApplyFilter,
  });

  @override
  State<DailyRentalFilterModal> createState() => _DailyRentalFilterModalState();
}

class _DailyRentalFilterModalState extends State<DailyRentalFilterModal> {
  late double _minPrice;
  late double _maxPrice;
  late String _propertyType;
  late String _selectedVille;
  late TextEditingController _autreVilleController;
  late int _minGuests;
  DateTime? _checkIn;
  DateTime? _checkOut;

  // Types de propriétés disponibles
  final List<PropertyType> _propertyTypes = const [
    PropertyType('Tous', Icons.grid_view_rounded),
    PropertyType('Maison', Icons.home),
    PropertyType('Appartement', Icons.apartment),
    PropertyType('Villa', Icons.villa),
    PropertyType('Studio', Icons.door_sliding),
    PropertyType('Chambre', Icons.bed),
    PropertyType('Duplex', Icons.layers),
    PropertyType('Bungalow', Icons.cottage),
  ];
  // Villes principales (80% des recherches)
  final List<String> _villesPrincipales = const [
    'Toutes',
    'Conakry',
    'Kindia',
    'Labé',
    'Kankan',
    'N\'Zérékoré',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _minPrice = widget.currentMinPrice;
    _maxPrice =
        widget.currentMaxPrice.isFinite ? widget.currentMaxPrice : 5000000;
    _propertyType = widget.currentPropertyType;

    // Gérer la ville initiale
    if (widget.currentVille.isEmpty) {
      _selectedVille = 'Toutes';
      _autreVilleController = TextEditingController();
    } else if (_villesPrincipales.contains(widget.currentVille)) {
      _selectedVille = widget.currentVille;
      _autreVilleController = TextEditingController();
    } else {
      _selectedVille = 'Autre';
      _autreVilleController = TextEditingController(text: widget.currentVille);
    }

    _minGuests = widget.currentMinGuests;
    _checkIn = widget.currentCheckIn;
    _checkOut = widget.currentCheckOut;
  }

  @override
  void dispose() {
    _autreVilleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtres',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Type de logement
              Text(
                'Type de logement',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _propertyTypes
                    .map((type) => _buildPropertyTypeChip(
                          label: type.label,
                          icon: type.icon,
                          isSelected: _propertyType == type.label,
                          onTap: () {
                            setState(() => _propertyType = type.label);
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Ville/Localisation
              Text(
                'Ville ou localisation',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _villesPrincipales
                    .map((ville) => _buildVilleChip(
                          label: ville,
                          isSelected: _selectedVille == ville,
                          onTap: () {
                            setState(() {
                              _selectedVille = ville;
                              if (ville != 'Autre') {
                                _autreVilleController.clear();
                              }
                            });
                          },
                        ))
                    .toList(),
              ),

              // Champ texte pour "Autre ville"
              if (_selectedVille == 'Autre') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _autreVilleController,
                  autofocus: true,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ex: Mamou, Boké, Kissidougou,Macenta...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.edit_location, color: primaryColor),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Prix
              Text(
                'Fourchette de prix (GNF/nuit)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: 0,
                max: 5000000,
                divisions: 100,
                activeColor: primaryColor,
                labels: RangeLabels(
                  NumberFormat('#,###').format(_minPrice),
                  NumberFormat('#,###').format(_maxPrice),
                ),
                onChanged: (values) {
                  setState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${NumberFormat('#,###').format(_minPrice)} GNF',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(_maxPrice)} GNF',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nombre d'invités
              Text(
                'Nombre d\'invités',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: _minGuests > 0
                        ? () => setState(() => _minGuests--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$_minGuests',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _minGuests++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _minPrice = 0;
                          _maxPrice = 5000000;
                          _propertyType = 'Tous';
                          _selectedVille = 'Toutes';
                          _autreVilleController.clear();
                          _minGuests = 0;
                          _checkIn = null;
                          _checkOut = null;
                        });
                      },
                      child: Text(
                        'Réinitialiser',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        // Déterminer la ville à envoyer
                        String villeToSend = '';
                        if (_selectedVille == 'Toutes') {
                          villeToSend = '';
                        } else if (_selectedVille == 'Autre') {
                          villeToSend = _autreVilleController.text.trim();
                        } else {
                          villeToSend = _selectedVille;
                        }

                        widget.onApplyFilter(
                          _minPrice,
                          _maxPrice,
                          _propertyType,
                          villeToSend,
                          _minGuests,
                          _checkIn,
                          _checkOut,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Appliquer',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyTypeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey[200]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? primaryColor : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isSelected ? primaryColor : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVilleChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Icône spéciale pour "Autre"
    final icon = label == 'Autre' ? Icons.edit_location : Icons.location_on;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey[200]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? primaryColor : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isSelected ? primaryColor : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
