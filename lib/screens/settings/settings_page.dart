import 'package:firebase_auth/firebase_auth.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final obscureCurrentPassword =
                ref.watch(obscureCurrentPasswordProvider);
            final obscureNewPassword = ref.watch(obscureNewPasswordProvider);

            return AlertDialog(
              title: Text(
                'Changer le mot de passe',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPasswordField(
                      controller: currentPasswordController,
                      labelText: 'Mot de passe actuel',
                      obscureText: obscureCurrentPassword,
                      onToggleObscure: () {
                        ref
                            .read(obscureCurrentPasswordProvider.notifier)
                            .state = !obscureCurrentPassword;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe actuel';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: newPasswordController,
                      labelText: 'Nouveau mot de passe',
                      obscureText: obscureNewPassword,
                      onToggleObscure: () {
                        ref.read(obscureNewPasswordProvider.notifier).state =
                            !obscureNewPassword;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nouveau mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Annuler',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => _handlePasswordChange(
                    context: context,
                    ref: ref,
                    formKey: formKey,
                    currentPassword: currentPasswordController.text.trim(),
                    newPassword: newPasswordController.text.trim(),
                  ),
                  child: Text(
                    'Changer',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onPressed: onToggleObscure,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Future<void> _handlePasswordChange({
    required BuildContext context,
    required WidgetRef ref,
    required GlobalKey<FormState> formKey,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(settingViewModelProvider.notifier)
          .changePassword(currentPassword, newPassword);

      Navigator.pop(context);

      _showToast(
        message: 'Mot de passe modifié avec succès',
        backgroundColor: Colors.green,
      );
    } catch (error) {
      _showToast(
        message: 'Erreur: ${error.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  void _showToast({
    required String message,
    required Color backgroundColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
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
