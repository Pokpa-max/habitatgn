import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
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
  bool _isFilterApplied = false;
  bool _hasChanges = false;
  String _searchQuery = '';

  double _minPrice = 0;
  int _bedrooms = 0;
  double _maxPrice = double.infinity;
  String _needType = 'Tous';
  String _propertyType = 'Tous';
  String _ville = '';

  @override
  void initState() {
    super.initState();
    _fetchHouses();
  }

  @override
  void didUpdateWidget(HouseListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchHouses();
  }

  void _fetchHouses() {
    ref.read(dashbordViewModelProvider.notifier).resetHouses();
    ref.read(dashbordViewModelProvider.notifier).fetchHouses();
  }

  void performSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchPage(),
      ),
    );
  }

  void showFilterModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
              horizontal: 16.0), // Ajuste la largeur du modal
          child: FractionallySizedBox(
            heightFactor: 1.0, // Ajuste la hauteur du modal
            child: FilterModal(
              onApplyFilter: (minPrice, maxPrice, needType, propertyType, ville,
                  bedrooms, hasChanges) {
                setState(() {
                  _isFilterApplied = true;
                  _minPrice = minPrice;
                  _maxPrice = maxPrice;
                  _needType = needType;
                  _propertyType = propertyType;
                  _ville = ville.trim();
                  _bedrooms = bedrooms;
                  _hasChanges = hasChanges;
                });
                // afficher les filtres
                ref
                    .read(dashbordViewModelProvider.notifier)
                    .fetchFilteredHouses(
                        propertyType: propertyType.toLowerCase(),
                        ville: ville.toLowerCase().trim(),
                        minPrice: minPrice,
                        maxPrice: maxPrice,
                        needType: needType,
                        bedrooms: bedrooms);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // afficher tous les

    final houseListViewModel = ref.watch(dashbordViewModelProvider);
    List<House> filteredHouses = [];

    final lowerCaseQuery = _searchQuery.trim().toLowerCase();
    final lowerCaseZone = _ville.toLowerCase();
    final lowcaseOfferType = _needType == "Acheter"
        ? "AVendre".toLowerCase()
        : _needType != "Tous"
            ? "ALouer".toLowerCase()
            : _needType.toLowerCase();

// Fonction de filtrage par recherche
    bool matchesQuery(House house) {
      final houseTypeLabel = house.houseType?.label.toLowerCase() ?? '';
      final houseDescription = house.description.toLowerCase();
      final houseZone = house.address?.zone.toLowerCase() ?? '';
      final houseTown = house.address?.town["label"].toLowerCase() ?? '';
      final houseCommune = house.address?.commune["label"].toLowerCase() ?? '';

      return houseTypeLabel.contains(lowerCaseQuery) ||
          houseDescription.contains(lowerCaseQuery) ||
          houseCommune.contains(lowerCaseQuery) ||
          houseTown.contains(lowerCaseQuery) ||
          houseZone.contains(lowerCaseQuery);
    }

// Fonction de filtrage par critères
    bool matchesFilter(House house) {
      final offerType = house.offerType["value"].trim().toLowerCase();
      final houseTypeLabel = house.houseType?.label.trim().toLowerCase() ?? '';
      final houseZone = house.address?.zone.toLowerCase() ?? '';
      final houseTown = house.address?.town["label"].toLowerCase() ?? '';
      final houseCommune = house.address?.commune["label"].toLowerCase() ?? '';

      return !_hasChanges ||
          (house.price >= _minPrice &&
              house.price <= _maxPrice &&
              (_needType == 'Tous' || offerType == lowcaseOfferType) &&
              (_propertyType == 'Tous' ||
                  houseTypeLabel == _propertyType.trim().toLowerCase()) &&
              (houseZone.contains(lowerCaseZone) ||
                  houseTown.contains(lowerCaseZone) ||
                  houseCommune.contains(lowerCaseZone)) &&
              (_needType == 'Tous' || house.bedrooms == _bedrooms));
    }

    if (_hasChanges) {
      filteredHouses = houseListViewModel.housefilter;
    } else {
      filteredHouses = houseListViewModel.houses.where((house) {
        return matchesQuery(house) && matchesFilter(house);
      }).toList();
    }

    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: AppBar(
        toolbarHeight: screenHeight * 0.12,
        //  100,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomTitle(
              text: "Toutes nos Annonces  ",
              textColor: primaryColor,
            ),
            const SizedBox(height: 10),
            _buildSearchBar(),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la liste
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 8,
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
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !_isFilterApplied
                                      ? primaryColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(11)),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isFilterApplied = false;
                                      });
                                    },
                                    borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(11)),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Tous",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: !_isFilterApplied
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1.5,
                              color: primaryColor,
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isFilterApplied
                                      ? primaryColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(11)),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isFilterApplied = true;
                                      });
                                      showFilterModal();
                                    },
                                    borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(11)),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.filter_list,
                                            size: 20,
                                            color: _isFilterApplied
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Filtres",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: _isFilterApplied
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor, width: 1.5),
                      ),
                      child: IconButton(
                        icon:
                            Icon(Icons.refresh, color: primaryColor, size: 22),
                        onPressed: () {
                          setState(() {
                            _isFilterApplied = false;
                            _hasChanges = false;
                            _searchQuery = "";
                            _searchController.clear();
                            _needType = "Tous";
                            _propertyType = "Tous";
                            _ville = "";
                            _bedrooms = 0;
                            _minPrice = 0;
                            _maxPrice = 0;
                          });
                        },
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: houseListViewModel.isLoading
                ? ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) => const LoadingSkeleton(),
                  )
                : filteredHouses.isEmpty
                    ? houseCategoryListEmpty()
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (!houseListViewModel.isLoading &&
                              scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent &&
                              houseListViewModel.hasMore) {
                            houseListViewModel.fetchHouses();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          itemCount: filteredHouses.length + 1,
                          itemBuilder: (context, index) {
                            if (index == filteredHouses.length) {
                              return houseListViewModel.hasMore
                                  ? const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: primaryColor,
                                        ),
                                      ),
                                    )
                                  : Container();
                            }

                            // double screenWidth =
                            //     MediaQuery.of(context).size.width;
                            double screenHeight =
                                MediaQuery.of(context).size.height;
                            House house = filteredHouses[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Image section avec badge overlay
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                            child: CustomCachedNetworkImage(
                                              imageUrl: house.imageUrl,
                                              width: double.infinity,
                                              height: screenHeight * 0.22,
                                            ),
                                          ),
                                          Positioned(
                                            top: 12,
                                            right: 12,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                house.offerType["label"],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Informations section
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  house.houseType!.label
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                FormattedPrice(
                                                  color: primaryColor,
                                                  price: house.price,
                                                  size: 18,
                                                  suffix: house.offerType[
                                                              "value"] ==
                                                          "ALouer"
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
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    '${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            if (house.houseType?.label !=
                                                "Terrain")
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
                          },
                        ),
                      ),
          )
        ],
      ),
    );
  }

  Widget _buildBedroomsRow(House house) {
    return Row(
      children: [
        const Icon(Icons.king_bed, color: Colors.grey),
        const SizedBox(width: 8),
        Text('${house.bedrooms} chambres',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAreaRow(House house) {
    return Row(
      children: [
        const Icon(Icons.area_chart_sharp, color: Colors.grey),
        const SizedBox(width: 8),
        Text('${house.area} m²',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          autofocus: false,
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
          decoration: InputDecoration(
            filled: true,
            labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
            fillColor: Colors.grey.withOpacity(0.2),
            hintText: 'Trouvez ici votre maison, appartement, ou terrain...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),

            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Au
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class FilterModal extends StatefulWidget {
  final Function(double, double, String, String, String, int, bool)
      onApplyFilter;

  const FilterModal({super.key, required this.onApplyFilter});

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String _propertyType = 'Tous';
  String _needType = 'Tous';
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _villeController = TextEditingController();
  int _bedrooms = 0;
  bool _hasChanges = false;

  // Couleurs personnalisées

  final backgroundColor = Colors.white;
  final surfaceColor = const Color(0xFFF3F4F6); // Gray-100

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
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "J'ai besoin de ?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _needType = 'Tous';
                      _propertyType = 'Tous';
                      _minPriceController.clear();
                      _maxPriceController.clear();
                      _villeController.clear();
                      _bedrooms = 0;
                      _hasChanges = false;
                    });
                  },
                  child: Text(
                    'Réinitialiser',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: ['Tous', 'Louer', 'Acheter'].map((type) {
                final isSelected = _needType == type;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _needType = type;
                          _hasChanges = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Section Emplacement
            const Text(
              "Emplacement",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _villeController,
              decoration: InputDecoration(
                hintText: 'Ville, commune, quartier...',
                prefixIcon: const Icon(Icons.location_on_outlined),
                filled: true,
                fillColor: surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
              onChanged: (_) => setState(() => _hasChanges = true),
            ),
            const SizedBox(height: 12),

            // Section Type de propriété
            const Text(
              "Type de propriété",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPropertyTypeChip('Tous', Icons.dashboard_outlined),
                _buildPropertyTypeChip('Villa', Icons.villa_outlined),
                _buildPropertyTypeChip('Maison', Icons.home_outlined),
                _buildPropertyTypeChip('Appartement', Icons.apartment_outlined),
                _buildPropertyTypeChip('Studio', Icons.single_bed_outlined),
                _buildPropertyTypeChip('Hôtel', Icons.hotel_outlined),
                _buildPropertyTypeChip('Terrain', Icons.landscape_outlined),
                _buildPropertyTypeChip('Commerce', Icons.storefront_outlined),
                _buildPropertyTypeChip('Bureau', Icons.business_outlined),
              ],
            ),
            const SizedBox(height: 12),

            // Section Budget
            const Text(
              "Budget",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Prix min',
                      prefixIcon: const Icon(Icons.attach_money_outlined),
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Prix max',
                      prefixIcon: const Icon(Icons.attach_money_outlined),
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Section Nombre de chambres
            if (_propertyType != 'Terrain') ...[
              const Text(
                "Nombre de chambres",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircularButton(
                      icon: Icons.remove,
                      onPressed: () {
                        if (_bedrooms > 0) {
                          setState(() {
                            _bedrooms--;
                            _hasChanges = true;
                          });
                        }
                      },
                    ),
                    Text(
                      '$_bedrooms',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    _buildCircularButton(
                      icon: Icons.add,
                      onPressed: () {
                        setState(() {
                          _bedrooms++;
                          _hasChanges = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Bouton Appliquer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  double minPrice =
                      double.tryParse(_minPriceController.text) ?? 0;
                  double maxPrice = double.tryParse(_maxPriceController.text) ??
                      double.infinity;
                  widget.onApplyFilter(
                    minPrice,
                    maxPrice,
                    _needType,
                    _propertyType,
                    _villeController.text,
                    _bedrooms,
                    _hasChanges,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Appliquer les filtres',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTypeChip(String label, IconData icon) {
    final isSelected = _propertyType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _propertyType = label;
          _hasChanges = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: Colors.black87,
        padding: const EdgeInsets.all(5),
      ),
    );
  }
}
