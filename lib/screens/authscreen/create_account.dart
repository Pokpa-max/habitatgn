import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:habitatgn/screens/home/dashbord/dashbord.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';

class CreateAccountPage extends ConsumerWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController referenceCodeController =
      TextEditingController(); // Nouveau contrôleur pour le code de référence
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.watch(authViewModelProvider);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    final isConfirmPasswordVisible =
        ref.watch(confirmPasswordVisibilityProvider);

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
        backgroundColor: primaryColor,
        title:
            const CustomTitle(text: "Créer un compte", textColor: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                cursorColor: primaryColor,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                cursorColor: primaryColor,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: phoneController,
                cursorColor: primaryColor,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              TextField(
                controller:
                    referenceCodeController, // Nouveau champ pour le code de référence
                cursorColor: primaryColor,
                decoration: InputDecoration(
                  labelText: 'Code de référence',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                cursorColor: primaryColor,
                decoration: InputDecoration(
                  labelText: 'Mot de passe *',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
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
                obscureText: !isPasswordVisible,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: confirmPasswordController,
                cursorColor: primaryColor,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe *',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      ref
                          .read(confirmPasswordVisibilityProvider.notifier)
                          .toggleVisibility();
                    },
                  ),
                ),
                obscureText: !isConfirmPasswordVisible,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: authProvider.isCreatingAccount
                      ? null
                      : () async {
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

                          // Vérification des champs obligatoires
                          if (nameController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              passwordController.text.isEmpty ||
                              confirmPasswordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Veuillez remplir tous les champs obligatoires marqués avec *.'),
                              ),
                            );
                            return;
                          }

                          // Concaténation du code de référence avec le numéro de téléphone
                          String phoneNumberWithReference =
                              '${referenceCodeController.text}${phoneController.text}';

                          await authProvider.createUserWithEmailAndPassword(
                            context,
                            emailController.text,
                            passwordController.text,
                            nameController.text,
                            phoneNumberWithReference,
                          );
                        },
                  label: authProvider.isCreatingAccount
                      ? const SpinKitFadingCircle(
                          color: primaryColor,
                          size: 40.0,
                        )
                      : const Text(
                          'Créer le compte',
                          style: TextStyle(color: Colors.white),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
