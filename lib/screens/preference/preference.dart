import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/viewmodels/preference/preference.dart';

class HousingPreferencesScreen extends ConsumerWidget {
  final String userId;

  const HousingPreferencesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsyncValue = ref.watch(userPreferencesProvider(userId));

    return Scaffold(
      backgroundColor: lightPrimary2,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Préférences de Logement',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      body: preferencesAsyncValue.when(
        data: (preferences) {
          final housingTypes = [
            'Villa',
            'Maison',
            'Studio',
            'Hôtel',
            'Magasin',
            'Terrain',
            'Duplex',
            'Appartement',
            'Chantier',
          ];

          // Vérifiez si aucune préférence n'est sélectionnée
          bool isAnyPreferenceSelected =
              housingTypes.any((type) => preferences[type] == true);

          if (!isAnyPreferenceSelected) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showNoSelectionDialog(context);
            });
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Sélectionnez vos préférences de logement pour recevoir des notifications.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Switch for notification permission
                SwitchListTile(
                  title: const Text(
                      "Autoriser l'envoi de notifications concernant vos préférences de logement"),
                  value: preferences['notificationsEnabled'] ?? false,
                  activeColor: primaryColor,
                  onChanged: (bool value) {
                    ref.read(updatePreferenceProvider({
                      'userId': userId,
                      'type': 'notificationsEnabled',
                      'value': value,
                    }));
                    // Recharger les préférences après mise à jour
                    ref.refresh(userPreferencesProvider(userId));
                  },
                ),

                const SizedBox(height: 20.0),

                Expanded(
                  child: ListView(
                    children: housingTypes.map((type) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        color: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: lightPrimary,
                              width: 1.0,
                            ),
                          ),
                          child: CheckboxListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            activeColor: primaryColor,
                            title: Text(
                              type,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            value: preferences[type] ?? false,
                            onChanged: (bool? value) {
                              if (value != null) {
                                ref.read(updatePreferenceProvider({
                                  'userId': userId,
                                  'type': type,
                                  'value': value,
                                }));
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  void _showNoSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aucune Sélection'),
          content: const Text(
              'Veuillez sélectionner au moins un type de logement et activer la notification pour recevoir des notifications.'),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.all(8.0),
                  ),
                  backgroundColor: WidgetStateProperty.all(primaryColor),
                  foregroundColor: WidgetStateProperty.all(Colors.white)),
              onPressed: () async {
                Navigator.pop(context);
              },
              child: const Text('Ok !'),
            ),
          ],
        );
      },
    );
  }
}
