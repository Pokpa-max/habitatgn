// ignore_for_file: avoid_print

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:habitatgn/screens/authscreen/create_account.dart';
import 'package:habitatgn/screens/forgot_password/forgotPasswordScreen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:math' as math;

class LoginScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.read(authViewModelProvider);
    final isLoading =
        ref.watch(authViewModelProvider.select((value) => value.isLoading));
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.1),

                // En-tête
                Text(
                  "Bienvenue !",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Connectez-vous pour continuer",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: size.height * 0.06),

                // Champs de connexion
                _buildTextField(
                  controller: emailController,
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: passwordController,
                  hintText: 'Mot de passe',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isVisible: isPasswordVisible,
                  onVisibilityToggle: () {
                    ref
                        .read(passwordVisibilityProvider.notifier)
                        .toggleVisibility();
                  },
                ),

                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotUserPasswordScreen()),
                            );
                          },
                    child: Text(
                      'Mot de passe oublié?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton de connexion
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (emailController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            authViewModel.showErrorMessage(
                                context, "Veuillez remplir tous les champs.",
                                color: primaryColor);
                            return;
                          }

                          if (!_isValidEmail(emailController.text)) {
                            authViewModel.showErrorMessage(
                                context, "Email invalide",
                                color: Colors.yellow[800]);
                            return;
                          }

                          final List<ConnectivityResult> connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if ((connectivityResult
                              .contains(ConnectivityResult.none))) {
                            authViewModel.showErrorMessage(
                                context, 'Connexion Internet indisponible.',
                                color: Colors.yellow[800]);
                            return;
                          }

                          await authViewModel.signInWithEmailAndPassword(
                            context,
                            emailController.text.trim(),
                            passwordController.text,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SpinKitFadingCircle(color: primaryColor, size: 25)
                      : const Text(
                          'Se connecter',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),

                const SizedBox(height: 24),

                // Séparateur
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child:
                          Text('OU', style: TextStyle(color: Colors.grey[600])),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),

                const SizedBox(height: 24),

                // Boutons sociaux
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        size: 22,
                        color: Colors.red,
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              final List<ConnectivityResult>
                                  connectivityResult =
                                  await (Connectivity().checkConnectivity());
                              if ((connectivityResult
                                  .contains(ConnectivityResult.none))) {
                                authViewModel.showErrorMessage(
                                    context, 'Connexion Internet indisponible.',
                                    color: primaryColor);
                                return;
                              }

                              await authViewModel.signInWithGoogle(context);
                            },
                    ),
                    const SizedBox(width: 20),
                    _buildSocialButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.facebook,
                        size: 22,
                        color: Colors.blue,
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              final List<ConnectivityResult>
                                  connectivityResult =
                                  await (Connectivity().checkConnectivity());
                              if ((connectivityResult
                                  .contains(ConnectivityResult.none))) {
                                authViewModel.showErrorMessage(
                                    context, 'Connexion Internet indisponible.',
                                    color: primaryColor);
                                return;
                              }
                              await authViewModel.signInWithFacebook(context);
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Création de compte
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => authViewModel.navigateToCreateAccount(context),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      children: [
                        const TextSpan(text: "Pas encore de compte ? "),
                        TextSpan(
                          text: "Créer un compte",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = true,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconTheme(
            data: IconThemeData(color: Colors.grey[700]),
            child: icon,
          ),
        ),
      ),
    );
  }
}
