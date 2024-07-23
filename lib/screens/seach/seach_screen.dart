import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:habitatgn/screens/seach/seach_result.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/search/search.dart';

// class SearchPage extends ConsumerStatefulWidget {
//   const SearchPage({super.key});

//   @override
//   _SearchPageState createState() => _SearchPageState();
// }

// class _SearchPageState extends ConsumerState<SearchPage> {
//   final _formKey = GlobalKey<FormState>();
//   String _selectedType = 'Villa';
//   String _selectedLocation = 'Conakry';
//   String? _selectedCommune;
//   String _selectedQuartier = '';
//   String _selectedPartNumber = '';

//   final TextEditingController _minPriceController = TextEditingController();
//   final TextEditingController _maxPriceController = TextEditingController();
//   bool isVenteSelected = true;

//   final List<String> _types = [
//     'Villa',
//     'Maison',
//     'Studio',
//     'Hôtel',
//     'Magasin',
//     'Terrain'
//   ];
//   final List<String> _locations = [
//     'Conakry',
//     'Kindia',
//     'Labé',
//     'Mamou',
//     'Kankan',
//     'Siguiri',
//     'Boké',
//     'Faranah',
//     'Kamsar',
//     'Nzérékoré'
//   ];

//   final Map<String, List<String>> _communes = {
//     'Conakry': [
//       'Kaloum',
//       'Dixinn',
//       'Matam',
//       'Ratoma',
//       'Matoto',
//       'Kassa',
//       'Gbessia',
//       'Tombolia',
//       'Lambanyi',
//       'Sonfonia',
//       'Kagbélén',
//       'Sanoyah',
//       'Maneah'
//     ],
//     'Kindia': ['Commune Urbaine', 'Gomni', 'Kankalaba'],
//     // Ajoutez les communes pour les autres villes ici
//   };

//   List<String> _getCommunesForLocation(String location) {
//     return _communes[location] ?? [];
//   }

//   void _performSearch() {
//     if (_formKey.currentState!.validate()) {
//       // Rechercher les logements
//       print("recherche dun logement⛪⛪⛪⛪⛪⛪ ");
//       print(_selectedType);
//       ref.watch(searchProvider.notifier).searchHouses(
//             type: _selectedType,
//             location: _selectedLocation,
//             commune: _selectedCommune!,
//             quartier: _selectedQuartier,
//             partNumber: _selectedPartNumber,
//             minPrice: int.tryParse(_minPriceController.text) ?? 0,
//             maxPrice: int.tryParse(_maxPriceController.text) ?? 0,
//             isVente: isVenteSelected,
//             isNewSearch: true,
//           );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final seachProvider = ref.watch(searchProvider);
//     return Scaffold(
//       backgroundColor: lightPrimary,
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_outlined,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: CustomTitle(
//             textColor: Colors.white,
//             text: seachProvider.houses.isEmpty
//                 ? "Où souhaitez-vous poser vos valises ?"
//                 : 'Résultats de la recherche (${seachProvider.houses.length})'),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: seachProvider.houses.isNotEmpty
//           ? const SearchResultPage()
//           : Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Form(
//                 key: _formKey,
//                 child: ListView(
//                   padding: const EdgeInsets.only(bottom: 80.0),
//                   children: [
//                     _buildToggleButtons(context),
//                     const SizedBox(height: 20),
//                     _buildSectionTitle('TYPE DE LOGEMENT'),
//                     _buildDropdown(
//                       _types,
//                       _selectedType,
//                       (value) {
//                         setState(() {
//                           _selectedType = value!;
//                         });
//                       },
//                       'Veuillez sélectionner un type',
//                     ),
//                     const SizedBox(height: 20),
//                     _buildSectionTitle('VILLE'),
//                     _buildDropdown(
//                       _locations,
//                       _selectedLocation,
//                       (value) {
//                         setState(() {
//                           _selectedLocation = value!;
//                           _selectedCommune = null;
//                           _selectedQuartier = '';
//                         });
//                       },
//                       'Veuillez sélectionner une ville',
//                     ),
//                     const SizedBox(height: 20),
//                     if (_getCommunesForLocation(_selectedLocation)
//                         .isNotEmpty) ...[
//                       _buildSectionTitle('COMMUNE'),
//                       _buildDropdown(
//                         _getCommunesForLocation(_selectedLocation),
//                         _selectedCommune ?? '',
//                         (value) {
//                           setState(() {
//                             _selectedCommune = value!;
//                           });
//                         },
//                         'Veuillez sélectionner une commune',
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                     _buildSectionTitle('QUARTIER'),
//                     _buildTextField(
//                       'Quartier',
//                       _selectedQuartier,
//                       (value) {
//                         setState(() {
//                           _selectedQuartier = value;
//                         });
//                       },
//                       'Veuillez entrer un quartier',
//                     ),
//                     const SizedBox(height: 20),
//                     _buildSectionTitle('NOMBRE DE PIÈCES'),
//                     _buildTextFieldBedroom(
//                       'Nombre de pièces',
//                       _selectedPartNumber,
//                       (value) {
//                         setState(() {
//                           _selectedPartNumber = value;
//                         });
//                       },
//                       'Veuillez entrer le nombre de pièces',
//                     ),
//                     const SizedBox(height: 20),
//                     _buildSectionTitle('BUDGET'),
//                     _buildPriceRangeInputs(),
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _performSearch,
//         icon: const Icon(
//           Icons.search,
//           color: Colors.white,
//         ),
//         label: const Text(
//           'Soumettre',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: primaryColor,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//     );
//   }

//   Widget _buildDropdown(List<String> options, String selectedValue,
//       ValueChanged<String?> onChanged, String validatorMessage) {
//     return DropdownButtonFormField<String>(
//       borderRadius: BorderRadius.circular(10),
//       iconSize: 30,
//       iconEnabledColor: primaryColor,
//       value: selectedValue.isEmpty ? null : selectedValue,
//       items: options.map((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       }).toList(),
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: inputBackground,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: inputBackground),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: inputBackground),
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return validatorMessage;
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildTextField(String label, String value,
//       ValueChanged<String> onChanged, String validatorMessage) {
//     return TextFormField(
//       cursorColor: primaryColor,
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         filled: true,
//         fillColor: inputBackground,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: inputBackground),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: inputBackground),
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return validatorMessage;
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildTextFieldBedroom(String label, String value,
//       ValueChanged<String> onChanged, String validatorMessage) {
//     return TextFormField(
//       cursorColor: primaryColor,
//       keyboardType: TextInputType.number,
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         filled: true,
//         fillColor: inputBackground,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: inputBackground),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: inputBackground),
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return validatorMessage;
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildToggleButtons(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildChoiceChip(context, 'ACHETER', isVenteSelected, () {
//           setState(() {
//             isVenteSelected = true;
//           });
//         }),
//         const SizedBox(width: 30),
//         _buildChoiceChip(context, 'LOUER', !isVenteSelected, () {
//           setState(() {
//             isVenteSelected = false;
//           });
//         }),
//       ],
//     );
//   }

//   Widget _buildChoiceChip(BuildContext context, String text, bool selected,
//       VoidCallback onSelected) {
//     return ChoiceChip(
//       padding: const EdgeInsets.all(10),
//       visualDensity: VisualDensity.standard,
//       checkmarkColor: Colors.white,
//       label: Text(
//         text,
//         style: const TextStyle(fontSize: 14),
//       ),
//       selected: selected,
//       onSelected: (bool value) => onSelected(),
//       selectedColor: primaryColor,
//       backgroundColor: lightPrimary,
//       labelStyle: TextStyle(
//         color: selected ? Colors.white : primaryColor,
//         fontWeight: FontWeight.bold,
//       ),
//       shape: RoundedRectangleBorder(
//         side: const BorderSide(color: primaryColor),
//         borderRadius: BorderRadius.circular(10),
//       ),
//     );
//   }

//   Widget _buildPriceRangeInputs() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextFormField(
//             controller: _minPriceController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               labelText: 'Min GN',
//               fillColor: inputBackground,
//               filled: true,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Veuillez entrer un prix minimum';
//               }
//               return null;
//             },
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: TextFormField(
//             controller: _maxPriceController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               labelText: 'Max GN',
//               fillColor: inputBackground,
//               filled: true,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Veuillez entrer un prix maximum';
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Villa';
  String _selectedLocation = 'Conakry';
  String? _selectedCommune;
  String _selectedQuartier = '';
  String _selectedPartNumber = '';

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  bool isVenteSelected = true;

  final List<String> _types = [
    'Villa',
    'Maison',
    'Studio',
    'Hôtel',
    'Magasin',
    'Terrain'
  ];
  final List<String> _locations = [
    'Conakry',
    'Kindia',
    'Labé',
    'Mamou',
    'Kankan',
    'Siguiri',
    'Boké',
    'Faranah',
    'Kamsar',
    'Nzérékoré'
  ];

  final Map<String, List<String>> _communes = {
    'Conakry': [
      'Kaloum',
      'Dixinn',
      'Matam',
      'Ratoma',
      'Matoto',
      'Kassa',
      'Gbessia',
      'Tombolia',
      'Lambanyi',
      'Sonfonia',
      'Kagbélén',
      'Sanoyah',
      'Maneah'
    ],
    'Kindia': ['Commune Urbaine', 'Gomni', 'Kankalaba'],
    // Ajoutez les communes pour les autres villes ici
  };

  List<String> _getCommunesForLocation(String location) {
    return _communes[location] ?? [];
  }

  Future<void> _performSearch() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(searchProvider.notifier).searchHouses(
            type: _selectedType,
            location: _selectedLocation,
            commune: _selectedCommune!,
            quartier: _selectedQuartier,
            partNumber: _selectedPartNumber,
            minPrice: int.tryParse(_minPriceController.text) ?? 0,
            maxPrice: int.tryParse(_maxPriceController.text) ?? 0,
            isVente: isVenteSelected,
            isNewSearch: true,
          );
      // Navigate to the results page after search is complete
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchResultPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const CustomTitle(
          textColor: Colors.white,
          text: "Où souhaitez-vous poser vos valises ?",
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 80.0),
            children: [
              _buildToggleButtons(context),
              const SizedBox(height: 20),
              _buildSectionTitle('TYPE DE LOGEMENT'),
              _buildDropdown(
                _types,
                _selectedType,
                (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                'Veuillez sélectionner un type',
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('VILLE'),
              _buildDropdown(
                _locations,
                _selectedLocation,
                (value) {
                  setState(() {
                    _selectedLocation = value!;
                    _selectedCommune = null;
                    _selectedQuartier = '';
                  });
                },
                'Veuillez sélectionner une ville',
              ),
              const SizedBox(height: 20),
              if (_getCommunesForLocation(_selectedLocation).isNotEmpty) ...[
                _buildSectionTitle('COMMUNE'),
                _buildDropdown(
                  _getCommunesForLocation(_selectedLocation),
                  _selectedCommune ?? '',
                  (value) {
                    setState(() {
                      _selectedCommune = value!;
                    });
                  },
                  'Veuillez sélectionner une commune',
                ),
                const SizedBox(height: 20),
              ],
              _buildSectionTitle('QUARTIER'),
              _buildTextField(
                'Quartier',
                _selectedQuartier,
                (value) {
                  setState(() {
                    _selectedQuartier = value;
                  });
                },
                'Veuillez entrer un quartier',
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('NOMBRE DE PIÈCES'),
              _buildTextFieldBedroom(
                'Nombre de pièces',
                _selectedPartNumber,
                (value) {
                  setState(() {
                    _selectedPartNumber = value;
                  });
                },
                'Veuillez entrer le nombre de pièces',
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('BUDGET'),
              _buildPriceRangeInputs(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: searchState.isLoading ? null : _performSearch,
        icon: searchState.isLoading
            ? const SpinKitFadingCircle(
                color: Colors.white,
                size: 40.0,
              )
            : const Icon(
                Icons.search,
                color: Colors.white,
              ),
        label: const Text(
          'Soumettre',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDropdown(List<String> options, String selectedValue,
      ValueChanged<String?> onChanged, String validatorMessage) {
    return DropdownButtonFormField<String>(
      borderRadius: BorderRadius.circular(10),
      iconSize: 30,
      iconEnabledColor: primaryColor,
      value: selectedValue.isEmpty ? null : selectedValue,
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: inputBackground),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: inputBackground),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        return null;
      },
    );
  }

  Widget _buildTextField(String label, String value,
      ValueChanged<String> onChanged, String validatorMessage) {
    return TextFormField(
      cursorColor: primaryColor,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: inputBackground),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: inputBackground),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        return null;
      },
    );
  }

  Widget _buildTextFieldBedroom(String label, String value,
      ValueChanged<String> onChanged, String validatorMessage) {
    return TextFormField(
      cursorColor: primaryColor,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: inputBackground),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: inputBackground),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        return null;
      },
    );
  }

  Widget _buildToggleButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChoiceChip(context, 'ACHETER', isVenteSelected, () {
          setState(() {
            isVenteSelected = true;
          });
        }),
        const SizedBox(width: 30),
        _buildChoiceChip(context, 'LOUER', !isVenteSelected, () {
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
      selectedColor: primaryColor,
      backgroundColor: lightPrimary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : primaryColor,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildPriceRangeInputs() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Min GN',
              fillColor: inputBackground,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un prix minimum';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Max GN',
              fillColor: inputBackground,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un prix maximum';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
