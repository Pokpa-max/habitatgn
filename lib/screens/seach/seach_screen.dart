import 'package:flutter/material.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/seach/seach_result.dart';
import 'package:habitatgn/utils/appColors.dart';
import 'package:habitatgn/utils/ui_element.dart'; // Assurez-vous d'importer le fichier de couleurs

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _selectedType = 'Tous';
  String _selectedLocation = 'Partout';
  String _selectedCommune = 'Commune';
  String _selectedQuartier = 'Quartier';

  RangeValues _selectedPriceRange = const RangeValues(500, 5000);
  bool isVenteSelected = true;

  final List<String> _types = [
    'Tous',
    'Villa',
    'Maison',
    'Studio',
    'Hôtel',
    'Magasin',
    'Terrain'
  ];
  final List<String> _locations = [
    'Partout',
    'Paris',
    'Lyon',
    'Marseille',
    'Toulouse',
    'Nice'
  ];

  List<House> _searchResults = [];

  void _performSearch() {
    // Simulation de résultats de recherche
    List<House> results = [
      House(
          type: 'Villa',
          location: 'Paris',
          commune: 'Commune1',
          quartier: 'Quartier1',
          price: 3000,
          imageUrl: 'assets/images/maison.jpg',
          numRooms: 3),
      House(
          type: 'Maison',
          location: 'Lyon',
          commune: 'Commune2',
          quartier: 'Quartier2',
          price: 2500,
          numRooms: 2,
          imageUrl: 'assets/images/maison.jpg'),
    ];

    setState(() {
      _searchResults = results;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultPage(results: _searchResults),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: primary),
        title: const CustomTitle(text: "Où souhaitez-vous poser vos valises ?"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildToggleButtons(context),
                const SizedBox(height: 10),
                _buildDropdown(
                  'Type de bien',
                  _types,
                  _selectedType,
                  (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildDropdown(
                  'Localisation',
                  _locations,
                  _selectedLocation,
                  (value) {
                    setState(() {
                      _selectedLocation = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField('Commune', _selectedCommune, (value) {
                  setState(() {
                    _selectedCommune = value;
                  });
                }),
                const SizedBox(height: 10),
                _buildTextField('Quartier', _selectedQuartier, (value) {
                  setState(() {
                    _selectedQuartier = value;
                  });
                }),
                const SizedBox(height: 10),
                _buildTextField('Nombre de pièces', _selectedQuartier, (value) {
                  setState(() {
                    _selectedQuartier = value;
                  });
                }),
                const SizedBox(height: 10),
                _buildPriceRange(),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _performSearch,
        label: const Text('Rechercher', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.search, color: Colors.white),
        backgroundColor: primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDropdown(String label, List<String> options,
      String selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, String value, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prix',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _selectedPriceRange,
          min: 0,
          max: 10000,
          divisions: 100,
          labels: RangeLabels(
            _selectedPriceRange.start.round().toString(),
            _selectedPriceRange.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _selectedPriceRange = values;
            });
          },
          activeColor: primary,
          inactiveColor: primary.withOpacity(0.3),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_selectedPriceRange.start.round()} GN'),
            Text('${_selectedPriceRange.end.round()} GN'),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChoiceChip(context, 'VENTE', isVenteSelected, () {
          setState(() {
            isVenteSelected = true;
          });
        }),
        const SizedBox(width: 10),
        _buildChoiceChip(context, 'LOCATION', !isVenteSelected, () {
          setState(() {
            isVenteSelected = false;
          });
        }),
      ],
    );
  }

  Widget _buildChoiceChip(BuildContext context, String text, bool selected,
      VoidCallback onSelected) {
    return ChoiceChip(
      checkmarkColor: Colors.white,
      label: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
      selected: selected,
      onSelected: (bool value) => onSelected(),
      selectedColor: Colors.cyan,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.cyan,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
