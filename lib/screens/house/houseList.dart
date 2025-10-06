import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // État local de l'interface
  bool _isFilterApplied = false;
  Timer? _debounce;

  // Filtres locaux (pour l'UI)
  double _minPrice = 0;
  double _maxPrice = double.infinity;
  String _needType = 'Tous';
  String _propertyType = 'Tous';
  String _ville = '';
  int _bedrooms = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Délayer la modification du provider après la construction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  void _bootstrap() {
    // Initialiser selon l'état du ViewModel
    final vm = ref.read(dashbordViewModelProvider);
    if (!vm.isSearchActive) {
      // Mode normal : charger tous les logements
      ref.read(dashbordViewModelProvider.notifier).resetHouses();
      ref.read(dashbordViewModelProvider.notifier).fetchHouses();
    }
    // Sinon, le mode recherche est déjà actif avec des résultats
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Gestion du scroll et pagination
  // ────────────────────────────────────────────────────────────────────────────
  void _onScroll() {
    final vm = ref.read(dashbordViewModelProvider);
    if (!_scrollController.hasClients || vm.isLoading) return;

    final atBottom = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;

    if (!atBottom) return;

    if (vm.isSearchActive && vm.hasMoreSearch) {
      // Mode recherche : charger plus de résultats de recherche
      ref.read(dashbordViewModelProvider.notifier).loadMoreSearch();
    } else if (!vm.isSearchActive && vm.hasMore) {
      // Mode normal : charger plus de logements
      ref.read(dashbordViewModelProvider.notifier).fetchHouses();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Recherche textuelle avec debounce
  // ────────────────────────────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.trim().isEmpty) {
        // Retour au mode normal
        _resetToNormalMode();
      } else {
        // Recherche textuelle
        ref.read(dashbordViewModelProvider.notifier).quickTextSearch(query);
      }
    });
  }

  void _resetToNormalMode() {
    ref.read(dashbordViewModelProvider.notifier).deactivateSearchMode();
    ref.read(dashbordViewModelProvider.notifier).resetHouses();
    ref.read(dashbordViewModelProvider.notifier).fetchHouses();

    setState(() {
      _isFilterApplied = false;
      _resetLocalFilters();
    });
  }

  void _resetLocalFilters() {
    _needType = 'Tous';
    _propertyType = 'Tous';
    _ville = '';
    _bedrooms = 0;
    _minPrice = 0;
    _maxPrice = double.infinity;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Gestion des filtres
  // ────────────────────────────────────────────────────────────────────────────
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        currentMinPrice: _minPrice,
        currentMaxPrice: _maxPrice,
        currentNeedType: _needType,
        currentPropertyType: _propertyType,
        currentVille: _ville,
        currentBedrooms: _bedrooms,
        onApplyFilter:
            (minPrice, maxPrice, needType, propertyType, ville, bedrooms) {
          setState(() {
            _isFilterApplied = true;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _needType = needType;
            _propertyType = propertyType;
            _ville = ville.trim();
            _bedrooms = bedrooms;
          });

          // Appliquer les filtres avec la recherche actuelle
          ref.read(dashbordViewModelProvider.notifier).applyFilters(
                minPrice: _minPrice > 0 ? _minPrice : null,
                maxPrice:
                    (_maxPrice.isFinite && _maxPrice > 0) ? _maxPrice : null,
                needType: _needType,
                propertyType: _propertyType,
                ville: _ville,
                bedrooms: _bedrooms,
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

  // ────────────────────────────────────────────────────────────────────────────
  // Interface utilisateur
  // ────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(dashbordViewModelProvider);

    // Déterminer quelle liste afficher
    final List<House> displayedItems =
        vm.isSearchActive ? vm.searchResults : vm.houses;
    final bool showLoadingTail =
        vm.isSearchActive ? vm.hasMoreSearch : vm.hasMore;
    final bool isEmpty = displayedItems.isEmpty && !vm.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Barre de recherche et filtres
          _buildSearchAndFilterBar(vm),

          // Indicateur de filtres actifs
          if (vm.hasActiveFilters) _buildActiveFiltersIndicator(vm),

          // Zone principale de contenu
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (vm.isSearchActive) {
                  // Recharger la recherche actuelle
                  await ref
                      .read(dashbordViewModelProvider.notifier)
                      .searchAndFilter(
                        query: vm.currentQuery,
                        minPrice: vm.currentFilters['minPrice'],
                        maxPrice: vm.currentFilters['maxPrice'],
                        needType: vm.currentFilters['needType'] ?? 'Tous',
                        propertyType:
                            vm.currentFilters['propertyType'] ?? 'Tous',
                        ville: vm.currentFilters['ville'] ?? '',
                        bedrooms: vm.currentFilters['bedrooms'] ?? 0,
                        reset: true,
                      );
                } else {
                  // Recharger la liste normale
                  ref.read(dashbordViewModelProvider.notifier).resetHouses();
                  await ref
                      .read(dashbordViewModelProvider.notifier)
                      .fetchHouses();
                }
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
      title: Text(
        'Tous les logements',
        style: GoogleFonts.poppins(
          color: Colors.grey[800],
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
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
          // Champ de recherche
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
                hintText: 'Rechercher un logement...',
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

          // Boutons de contrôle
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
      vm, List<House> items, bool showLoadingTail, bool isEmpty) {
    if (vm.isLoading && items.isEmpty) {
      return _buildLoadingState();
    }

    if (isEmpty) {
      return _buildEmptyState(vm);
    }

    return _buildHouseList(items, showLoadingTail, vm.isLoading);
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
                isSearchMode ? Icons.search_off_outlined : Icons.home_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchMode
                  ? 'Aucun résultat trouvé'
                  : 'Aucun logement disponible',
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
                  : 'Il n\'y a actuellement aucun logement disponible. Revenez plus tard.',
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
                isSearchMode ? Icons.refresh_outlined : Icons.home_outlined,
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

  Widget _buildHouseList(
      List<House> houses, bool showLoadingTail, bool isLoading) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: houses.length + (showLoadingTail && isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == houses.length) {
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

        final house = houses[index];
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
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HouseDetailScreen(houseId: house.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: CustomCachedNetworkImage(
                        imageUrl: house.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        house.offerType["label"] ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Informations
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
                          child: Text(
                            (house.houseType?.label ?? '').toUpperCase(),
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
                          suffix: (house.offerType["value"] == "Louer")
                              ? '/mois'
                              : '',
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
                          child: Icon(Icons.location_on_outlined,
                              color: Colors.grey[600], size: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${house.address?.town["label"] ?? ''} / ${house.address?.commune["label"] ?? ''}',
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
                      _buildBedroomsRow(house)
                    else
                      _buildAreaRow(house),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBedroomsRow(House house) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.bed_outlined, color: primaryColor, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          '${house.bedrooms} chambre${house.bedrooms > 1 ? 's' : ''}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAreaRow(House house) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.straighten_outlined, color: primaryColor, size: 16),
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

// ────────────────────────────────────────────────────────────────────────────
// MODAL FILTRES OPTIMISÉE
// ────────────────────────────────────────────────────────────────────────────
class FilterModal extends StatefulWidget {
  final Function(double, double, String, String, String, int) onApplyFilter;
  final double currentMinPrice;
  final double currentMaxPrice;
  final String currentNeedType;
  final String currentPropertyType;
  final String currentVille;
  final int currentBedrooms;

  const FilterModal({
    super.key,
    required this.onApplyFilter,
    this.currentMinPrice = 0,
    this.currentMaxPrice = double.infinity,
    this.currentNeedType = 'Tous',
    this.currentPropertyType = 'Tous',
    this.currentVille = '',
    this.currentBedrooms = 0,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late String _propertyType;
  late String _needType;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _villeController;
  late int _bedrooms;

  @override
  void initState() {
    super.initState();
    _propertyType = widget.currentPropertyType;
    _needType = widget.currentNeedType;
    _bedrooms = widget.currentBedrooms;

    _minPriceController = TextEditingController(
      text: widget.currentMinPrice > 0
          ? widget.currentMinPrice.toInt().toString()
          : '',
    );
    _maxPriceController = TextEditingController(
      text: widget.currentMaxPrice.isFinite
          ? widget.currentMaxPrice.toInt().toString()
          : '',
    );
    _villeController = TextEditingController(text: widget.currentVille);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtres',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      TextButton(
                        onPressed: _resetAllFilters,
                        child: Text(
                          'Réinitialiser',
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Type de besoin'),
                  const SizedBox(height: 12),
                  _buildNeedTypeSelector(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Localisation'),
                  const SizedBox(height: 12),
                  _buildLocationField(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Type de propriété'),
                  const SizedBox(height: 12),
                  _buildPropertyTypeGrid(),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Budget'),
                  const SizedBox(height: 12),
                  _buildBudgetFields(),
                  const SizedBox(height: 24),

                  if (_propertyType != 'Terrain') ...[
                    _buildSectionTitle('Nombre de chambres'),
                    const SizedBox(height: 12),
                    _buildBedroomSelector(),
                    const SizedBox(height: 24),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Appliquer les filtres',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      );

  Widget _buildNeedTypeSelector() {
    return Row(
      children: ['Tous', 'Louer', 'Vendre'].map((type) {
        final isSelected = _needType == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildSelectableChip(
              label: type,
              isSelected: isSelected,
              onTap: () => setState(() => _needType = type),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationField() {
    return TextField(
      controller: _villeController,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Ville, commune, quartier...',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
        prefixIcon: Icon(Icons.location_on_outlined, color: primaryColor),
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
      ),
    );
  }

  Widget _buildPropertyTypeGrid() {
    final types = [
      {'label': 'Tous', 'icon': Icons.dashboard_outlined},
      {'label': 'Villa', 'icon': Icons.villa_outlined},
      {'label': 'Maison', 'icon': Icons.home_outlined},
      {'label': 'Appartement', 'icon': Icons.apartment_outlined},
      {'label': 'Studio', 'icon': Icons.single_bed_outlined},
      {'label': 'Chambre', 'icon': Icons.bed_outlined},
      {'label': 'Bureau', 'icon': Icons.business_outlined},
      {'label': 'Magasin', 'icon': Icons.store_outlined},
      {'label': 'Terrain', 'icon': Icons.landscape_outlined},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _propertyType == type['label'];
        return _buildPropertyTypeChip(
          label: type['label'] as String,
          icon: type['icon'] as IconData,
          isSelected: isSelected,
          onTap: () => setState(() => _propertyType = type['label'] as String),
        );
      }).toList(),
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

  Widget _buildBudgetFields() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Prix minimum',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
              prefixIcon:
                  Icon(Icons.attach_money_outlined, color: primaryColor),
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
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Prix maximum',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
              prefixIcon:
                  Icon(Icons.attach_money_outlined, color: primaryColor),
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBedroomSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircularButton(
            icon: Icons.remove,
            onPressed: _bedrooms > 0 ? () => setState(() => _bedrooms--) : null,
          ),
          Column(
            children: [
              Text(
                '$_bedrooms',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'chambre${_bedrooms > 1 ? 's' : ''}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          _buildCircularButton(
            icon: Icons.add,
            onPressed: () => setState(() => _bedrooms++),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(
      {required IconData icon, VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: onPressed != null ? primaryColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: onPressed != null ? Colors.white : Colors.grey[500],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
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
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetAllFilters() {
    setState(() {
      _needType = 'Tous';
      _propertyType = 'Tous';
      _minPriceController.clear();
      _maxPriceController.clear();
      _villeController.clear();
      _bedrooms = 0;
    });
  }

  void _applyFilters() {
    final minPrice = double.tryParse(_minPriceController.text) ?? 0;
    final maxPrice =
        double.tryParse(_maxPriceController.text) ?? double.infinity;

    widget.onApplyFilter(
      minPrice,
      maxPrice,
      _needType,
      _propertyType,
      _villeController.text,
      _bedrooms,
    );

    Navigator.pop(context);
  }
}
