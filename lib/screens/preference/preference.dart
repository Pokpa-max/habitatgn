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
            'Tous',
          ];

          bool isAnyPreferenceSelected = housingTypes
              .where((type) => type != 'Tous')
              .any((type) => preferences[type] == true);

          bool isNotificationsEnabled =
              preferences['notificationsEnabled'] ?? false;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text(
                      "Activer les notifications pour vos préférences de logement"),
                  value: isAnyPreferenceSelected && isNotificationsEnabled,
                  activeColor: primaryColor,
                  onChanged: (bool value) {
                    if (isAnyPreferenceSelected) {
                      ref.read(updatePreferenceProvider({
                        'userId': userId,
                        'type': 'notificationsEnabled',
                        'value': value,
                      }));
                    } else {
                      _showNoSelectionDialog(context);
                    }
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
                                if (type == 'Tous') {
                                  // Gestion de la case 'Tous'
                                  bool newValue = value;
                                  // Coche ou décoche toutes les autres préférences
                                  for (var housingType in housingTypes) {
                                    if (housingType != 'Tous') {
                                      ref.read(updatePreferenceProvider({
                                        'userId': userId,
                                        'type': housingType,
                                        'value': newValue,
                                      }));
                                    }
                                  }
                                  // Active ou désactive les notifications
                                  ref.read(updatePreferenceProvider({
                                    'userId': userId,
                                    'type': 'notificationsEnabled',
                                    'value': newValue,
                                  }));
                                } else {
                                  // Mise à jour d'une préférence spécifique
                                  ref.read(updatePreferenceProvider({
                                    'userId': userId,
                                    'type': type,
                                    'value': value,
                                  }));
                                }
                                // Mise à jour de la case 'Tous'
                                bool allSelectedExceptAll = housingTypes
                                    .where((type) => type != 'Tous')
                                    .every(
                                        (type) => preferences[type] ?? false);

                                ref.read(updatePreferenceProvider({
                                  'userId': userId,
                                  'type': 'Tous',
                                  'value': allSelectedExceptAll,
                                }));

                                // Mise à jour des notifications en fonction de la sélection
                                bool anySelected = housingTypes
                                    .where((type) => type != 'Tous')
                                    .any((type) => preferences[type] ?? false);

                                ref.read(updatePreferenceProvider({
                                  'userId': userId,
                                  'type': 'notificationsEnabled',
                                  'value': anySelected,
                                }));

                                // Actualiser les préférences
                                ref.refresh(userPreferencesProvider(userId));
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
        loading: () =>
            const Center(child: CircularProgressIndicator(color: primaryColor)),
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
              'Veuillez sélectionner au moins un type de logement pour activer les notifications.',
              style: TextStyle(fontSize: 16)),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok !', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
