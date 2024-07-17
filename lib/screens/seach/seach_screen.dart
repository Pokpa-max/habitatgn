import 'package:flutter/material.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/seach/seach_result.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';

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
  String _selectedPartNumber = 'Nombre de piece';

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

  List<Map<String, List<String>>> communes = [
    // 'Conakry'= [
    //   { label: 'Kaloum', value: 'Kaloum' },
    //   { label: 'Dixinn', value: 'Dixinn' },
    //   { label: 'Matam', value: 'Matam' },
    //   { label: 'Ratoma', value: 'Ratoma' },
    //   { label: 'Matoto', value: 'Matoto' }
    // ],
    // Kankan: [
    //   { label: 'Kankan Centre', value: 'Kankan Centre' },
    //   { label: 'Banankoro', value: 'Banankoro' },
    //   { label: 'Karifamoriah', value: 'Karifamoriah' }
    // ],
    // Kindia: [
    //   { label: 'Kindia Centre', value: 'Kindia Centre' },
    //   { label: 'Friguiagbé', value: 'Friguiagbé' },
    //   { label: 'Mambia', value: 'Mambia' }
    // ],
    // Labe: [
    //   { label: 'Labé Centre', value: 'Labé Centre' },
    //   { label: 'Daka', value: 'Daka' },
    //   { label: 'Pita', value: 'Pita' }
    // ],
    // Mamou: [
    //   { label: 'Mamou Centre', value: 'Mamou Centre' },
    //   { label: 'Sérédou', value: 'Sérédou' },
    //   { label: 'Koumbia', value: 'Koumbia' }
    // ],
    // Nzerekore: [
    //   { label: 'Nzérékoré Centre', value: 'Nzérékoré Centre' },
    //   { label: 'Sérédou', value: 'Sérédou' },
    //   { label: 'Yalenzou', value: 'Yalenzou' }
    // ],
    // Boke: [
    //   { label: 'Boké Centre', value: 'Boké Centre' },
    //   { label: 'Kamsar', value: 'Kamsar' },
    //   { label: 'Sangaredi', value: 'Sangaredi' }
    // ],
    // Faranah: [
    //   { label: 'Faranah Centre', value: 'Faranah Centre' },
    //   { label: 'Tiro', value: 'Tiro' },
    //   { label: 'Banian', value: 'Banian' }
    // ],
    // Kamsar: [
    //   { label: 'Kamsar Centre', value: 'Kamsar Centre' },
    //   { label: 'Kolaboui', value: 'Kolaboui' },
    //   { label: 'Bintimodia', value: 'Bintimodia' }
    // ],
    // Siguiri: [
    //   { label: 'Siguiri Centre', value: 'Siguiri Centre' },
    //   { label: 'Kintinian', value: 'Kintinian' },
    //   { label: 'Niandankoro', value: 'Niandankoro' }
    // ]
  ];

  List<House> _searchResults = [];

  void _performSearch() {
    // Simulation de résultats de recherche
    List<House> results = [];

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: AppBar(
        backgroundColor: primary,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: CustomTitle(
          textColor: Colors.white,
          text: _searchResults.isNotEmpty
              ? 'Résultats de la recherche'
              : "Où souhaitez-vous poser vos valises ?",
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: _searchResults.isNotEmpty
          ? seachResult(results: _searchResults)
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                padding: const EdgeInsets.only(
                    bottom: 80.0), // Ajout de padding en bas
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildToggleButtons(context),
                      const SizedBox(height: 10),
                      _buildDropdown(
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
                      _buildTextField('Nombre de pièces', _selectedPartNumber,
                          (value) {
                        setState(() {
                          _selectedPartNumber = value;
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
      floatingActionButton: _searchResults.isEmpty
          ? FloatingActionButton.extended(
              // isExtended: false,
              onPressed: _performSearch,
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              label: const Text(
                'Soumettre',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.cyan,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDropdown(List<String> options, String selectedValue,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          borderRadius: BorderRadius.circular(15),
          iconSize: 30,
          iconEnabledColor: primary,
          value: selectedValue,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white),
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
        const SizedBox(height: 8),
        TextFormField(
          cursorColor: primary,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white),
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
        _buildChoiceChip(context, 'BIEN EN VENTE', isVenteSelected, () {
          setState(() {
            isVenteSelected = true;
          });
        }),
        const SizedBox(width: 30),
        _buildChoiceChip(context, 'BIEN EN LOCATION', !isVenteSelected, () {
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
      padding: const EdgeInsets.all(10),
      visualDensity: VisualDensity.standard,
      checkmarkColor: Colors.white,
      label: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
      selected: selected,
      onSelected: (bool value) => onSelected(),
      selectedColor: primary,
      backgroundColor: lightPrimary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.cyan,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: primary),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
