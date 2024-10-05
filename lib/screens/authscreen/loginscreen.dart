import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:habitatgn/screens/authscreen/create_account.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Ajouter ceci pour la vérification de la connectivité

class LoginScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.read(authViewModelProvider);
    final isLoading =
        ref.watch(authViewModelProvider.select((value) => value.isLoading));
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightPrimary2, primaryColor], // Dégradé
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                ),
                const Text(
                  "Se connecter",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                _buildCard(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: emailController,
                        labelText: 'Email *',
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: passwordController,
                        labelText: 'Mot de passe *',
                        obscureText: !isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            ref
                                .read(passwordVisibilityProvider.notifier)
                                .toggleVisibility();
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Mot de passe oublié?',
                            style: TextStyle(color: Colors.red[300]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                // Vérification de la connectivité
                                final connectivityResult =
                                    await Connectivity().checkConnectivity();
                                if (connectivityResult ==
                                    ConnectivityResult.none) {
                                  authViewModel.showErrorMessage(
                                    context,
                                    "Pas de connexion Internet. Veuillez vérifier votre connexion.",
                                  );
                                  return;
                                }

                                // Validation des champs
                                if (emailController.text.isEmpty ||
                                    passwordController.text.isEmpty) {
                                  authViewModel.showErrorMessage(
                                    color: primaryColor,
                                    context,
                                    "Veuillez remplir tous les champs.",
                                  );
                                  return;
                                }

                                // Tentative de connexion
                                await authViewModel.signInWithEmailAndPassword(
                                  context,
                                  emailController.text,
                                  passwordController.text,
                                );
                              },
                        label: isLoading
                            ? const SpinKitFadingCircle(
                                color: Colors.white,
                                size: 30.0,
                              )
                            : const Text(
                                'Se connecter',
                                style: TextStyle(fontSize: 16),
                              ),
                        backgroundColor: primaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Ou connectez-vous avec",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 20),
                _buildSocialButton(
                  icon: const Icon(Icons.facebook, color: Colors.white),
                  color: Colors.blueAccent,
                  label: 'Facebook',
                  onPressed: isLoading
                      ? null
                      : () async {
                          try {
                            final connectivityResult =
                                await Connectivity().checkConnectivity();
                            if (connectivityResult == ConnectivityResult.none) {
                              authViewModel.showErrorMessage(
                                context,
                                "Pas de connexion Internet. Veuillez vérifier votre connexion.",
                              );
                              return;
                            }
                            await authViewModel.signInWithFacebook(context);
                          } catch (e) {
                            print('Erreur de connexion Facebook: $e');
                          }
                        },
                ),
                const SizedBox(height: 16),
                _buildSocialButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.white,
                  ),
                  color: Colors.redAccent,
                  label: 'Google',
                  onPressed: isLoading
                      ? null
                      : () async {
                          try {
                            final connectivityResult =
                                await Connectivity().checkConnectivity();
                            if (connectivityResult == ConnectivityResult.none) {
                              authViewModel.showErrorMessage(
                                context,
                                "Pas de connexion Internet. Veuillez vérifier votre connexion.",
                              );
                              return;
                            }
                            await authViewModel.signInWithGoogle(context);
                          } catch (e) {
                            print('Erreur de connexion Google: $e');
                          }
                        },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas de compte?',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        authViewModel.navigateToCreateAccount(context);
                      },
                      child: const Text(
                        "S'inscrire maintenant",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 8,
      color: lightPrimary2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: primaryColor,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey[200],
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  Widget _buildElevatedButton({
    required VoidCallback? onPressed,
    required Widget label,
    required Color backgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: label,
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required Color color,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 0.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
