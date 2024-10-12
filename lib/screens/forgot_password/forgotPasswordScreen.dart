import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/utils/appColors.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ForgotUserPasswordScreen extends ConsumerStatefulWidget {
  const ForgotUserPasswordScreen({super.key});

  @override
  ConsumerState<ForgotUserPasswordScreen> createState() =>
      _ForgotUserPasswordScreenState();
}

class _ForgotUserPasswordScreenState
    extends ConsumerState<ForgotUserPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false; // Pour afficher un indicateur de chargement
  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ref.read(authViewModelProvider).showErrorMessage(
          context, "Veuillez entrer un email",
          color: primaryColor);
      return;
    }
    if (!_isValidEmail(emailController.text)) {
      ref.read(authViewModelProvider).showErrorMessage(
            context,
            "Veuillez entrer une adresse email valide.",
          );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });
      await ref.read(authViewModelProvider).resetPassword(
            context,
            email,
          );

      ref.read(authViewModelProvider).showErrorMessage(
            context,
            "Instructions de réinitialisation envoyées à votre email",
          );
    } catch (e) {
      ref.read(authViewModelProvider).showErrorMessage(context, e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
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
                      "Mot de passe oublié ?",
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
            const SizedBox(height: 10),
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: primaryColor,
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Pas de soucis, nous vous enverrons des instructions pour réinitialiser votre mot de passe.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Entrez votre Email',
                        labelStyle: TextStyle(color: Colors.grey[700]),
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null // Désactivez le bouton si en chargement
                            : resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: isLoading
                            ? const SpinKitFadingCircle(
                                color: primaryColor,
                                size: 20.0,
                              )
                            : const Text(
                                'Réinitialiser le mot de passe',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
