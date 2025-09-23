import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/viewmodels/preference/preference.dart';

class HousingPreferencesScreen extends ConsumerWidget {
  final String userId;

  const HousingPreferencesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsyncValue = ref.watch(userPreferencesProvider(userId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          color: Colors.grey[700],
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Préférences de Logement',
          style: GoogleFonts.poppins(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: preferencesAsyncValue.when(
        data: (preferences) =>
            _buildPreferencesContent(context, ref, preferences),
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Chargement des préférences...',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesContent(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> preferences,
  ) {
    final housingTypes = [
      {'key': 'Villa', 'icon': Icons.villa_outlined, 'label': 'Villa'},
      {'key': 'Maison', 'icon': Icons.home_outlined, 'label': 'Maison'},
      {'key': 'Studio', 'icon': Icons.apartment_outlined, 'label': 'Studio'},
      {'key': 'Hôtel', 'icon': Icons.hotel_outlined, 'label': 'Hôtel'},
      {'key': 'Magasin', 'icon': Icons.store_outlined, 'label': 'Magasin'},
      {'key': 'Terrain', 'icon': Icons.landscape_outlined, 'label': 'Terrain'},
      {'key': 'Duplex', 'icon': Icons.domain_outlined, 'label': 'Duplex'},
      {
        'key': 'Appartement',
        'icon': Icons.apartment_outlined,
        'label': 'Appartement'
      },
      {
        'key': 'Chantier',
        'icon': Icons.construction_outlined,
        'label': 'Chantier'
      },
    ];

    bool isAnyPreferenceSelected =
        housingTypes.any((type) => preferences[type['key']] == true);

    bool isNotificationsEnabled = preferences['notificationsEnabled'] ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête informatif
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: primaryColor,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Personnalisez vos notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sélectionnez les types de logements qui vous intéressent pour recevoir des notifications personnalisées.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section Notifications
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Switch(
                      value: isAnyPreferenceSelected && isNotificationsEnabled,
                      activeColor: primaryColor,
                      onChanged: (bool value) {
                        if (isAnyPreferenceSelected) {
                          _updatePreference(ref, 'notificationsEnabled', value);
                        } else {
                          _showNoSelectionDialog(context);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isAnyPreferenceSelected
                      ? 'Recevez des notifications pour vos types de logements sélectionnés'
                      : 'Sélectionnez au moins un type de logement pour activer les notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isAnyPreferenceSelected
                        ? Colors.grey[600]
                        : Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section Actions rapides
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actions rapides',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.select_all_outlined,
                        label: 'Tout sélectionner',
                        onPressed: () => _selectAll(ref, housingTypes, true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.deselect_outlined,
                        label: 'Tout désélectionner',
                        onPressed: () => _selectAll(ref, housingTypes, false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section Types de logements
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Types de logements',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choisissez les types qui vous intéressent',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ...housingTypes.map((type) => _buildHousingTypeItem(
                      context,
                      ref,
                      preferences,
                      type['key'] as String,
                      type['icon'] as IconData,
                      type['label'] as String,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHousingTypeItem(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> preferences,
    String type,
    IconData icon,
    String label,
  ) {
    bool isSelected = preferences[type] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? primaryColor.withOpacity(0.3) : Colors.grey[300]!,
        ),
        color: isSelected ? primaryColor.withOpacity(0.05) : Colors.grey[50],
      ),
      child: InkWell(
        onTap: () => _updatePreference(ref, type, !isSelected),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? primaryColor : Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.grey[800] : Colors.grey[600],
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? primaryColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updatePreference(WidgetRef ref, String type, bool value) {
    ref.read(updatePreferenceProvider({
      'userId': userId,
      'type': type,
      'value': value,
    }));

    // Actualiser les préférences
    ref.refresh(userPreferencesProvider(userId));
  }

  void _selectAll(
      WidgetRef ref, List<Map<String, dynamic>> housingTypes, bool value) {
    // Mettre à jour tous les types de logements
    for (var type in housingTypes) {
      _updatePreference(ref, type['key'] as String, value);
    }

    // Mettre à jour les notifications
    _updatePreference(ref, 'notificationsEnabled', value);
  }

  void _showNoSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_outlined,
                  color: Colors.orange[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Aucune sélection',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          content: Text(
            'Veuillez sélectionner au moins un type de logement pour activer les notifications.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Compris',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
