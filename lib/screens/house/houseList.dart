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
                // to do apply filter from firebase

                // affiche tous
                print(
                    "minPrice ⛪⛪😋😋😋: $_minPrice, maxPrice: $_maxPrice, needType: $_needType, propertyType: $_propertyType, ville: $_ville, bedrooms: $_bedrooms");

                ref
                    .read(dashbordViewModelProvider.notifier)
                    .fetchFilteredHouses(
                        propertyType: propertyType,
                        ville: ville,
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
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ToggleButtons(
                          isSelected: [
                            !_isFilterApplied,
                            _isFilterApplied
                          ], // Notez le changement ici
                          onPressed: (int index) {
                            setState(() {
                              _isFilterApplied = index ==
                                  1; // Mise à jour pour sélectionner le filtre
                            });
                            if (index == 1) {
                              showFilterModal(); // Ouvrir le modal lorsque le filtre est sélectionné
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          selectedColor: Colors.white,
                          fillColor: primaryColor,
                          color: Colors.black,

                          borderColor: lightPrimary2,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child:
                                  Text("Tous", style: TextStyle(fontSize: 18)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.filter_list,
                                    color: Colors.white,
                                  ),
                                  Text("Appliquer les filtres",
                                      style: TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: primaryColor),
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
                    )
                  ],
                ),
              ],
            ),
          ),
          // Liste des maisons
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
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                      color: primaryColor,
                                    ))
                                  : Container();
                            }
                            double screenWidth =
                                MediaQuery.of(context).size.width;
                            double screenHeight =
                                MediaQuery.of(context).size.height;

                            House house = filteredHouses[index];
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Card(
                                color: Colors.white,
                                elevation: 0.5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: lightPrimary2),
                                ),
                                child: InkWell(
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
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: CustomCachedNetworkImage(
                                          imageUrl: house.imageUrl,
                                          width: screenWidth * 0.45,
                                          height: screenHeight * 0.20,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
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
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4,
                                                        horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      house.offerType["label"],
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                if (house.houseType?.label !=
                                                    "Terrain") ...[
                                                  _buildBedroomsRow(house),
                                                ],
                                                if (house.houseType?.label ==
                                                    "Terrain") ...[
                                                  _buildAreaRow(house),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 6),

                                            Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  ' ${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.attach_money_outlined,
                                                    color: Colors.grey),
                                                Expanded(
                                                  child: FormattedPrice(
                                                    color: Colors.black,
                                                    price: house.price,
                                                    size: 16,
                                                    suffix: house.offerType[
                                                                "value"] ==
                                                            "ALouer"
                                                        ? '/mois'
                                                        : '',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // _buildAdditionalInfo(house),
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
          ),
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

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  void _onApplyFilter() {
    double minPrice = double.tryParse(_minPriceController.text) ?? 0;
    double maxPrice =
        double.tryParse(_maxPriceController.text) ?? double.infinity;
    widget.onApplyFilter(minPrice, maxPrice, _needType, _propertyType,
        _villeController.text, _bedrooms, _hasChanges);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "J'ai besoin de ?",
                  style: TextStyle(fontSize: 18),
                ),
                IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ],
            ),
            SegmentedButton<String>(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return Colors.black;
                  },
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return primaryColor;
                    }
                    return Colors.white;
                  },
                ),
              ),
              segments: const [
                ButtonSegment(
                  value: 'Tous',
                  label: Text(
                    'Tous',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                ButtonSegment(
                  value: 'Louer',
                  label: Text('Louer', style: TextStyle(fontSize: 14)),
                ),
                ButtonSegment(
                  value: 'Acheter',
                  label: Text('Acheter', style: TextStyle(fontSize: 14)),
                ),
              ],
              selected: <String>{_needType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _needType = newSelection.first;
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text("Emplacement", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _villeController,
              decoration: const InputDecoration(
                labelText: 'Ville ,commune , quartier ..',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 15),
            const Text("Type de propriété", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                FilterChip(
                  selectedColor: primaryColor,
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  label: Text(
                    'Tous',
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          _propertyType == 'Tous' ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: _propertyType == 'Tous',
                  onSelected: (bool selected) {
                    setState(() {
                      _propertyType = 'Tous';
                      _hasChanges = true;
                    });
                  },
                ),
                FilterChip(
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  label: Text(
                    'Villa',
                    style: TextStyle(
                      fontSize: 15,
                      color: _propertyType == 'Villa'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: _propertyType == 'Villa',
                  onSelected: (bool selected) {
                    setState(() {
                      _propertyType = 'Villa';
                    });
                  },
                ),
                FilterChip(
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  label: Text(
                    'Maison',
                    style: TextStyle(
                      fontSize: 15,
                      color: _propertyType == 'Maison'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: _propertyType == 'Maison',
                  onSelected: (bool selected) {
                    setState(() {
                      _propertyType = 'Maison';
                    });
                  },
                ),
                FilterChip(
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  label: Text(
                    'Appartement',
                    style: TextStyle(
                      fontSize: 15,
                      color: _propertyType == 'Appartement'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: _propertyType == 'Appartement',
                  onSelected: (bool selected) {
                    setState(() {
                      _propertyType = 'Appartement';
                    });
                  },
                ),
                FilterChip(
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  label: Text(
                    'Studio',
                    style: TextStyle(
                      fontSize: 15,
                      color: _propertyType == 'Studio'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: _propertyType == 'Studio',
                  onSelected: (bool selected) {
                    setState(() {
                      _propertyType = 'Studio';
                    });
                  },
                ),
                FilterChip(
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  label: Text(
                    'Hôtel',
                    style: TextStyle(
                      fontSize: 15,
                      color: _propertyType == 'Hôtel'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: _propertyType == 'Hôtel',
                  onSelected: (bool selected) {
                    setState(() {
                      _propertyType = 'Hôtel';
                    });
                  },
                ),
                FilterChip(
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  label: Text(
                    'Terrain',
                    style: TextStyle(
                      fontSize: 15,
                      color: _propertyType == 'Terrain'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: _propertyType == 'Terrain',
                  onSelected: (bool selected) {
                    setState(() {
                      _propertyType = 'Terrain';
                    });
                  },
                ),
                FilterChip(
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  label: Text(
                    'Commerce',
                    style: TextStyle(
                      fontSize: 15,
                      color: _propertyType == 'commerce'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: _propertyType == 'commerce',
                  onSelected: (bool selected) {
                    setState(() {
                      _propertyType = 'commerce';
                    });
                  },
                ),
                FilterChip(
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.white,
                  label: Text(
                    'Bureau',
                    style: TextStyle(
                      fontSize: 15,
                      color: _propertyType == 'Bureau'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: _propertyType == 'Bureau',
                  onSelected: (bool selected) {
                    setState(() {
                      _propertyType = 'Bureau';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Plage de prix", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Colors.black54,
                    controller: _minPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix minimal',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0), // Réduit le padding
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    cursorColor: Colors.black54,
                    controller: _maxPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix maximal',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0), // Réduit le padding
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Nombre de chambres", style: TextStyle(fontSize: 18)),
            Row(
              children: [
                const Text("Chambres", style: TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(() {
                    _bedrooms = _bedrooms > 0
                        ? _bedrooms - 1
                        : 0; // Empêche d'aller en dessous de 0
                  }),
                ),
                Text(_bedrooms.toString(),
                    style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() {
                    _bedrooms++; // Incrémente la valeur
                  }),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                  child: const Text(
                    'Réinitialiser tout',
                    style: TextStyle(fontSize: 18, color: primaryColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: _onApplyFilter,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white),
                  child:
                      const Text('Appliquer', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
