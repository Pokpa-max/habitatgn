import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:habitatgn/screens/authscreen/create_account.dart';
import 'package:habitatgn/screens/home/dashbord/dashbord.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authViewModelProvider);
    final isLoading =
        ref.watch(authViewModelProvider.select((value) => value.isLoading));
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightPrimary,
        title: const Text(
          "HABITATGN",
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: lightPrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 15),
                TextField(
                  cursorColor: primaryColor,
                  controller: passwordController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(15),
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
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Mot de passe oublié?',
                        style: TextStyle(color: Colors.red[500]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await authService.signInWithEmailAndPassword(
                              context,
                              emailController.text,
                              passwordController.text,
                            );
                          },
                    label: isLoading
                        ? const SpinKitFadingCircle(
                            color: primaryColor,
                            size: 40.0,
                          )
                        : const Text('Se connecter',
                            style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Ou connectez-vous avec ",
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            try {
                              await authService.signInWithFacebook(context);
                            } catch (e) {
                              print('Erreur de connexion Facebook: $e');
                            }
                          },
                    icon: const Icon(
                      Icons.facebook,
                      color: Colors.white,
                    ),
                    label: const Text('Facebook',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            try {
                              await authService.signInWithGoogle(context);
                            } catch (e) {
                              print('Erreur de connexion Google: $e');
                            }
                          },
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Google',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas de compte?',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle navigation to register page
                        authService.navigateToCreateAccount(context);
                      },
                      child: const Text(
                        "S'inscrire maintenant",
                        style: TextStyle(color: primaryColor),
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
}
