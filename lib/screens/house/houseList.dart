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
          insetPadding: const EdgeInsets.symmetric(
              horizontal: 16.0), // Ajuste la largeur du modal
          child: FractionallySizedBox(
            heightFactor: 0.6, // Ajuste la hauteur du modal
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
    print('voir le filtre🤬🤬🤬🤬🤬');

    print(!_isFilterApplied);

    // afficher tous les

    final houseListViewModel = ref.watch(dashbordViewModelProvider);

    final filteredHouses = houseListViewModel.houses.where((house) {
      final lowerCaseQuery = _searchQuery.trim().toLowerCase();
      final lowerCaseVille = _ville.toLowerCase();

      final lowcaseofferType = _needType == "Acheter"
          ? "AVendre".trim().toLowerCase()
          : " ALouer".trim().toLowerCase();

      // Vérification de la requête de recherche
      bool matchesQuery = house.houseType!.label
              .toLowerCase()
              .contains(lowerCaseQuery) ||
          house.description.toLowerCase().contains(lowerCaseQuery) ||
          house.address?.town["label"].toLowerCase().contains(lowerCaseQuery);

      // Vérification des filtres appliqués

      print("verificaion des filtre s⛪⛪⛪⛪⛪⛪");
      print(_hasChanges);
      bool matchesFilter = (!_isFilterApplied && !_hasChanges ||
          (house.price >= _minPrice &&
              house.price <= _maxPrice &&
              (_needType == 'Tous' ||
                  house.offerType["value"].trim().toLowerCase() ==
                      lowcaseofferType) && // Adapté pour le besoin
              (_propertyType == 'Tous' ||
                  house.houseType?.label.trim().toLowerCase() ==
                      _propertyType
                          .trim()
                          .toLowerCase()) && // Adapté pour le type de propriété

              (house.address?.town["label"]
                  .toLowerCase()
                  .contains(lowerCaseVille)) &&
              (house.bedrooms == _bedrooms))); // Filtrage par ville

      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: AppBar(
        toolbarHeight: 120,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: _buildSearchBar(),
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
                          borderRadius: BorderRadius.circular(30),
                          selectedColor: Colors.white,
                          fillColor: primaryColor,
                          color: primaryColor,
                          borderColor: primaryColor,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text("Toutes les annonces",
                                  style: TextStyle(fontSize: 16)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text("Appliquer le Filtre",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.restore_outlined,
                          color: primaryColor),
                      onPressed: () {
                        setState(() {
                          _isFilterApplied = false;
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
                                        builder: (context) => HousingDetailPage(
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
                                          width: screenWidth * 0.40,
                                          height: screenHeight * 0.15,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
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
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  ' ${house.address!.town["label"]} / ${house.address!.commune["label"]}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey[700]),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.home,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${house.bedrooms} pièces',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey[700]),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.attach_money_outlined,
                                                    color: Colors.grey),
                                                FormattedPrice(
                                                  color: Colors.black,
                                                  price: house.price,
                                                  suffix: house.offerType[
                                                              "value"] ==
                                                          "ALouer"
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
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        const CustomTitle(
          text: "Toutes les Annonces de Logements",
          textColor: primaryColor,
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          controller: _searchController,
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.withOpacity(0.2),
            hintText: 'Rechercher ici une maison, un appartement, terrain ...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            // contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16), // Au
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
                  'Filtrer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      if (_hasChanges) {
                        // Optionnel : Confirmer la fermeture si des modifications ont été apportées
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Annuler les modifications?'),
                            content: const Text(
                                'Vous avez des modifications non enregistrées. Voulez-vous vraiment annuler ?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Non'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                  Navigator.of(context).pop(); // Ferme le modal
                                },
                                child: const Text('Oui'),
                              ),
                            ],
                          ),
                        ).then((result) {
                          if (result == true) {
                            Navigator.of(context).pop();
                          }
                        });
                      } else {
                        Navigator.of(context).pop();
                      }
                    }),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "J'ai besoin de",
              style: TextStyle(fontSize: 18),
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
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ButtonSegment(
                  value: 'Louer',
                  label: Text('Louer', style: TextStyle(fontSize: 18)),
                ),
                ButtonSegment(
                  value: 'Acheter',
                  label: Text('Acheter', style: TextStyle(fontSize: 18)),
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
                labelText: 'Ville',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text("Type de propriété", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilterChip(
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  label: Text(
                    'Tous',
                    style: TextStyle(
                      fontSize: 16,
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
                  label: Text(
                    'Villa',
                    style: TextStyle(
                      fontSize: 16,
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
                  label: Text(
                    'Maison',
                    style: TextStyle(
                      fontSize: 16,
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
                  label: Text(
                    'Appartement',
                    style: TextStyle(
                      fontSize: 16,
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
                  label: Text(
                    'Studio',
                    style: TextStyle(
                      fontSize: 16,
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
                  label: Text(
                    'Hôtel',
                    style: TextStyle(
                      fontSize: 16,
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
                  label: Text(
                    'Terrain',
                    style: TextStyle(
                      fontSize: 16,
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
                  label: Text(
                    'Lieux de commerce',
                    style: TextStyle(
                      fontSize: 16,
                      color: _propertyType == 'Lieux de commerce'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  selected: _propertyType == 'Lieux de commerce',
                  onSelected: (bool selected) {
                    setState(() {
                      _propertyType = 'Lieux de commerce';
                    });
                  },
                ),
                FilterChip(
                  selectedColor: primaryColor,
                  checkmarkColor: Colors.white,
                  label: Text(
                    'Bureau',
                    style: TextStyle(
                      fontSize: 16,
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix minimal',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix maximal',
                      border: OutlineInputBorder(),
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
            const SizedBox(height: 16),
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
