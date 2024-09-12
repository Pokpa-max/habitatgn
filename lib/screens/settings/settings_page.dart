import 'package:firebase_auth/firebase_auth.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/providers/provider.dart';
import 'package:habitatgn/screens/authscreen/loginscreen.dart';
import 'package:habitatgn/screens/preference/preference.dart';
import 'package:habitatgn/screens/settings/about_page.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/viewmodels/settings_provider/settings.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    User? user = ref.read(settingViewModelProvider.notifier).currentUser;

    if (user == null) {
      // Si l'utilisateur n'est pas connecté, redirigez vers l'écran de connexion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }

    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text('Paramètres', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        children: [
          _buildSettingsOption(
            icon: Icons.lock,
            title: 'Changer le mot de passe',
            onTap: () {
              _checkInternetAndExecute(context, ref, () {
                _showChangePasswordDialog(context, ref);
              });
            },
          ),
          const SizedBox(height: 20),
          _buildSettingsOption(
            icon: Icons.location_on,
            title: 'Préférences de notification',
            onTap: () {
              _checkInternetAndExecute(context, ref, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HousingPreferencesScreen(
                      userId: user!.uid,
                    ),
                  ),
                );
              });
            },
          ),
          const SizedBox(height: 20),
          _buildSettingsOption(
            icon: Icons.info,
            title: 'À propos',
            onTap: () {
              _checkInternetAndExecute(context, ref, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              });
            },
          ),
          _buildSettingsOption(
            icon: Icons.delete,
            title: 'Supprimer votre compte',
            onTap: () {
              _checkInternetAndExecute(context, ref, () {
                _showDeleteAccountDialog(context, ref);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: primaryColor),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }

  Future<void> _checkInternetAndExecute(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onSuccess,
  ) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Affichez un message à l'utilisateur si la connexion Internet est absente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text(
                'Aucune connexion Internet. Veuillez vérifier votre connexion.'),
          ),
        ),
      );
    } else {
      // Exécutez l'action si la connexion Internet est disponible
      onSuccess();
    }
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final obscureCurrentPassword =
                ref.watch(obscureCurrentPasswordProvider);
            final obscureNewPassword = ref.watch(obscureNewPasswordProvider);

            return AlertDialog(
              title: const Text(
                'Changer le mot de passe',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPasswordTextField(
                    controller: currentPasswordController,
                    labelText: 'Mot de passe actuel',
                    obscureText: obscureCurrentPassword,
                    toggleObscure: () {
                      ref.read(obscureCurrentPasswordProvider.notifier).state =
                          !obscureCurrentPassword;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPasswordTextField(
                    controller: newPasswordController,
                    labelText: 'Nouveau mot de passe',
                    obscureText: obscureNewPassword,
                    toggleObscure: () {
                      ref.read(obscureNewPasswordProvider.notifier).state =
                          !obscureNewPassword;
                    },
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.grey),
                      foregroundColor: WidgetStateProperty.all(Colors.white)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(primaryColor),
                      foregroundColor: WidgetStateProperty.all(Colors.white)),
                  onPressed: () async {
                    String currentPassword =
                        currentPasswordController.text.trim();
                    String newPassword = newPasswordController.text.trim();
                    if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
                      try {
                        await ref
                            .read(settingViewModelProvider.notifier)
                            .changePassword(currentPassword, newPassword);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Mot de passe modifié avec succès')),
                        );
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $error'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Changer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String labelText,
    required VoidCallback toggleObscure,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleObscure,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Supprimer le compte',
          style: TextStyle(fontSize: 20, color: Colors.red),
        ),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
            style: TextStyle(fontSize: 16)),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.grey),
                foregroundColor: WidgetStateProperty.all(Colors.white)),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red),
                foregroundColor: WidgetStateProperty.all(Colors.white)),
            onPressed: () async {
              await ref.read(settingViewModelProvider.notifier).deleteAccount();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Votre compte a été supprimé')),
              );
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
