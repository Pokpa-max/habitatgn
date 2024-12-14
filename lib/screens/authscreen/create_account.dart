import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/utils/appColors.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreateAccountPage extends ConsumerStatefulWidget {
  const CreateAccountPage({super.key});

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _acceptedTerms = false; // State pour les conditions d'utilisation

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = ref.watch(authViewModelProvider);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    final isConfirmPasswordVisible =
        ref.watch(confirmPasswordVisibilityProvider);

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Créer un compte",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Commencez votre expérience avec nous",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // Champs de formulaire
                _buildTextField(
                  controller: nameController,
                  hintText: 'Nom & Prénom',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),

                // Conditions d'utilisation
                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                      activeColor: primaryColor,
                    ),
                    const Text(
                      "J'accepte les conditions d'utilisation",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Bouton de création de compte
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isCreatingAccount
                        ? null
                        : () async {
                            // Vérification des autres champs
                            if (emailController.text.isEmpty ||
                                passwordController.text.isEmpty ||
                                confirmPasswordController.text.isEmpty ||
                                nameController.text.isEmpty) {
                              authProvider.showErrorMessage(
                                context,
                                "Veuillez remplir tous les champs.",
                                color: primaryColor,
                              );
                              return;
                            }
                            if (!_isValidEmail(emailController.text)) {
                              authProvider.showErrorMessage(
                                context,
                                "Email invalide",
                                color: Colors.yellow[800],
                              );
                              return;
                            }

                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              authProvider.showErrorMessage(
                                context,
                                "Les mots de passe ne correspondent pas.",
                                color: Colors.yellow[800],
                              );
                              return;
                            }

                            if (passwordController.text.length < 6) {
                              authProvider.showErrorMessage(
                                context,
                                "Le mot de passe doit contenir au moins 6 caractères.",
                                color: Colors.yellow[800],
                              );
                              return;
                            }

                            // Vérification de l'acceptation des conditions
                            if (!_acceptedTerms) {
                              authProvider.showErrorMessage(
                                context,
                                "Veuillez accepter les conditions d'utilisation",
                                color: Colors.yellow[800],
                              );
                              return;
                            }
                            final List<ConnectivityResult> connectivityResult =
                                await (Connectivity().checkConnectivity());
                            if ((connectivityResult
                                .contains(ConnectivityResult.none))) {
                              authProvider.showErrorMessage(
                                  context, 'Connexion Internet indisponible.',
                                  color: Colors.yellow[800]);
                              return;
                            }

                            // Création du compte
                            await authProvider.createUserWithEmailAndPassword(
                              context,
                              emailController.text.trim(),
                              passwordController.text,
                              nameController.text.trim(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authProvider.isCreatingAccount
                        ? const SpinKitFadingCircle(
                            color: primaryColor,
                            size: 24,
                          )
                        : const Text(
                            'Créer mon compte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Lien de connexion
                Center(
                  child: TextButton(
                    onPressed: () => authProvider.navigateToLogin(context),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                        children: [
                          const TextSpan(text: "Déjà un compte ? "),
                          TextSpan(
                            text: "Se connecter",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // ... Reste de vos widgets ...
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                    size: 22,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
