import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/utils/appColors.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreateAccountPage extends ConsumerWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  CreateAccountPage({super.key});
  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.watch(authViewModelProvider);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    final isConfirmPasswordVisible =
        ref.watch(confirmPasswordVisibilityProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Créez votre compte",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: nameController,
                    hintText: 'Nom & Présnom',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirmer le mot de passe',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: isConfirmPasswordVisible,
                    onVisibilityToggle: () {
                      ref
                          .read(confirmPasswordVisibilityProvider.notifier)
                          .toggleVisibility();
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (value) {},
                        fillColor: WidgetStateProperty.resolveWith(
                            (states) => primaryColor),
                      ),
                      const Text(
                        'J’accepte les conditions d’utilisation',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authProvider.isCreatingAccount
                          ? null
                          : () async {
                              // Votre logique de création de compte existante
                              // Validation des champs
                              if (emailController.text.isEmpty ||
                                  passwordController.text.isEmpty ||
                                  confirmPasswordController.text.isEmpty ||
                                  nameController.text.isEmpty) {
                                authProvider.showErrorMessage(
                                  color: primaryColor,
                                  context,
                                  "Veuillez remplir tous les champs.",
                                );
                                return;
                              }

                              // Validation de l'email
                              if (!_isValidEmail(emailController.text)) {
                                authProvider.showErrorMessage(
                                  context,
                                  "Veuillez entrer une adresse email valide.",
                                );
                                return;
                              }
                              // Vérification si les mots de passe correspondent
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Les mots de passe ne correspondent pas.'),
                                  ),
                                );
                                return;
                              }

                              await authProvider.createUserWithEmailAndPassword(
                                  context,
                                  emailController.text,
                                  passwordController.text,
                                  nameController.text);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: authProvider.isCreatingAccount
                          ? const SpinKitFadingCircle(
                              color: primaryColor,
                              size: 30.0,
                            )
                          : const Text(
                              'Créez votre compte',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Naviguer vers la page de connexion
                        authProvider.navigateToLogin(context);
                      },
                      child: const Text(
                        'Avez déjà un compte ? Connectez-vous',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
