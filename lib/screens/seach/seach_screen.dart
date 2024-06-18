import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isVenteSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OU VOULEZ VOUS HABITER ?',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.cyan,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              // color: Colors.cyan,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: _buildToggleButtons(context),
            ),
            const SizedBox(height: 20),
            _buildOption(context, 'TYPE DE BIEN', Icons.home),
            _buildOption(context, 'SELECTIONNEZ LA COMMUNE', Icons.location_on),
            _buildOption(
                context, 'SELECTIONNEZ LE QUARTIER', Icons.location_on),
            _buildOption(context, 'PIECES', Icons.meeting_room),
            _buildOption(context, 'BUDGET GNF', Icons.money),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Action à effectuer lors de l'appui sur le bouton de recherche
              },
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text('Rechercher',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
      label: Text(text),
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
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.cyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          title: Text(text),
          trailing: Icon(icon, color: Colors.cyan),
        ),
      ),
    );
  }
}
