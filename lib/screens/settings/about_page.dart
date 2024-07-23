// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:habitatgn/utils/appcolors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'À propos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildAppLogo(),
            const SizedBox(height: 20),
            _buildAppDescription(),
            const SizedBox(height: 20),
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Center(
      child: Image.asset(
        'assets/images/logo.png', // Replace with your app logo image asset path
        width: 150,
        height: 150,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildAppDescription() {
    return Text(
      'HabitatGN est une application de recherche de logements qui vous permet de trouver facilement des propriétés à louer ou à acheter. Explorez des milliers de listes mises à jour quotidiennement et trouvez le logement parfait pour vous et votre famille.',
      style: TextStyle(fontSize: 16),
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Version 1.0.0',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        SizedBox(height: 10),
        Text(
          'Développé par VotreEntreprise',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
