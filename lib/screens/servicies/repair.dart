import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitatgn/models/service.dart';
import 'package:habitatgn/services/authService/auth_service.dart';
import 'package:habitatgn/utils/appColors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/repairService/repair_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

enum ServiceType { repair, moving }

class UnifiedServicesScreen extends ConsumerWidget {
  final ServiceType serviceType;

  const UnifiedServicesScreen({
    super.key,
    required this.serviceType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = _getServiceConfig();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          config.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildEmergencyBanner(context, ref, config),
          Expanded(
            child: _buildServicesGrid(context, ref, config),
          ),
        ],
      ),
    );
  }

  ServiceConfig _getServiceConfig() {
    switch (serviceType) {
      case ServiceType.repair:
        return ServiceConfig(
          title: 'Réparations & Entretien',
          emergencyTitle: 'Réparation urgente ?',
          emergencyIcon: Icons.build_circle_outlined,
          phoneType: 'repair',
          gradientColors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
          ],
          services: [
            ServiceItemData(
              icon: Icons.plumbing_outlined,
              title: 'Plomberie',
              description:
                  'Dépannage fuites, installation sanitaire et chauffe-eau',
            ),
            ServiceItemData(
              icon: Icons.electrical_services_outlined,
              title: 'Électricité',
              description:
                  'Installation électrique, réparation et mise aux normes',
            ),
            ServiceItemData(
              icon: Icons.handyman_outlined,
              title: 'Bricolage',
              description: 'Montage meubles, serrurerie et petites réparations',
            ),
            ServiceItemData(
              icon: Icons.format_paint_outlined,
              title: 'Peinture',
              description: 'Rénovation intérieure, décoration et conseils',
            ),
            ServiceItemData(
              icon: Icons.ac_unit_outlined,
              title: 'Climatisation',
              description:
                  'Installation, réparation et entretien de climatiseurs',
            ),
            ServiceItemData(
              icon: Icons.cleaning_services_outlined,
              title: 'Assainissement',
              description: 'Nettoyage professionnel et assainissement 24h/24',
            ),
          ],
        );

      case ServiceType.moving:
        return ServiceConfig(
          title: 'Services de Déménagement',
          emergencyTitle: 'Déménagement urgent ?',
          emergencyIcon: Icons.emergency_rounded,
          phoneType: 'moving',
          gradientColors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
          ],
          services: [
            ServiceItemData(
              icon: Icons.local_shipping_outlined,
              title: 'Transport',
              description:
                  'Transport sécurisé de vos biens avec véhicules adaptés',
            ),
            ServiceItemData(
              icon: Icons.handyman_outlined,
              title: 'Assemblage',
              description: 'Montage et démontage professionnel de vos meubles',
            ),
            ServiceItemData(
              icon: Icons.inventory_2_outlined,
              title: 'Stockage',
              description: 'Solutions de stockage temporaire sécurisées',
            ),
            ServiceItemData(
              icon: Icons.all_inbox_outlined,
              title: 'Emballage',
              description: 'Emballage professionnel et protection optimale',
            ),
          ],
        );
    }
  }

  Widget _buildEmergencyBanner(
      BuildContext context, WidgetRef ref, ServiceConfig config) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: config.gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -5,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
          // Contenu principal
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  config.emergencyIcon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.emergencyTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Intervention rapide disponible 24h/7j',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final phoneNumber = await ref
                        .read(serviceRequestServiceProvider)
                        .getAgentPhoneNumber(config.phoneType);
                    if (phoneNumber != null) {
                      _launchPhoneCall('tel:$phoneNumber');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Numéro non disponible'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone, color: primaryColor, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Appeler',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(
      BuildContext context, WidgetRef ref, ServiceConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nos Services',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez le service dont vous avez besoin',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: config.services.length,
              itemBuilder: (context, index) {
                final service = config.services[index];
                return _buildServiceCard(
                  context: context,
                  service: service,
                  ref: ref,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required ServiceItemData service,
    required WidgetRef ref,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showRequestForm(context, service.title, ref),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  service.icon,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 10),

              // Titre
              Text(
                service.title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Description
              Expanded(
                child: Text(
                  service.description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),

              // Bouton d'action
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Demander',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: primaryColor,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestForm(
      BuildContext context, String serviceType, WidgetRef ref) async {
    await initializeDateFormatting('fr_FR', null);

    final viewModel = ref.watch(serviceRequestServiceProvider);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    Intl.defaultLocale = 'fr_FR';
    final dateFormat = DateFormat.yMMMMd('fr_FR');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête du modal
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          this.serviceType == ServiceType.repair
                              ? Icons.build_outlined
                              : Icons.local_shipping_outlined,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Demande de $serviceType',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Remplissez les informations ci-dessous',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Champs du formulaire
                  _buildFormField(
                    controller: nameController,
                    label: 'Nom et prénom',
                    icon: Icons.person_outline,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    controller: phoneController,
                    label: 'Téléphone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    prefixText: '+224 ',
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Numéro requis' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    controller: addressController,
                    label: 'Quartier',
                    icon: Icons.location_on_outlined,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Quartier requis' : null,
                  ),
                  const SizedBox(height: 16),

                  // Date et heure sur la même ligne
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                            context, dateController, dateFormat),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeField(context, timeController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildFormField(
                    controller: descriptionController,
                    label: 'Description (optionnel)',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Bouton de soumission
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: viewModel is AsyncLoading
                          ? null
                          : () async {
                              if (formKey.currentState?.validate() ?? false) {
                                final request = ServiceRequestModel(
                                  serviceType: serviceType,
                                  name: nameController.text,
                                  address: addressController.text,
                                  phone: phoneController.text,
                                  status: "En attente",
                                  description: descriptionController.text,
                                  scheduledDate: dateController.text,
                                  scheduledTime: timeController.text,
                                  userId: ref
                                      .read(authServiceProvider)
                                      .getCurrentUser()!
                                      .uid,
                                );
                                await ref
                                    .read(serviceRequestViewModelProvider
                                        .notifier)
                                    .submitRequest(request)
                                    .then((_) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Demande envoyée avec succès !'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erreur: $error'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                });
                              }
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: viewModel is AsyncLoading
                              ? Colors.grey[300]
                              : primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: viewModel is AsyncLoading
                              ? null
                              : [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (viewModel is AsyncLoading)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            else
                              Icon(Icons.send, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              viewModel is AsyncLoading
                                  ? 'Envoi en cours...'
                                  : 'Envoyer la demande',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: primaryColor),
        prefixText: prefixText,
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField(BuildContext context, TextEditingController controller,
      DateFormat dateFormat) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Date',
        labelStyle: GoogleFonts.poppins(color: primaryColor),
        prefixIcon:
            Icon(Icons.calendar_today_outlined, color: primaryColor, size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          locale: const Locale('fr', 'FR'),
          helpText: 'SÉLECTIONNER UNE DATE',
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: primaryColor,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                  surface: Colors.white,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          controller.text = dateFormat.format(pickedDate);
        }
      },
      validator: (value) => value?.isEmpty ?? true ? 'Date requise' : null,
    );
  }

  Widget _buildTimeField(
      BuildContext context, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Heure',
        labelStyle: GoogleFonts.poppins(color: primaryColor),
        prefixIcon:
            Icon(Icons.access_time_outlined, color: primaryColor, size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          cancelText: 'ANNULER',
          confirmText: 'CONFIRMER',
          helpText: 'SÉLECTIONNER UNE HEURE',
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: primaryColor,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                  surface: Colors.white,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedTime != null) {
          final now = DateTime.now();
          final datetime = DateTime(
            now.year,
            now.month,
            now.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          controller.text = DateFormat('HH:mm').format(datetime);
        }
      },
      validator: (value) => value?.isEmpty ?? true ? 'Heure requise' : null,
    );
  }

  Future<void> _launchPhoneCall(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}

// Classes de configuration pour les différents types de services
class ServiceConfig {
  final String title;
  final String emergencyTitle;
  final IconData emergencyIcon;
  final String phoneType;
  final List<Color> gradientColors;
  final List<ServiceItemData> services;

  ServiceConfig({
    required this.title,
    required this.emergencyTitle,
    required this.emergencyIcon,
    required this.phoneType,
    required this.gradientColors,
    required this.services,
  });
}

class ServiceItemData {
  final IconData icon;
  final String title;
  final String description;

  ServiceItemData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
