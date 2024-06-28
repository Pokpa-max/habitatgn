import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitatgn/screens/home/dashbord/dashbord.dart';

class EmailLoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  EmailLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login par Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                  // Connexion réussie avec l'email et mot de passe
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashbordScreen()),
                  );
                } catch (e) {
                  // Gérer les erreurs d'authentification par email
                  print('Erreur de connexion par email: $e');
                }
              },
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
