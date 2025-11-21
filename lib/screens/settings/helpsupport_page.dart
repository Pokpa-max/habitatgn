// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/utils/appcolors.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        surfaceTintColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Aide & Support',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section FAQ
            _buildSectionHeader(
              icon: Icons.help_outline,
              title: 'Foire aux questions',
              subtitle: 'Trouvez des réponses aux questions courantes',
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildModernFAQItem(
                    question:
                        'Comment puis-je rechercher des logements disponibles ?',
                    answer:
                        'Vous pouvez utiliser notre barre de recherche ou le filtre pour spécifier vos critères et affiner les résultats.',
                    isFirst: true,
                  ),
                  _buildDivider(),
                  _buildModernFAQItem(
                    question:
                        'Comment contacter un propriétaire pour une visite ?',
                    answer:
                        "Sur chaque fiche de logement, vous trouverez un bouton pour contacter le propriétaire ou l'agence.",
                  ),
                  _buildDivider(),
                  _buildModernFAQItem(
                    question:
                        'Comment puis-je ajouter un logement à mes favoris ?',
                    answer:
                        "Dans la fiche détaillée du logement, vous trouverez une option pour l'ajouter à vos favoris.",
                  ),
                  _buildDivider(),
                  _buildModernFAQItem(
                    question:
                        'Comment puis-je gérer mes préférences de notification ?',
                    answer:
                        'Vous pouvez gérer vos préférences de notification dans les paramètres de votre compte, en sélectionnant les types de notifications que vous souhaitez recevoir.',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section Support technique
            _buildSectionHeader(
              icon: Icons.support_agent_outlined,
              title: 'Support technique',
              subtitle: 'Solutions aux problèmes techniques courants',
            ),
            const SizedBox(height: 16),
            _buildModernSupportItem(
              icon: Icons.wifi_off_outlined,
              title: 'Problèmes de connexion',
              description:
                  'Si vous rencontrez des difficultés pour vous connecter à votre compte, vérifiez votre connexion Internet et réessayez.',
            ),
            const SizedBox(height: 12),
            _buildModernSupportItem(
              icon: Icons.visibility_off_outlined,
              title: "Problèmes d'affichage des résultats",
              description:
                  "Si les résultats de recherche ne s'affichent pas correctement, essayez de rafraîchir l'application ou vérifiez les filtres appliqués.",
            ),
            const SizedBox(height: 12),
            _buildModernSupportItem(
              icon: Icons.bug_report_outlined,
              title: 'Signaler un bug ou une erreur',
              description:
                  "Si vous trouvez un bug ou une erreur dans l'application, veuillez nous en informer en utilisant le formulaire de contact.",
            ),

            const SizedBox(height: 32),

            // Section Contact rapide
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.headset_mic_outlined,
                    color: primaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Besoin d\'aide supplémentaire ?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notre équipe de support est là pour vous aider. N\'hésitez pas à nous contacter.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigation vers la page de contact
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Nous contacter',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernFAQItem({
    required String question,
    required String answer,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        iconColor: primaryColor,
        collapsedIconColor: Colors.grey[600],
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.grey[800],
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSupportItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey[100],
    );
  }
}
