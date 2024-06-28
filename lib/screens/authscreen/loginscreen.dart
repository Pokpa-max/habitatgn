import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:habitatgn/screens/authscreen/create_account.dart';
import 'package:habitatgn/screens/authscreen/emailscreen.dart';
import 'package:habitatgn/screens/home/dashbord/dashbord.dart';
import 'package:habitatgn/screens/home/home_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: lightPrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Connexion',
                  style: TextStyle(
                    color: primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
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
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
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
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.black),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Mot de passe oublié?',
                        style: TextStyle(color: Colors.orangeAccent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, // Prendre toute la largeur disponible
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // Connexion réussie avec l'email et mot de passe
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      } catch (e) {
                        // Gérer les erreurs d'authentification par email
                        print('Erreur de connexion par email: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                          color: Colors.cyan,
                          width:
                              2), // Couleur et épaisseur du contour du bouton
                    ),
                    child: const Text('Se connecter'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Ou connectez-vous avec ",
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          // final LoginResult result =
                          //     await FacebookAuth.instance.login();
                          // if (result.status == LoginStatus.success) {
                          //   Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => const DashbordScreen()
                          //         ),
                          //   );
                          // }
                          authService.signInWithFacebook(context);
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
                    ElevatedButton.icon(
                      onPressed: () async {
                        authService.signInWithGoogle(context);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
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
                  ],
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
                      },
                      child: const Text(
                        "S'inscrire maintenant",
                        style: TextStyle(color: primary),
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
