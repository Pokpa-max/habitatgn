import 'package:flutter/material.dart';
import 'package:habitatgn/utils/appcolors.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Aide & Support',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Foire aux questions'),
            const SizedBox(height: 10),
            _buildFAQItem(
              question:
                  'Comment puis-je rechercher des logements disponibles ?',
              answer:
                  'Vous pouvez utiliser notre barre de recherche pour spécifier vos critères et affiner les résultats.',
            ),
            _buildFAQItem(
              question: 'Comment contacter un propriétaire pour une visite ?',
              answer:
                  "Sur chaque fiche de logement, vous trouverez un bouton pour contacter le propriétaire ou l'agence.",
            ),
            _buildFAQItem(
              question: 'Comment puis-je ajouter un logement à mes favoris ?',
              answer:
                  "Dans la fiche détaillée du logement, vous trouverez une option pour l'ajouter à vos favoris.",
            ),
            _buildFAQItem(
              question:
                  'Comment puis-je gérer mes préférences de notification ?',
              answer:
                  'Vous pouvez gérer vos préférences de notification dans les paramètres de votre compte, en sélectionnant les types de notifications que vous souhaitez recevoir.',
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Support technique'),
            const SizedBox(height: 10),
            _buildSupportItem(
              icon: Icons.wifi_off,
              title: 'Problèmes de connexion',
              description:
                  'Si vous rencontrez des difficultés pour vous connecter à votre compte, vérifiez votre connexion Internet et réessayez.',
            ),
            _buildSupportItem(
              icon: Icons.warning,
              title: "Problèmes d'affichage des résultats",
              description:
                  "Si les résultats de recherche ne s'affichent pas correctement, essayez de rafraîchir l'application ou vérifiez les filtres appliqués.",
            ),
            _buildSupportItem(
              icon: Icons.bug_report,
              title: 'Signaler un bug ou une erreur',
              description:
                  "Si vous trouvez un bug ou une erreur dans l'application, veuillez nous en informer en utilisant le formulaire de contact.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ExpansionTile(
        collapsedIconColor: primaryColor,
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryColor, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
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
}
