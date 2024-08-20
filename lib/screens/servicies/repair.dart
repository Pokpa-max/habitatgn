import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:habitatgn/models/service.dart';
import 'package:habitatgn/services/authService/auth_service.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/repairService/repair_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RepairServicesScreen extends ConsumerWidget {
  const RepairServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomTitle(
            text: 'Réparations & Divers', textColor: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Services de Réparations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildServiceCard(
                    icon: Icons.plumbing,
                    title: 'Plomberie',
                    description: 'Réparations et installations de plomberie.',
                    onTap: () {
                      _showServiceRequestForm(context, ref, 'Plomberie');
                    },
                  ),
                  _buildServiceCard(
                    icon: Icons.home_repair_service,
                    title: 'Peinture et nettoyage',
                    description:
                        "Services de peinture intérieure et extérieure, ainsi que le nettoyage complet d'habitat",
                    onTap: () {
                      _showServiceRequestForm(context, ref, 'Général');
                    },
                  ),
                  _buildServiceCard(
                    icon: Icons.electrical_services,
                    title: 'Électricité',
                    description: 'Réparations et installations électriques.',
                    onTap: () {
                      _showServiceRequestForm(context, ref, 'Électricité');
                    },
                  ),
                  _buildServiceCard(
                    icon: Icons.home_repair_service,
                    title: 'Général',
                    description: 'Réparations et maintenance générales.',
                    onTap: () {
                      _showServiceRequestForm(context, ref, 'Général');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                // Appeler la fonction pour récupérer le numéro de téléphone
                final phoneNumber = await _getAgentPhoneNumber(ref);
                if (phoneNumber != null) {
                  _launchPhoneCall('tel:$phoneNumber');
                } else {
                  // Afficher un message d'erreur si le numéro de téléphone n'est pas disponible
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Numéro de téléphone non disponible.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.phone),
              label: const Text(
                'Appeler l\'agent',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showServiceRequestForm(context, ref, 'Réparations');
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: lightPrimary2)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
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

  void _showServiceRequestForm(
      BuildContext context, WidgetRef ref, String serviceType) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController =
        TextEditingController(text: '+224'); // Prérempli avec +224
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, watch, child) {
            final viewModel = ref.watch(serviceRequestViewModelProvider);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Demander le service de $serviceType',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Téléphone',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value == '+224') {
                                return 'Veuillez entrer votre numéro de téléphone';
                              }
                              if (!RegExp(r'^\+224\d{9}$').hasMatch(value)) {
                                return 'Veuillez entrer un numéro de téléphone valide';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez fournir une petite description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: viewModel is AsyncLoading
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                final request = ServiceRequestModel(
                                  serviceType: serviceType,
                                  name: nameController.text,
                                  address: addressController.text,
                                  phone: phoneController.text,
                                  description: descriptionController.text,
                                  userId: ref
                                      .read(authServiceProvider)
                                      .getCurrentUser()!
                                      .uid,
                                );
                                await ref
                                    .read(serviceRequestServiceProvider)
                                    .submitRequest(request)
                                    .then((_) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Demande de $serviceType soumise avec succès !'),
                                    ),
                                  );
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Erreur lors de la soumission: $error'),
                                    ),
                                  );
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: viewModel is AsyncLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Soumettre la demande'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchPhoneCall(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<String?> _getAgentPhoneNumber(WidgetRef ref) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('type', isEqualTo: 'repair')
          .limit(1) // Limite le résultat à un seul document
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // On suppose que le premier document est celui que nous voulons
        final document = querySnapshot.docs.first;
        return document.data()['phoneNumber'] as String?;
      }
    } catch (e) {
      print('Erreur lors de la récupération du numéro de téléphone: $e');
    }
    return null;
  }
}
