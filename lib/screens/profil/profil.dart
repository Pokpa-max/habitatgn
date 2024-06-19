import 'package:flutter/material.dart';

import 'package:habitatgn/utils/appColors.dart'; // Assurez-vous d'importer le fichier de couleurs

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              color: primary,
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: primary,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Guilavogui Pokpa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'pokpawolomagui@gmail.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildProfileOption(
                  icon: Icons.lock,
                  title: 'Changer le mot de passe',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.settings,
                  title: 'Paramètres',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Settings',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.help,
                  title: 'Aide & Support',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.logout,
                  title: 'Se déconnecter',
                  onTap: () {},
                  color: Colors.red,
                ),
                _buildProfileOption(
                  icon: Icons.delete,
                  title: 'Supprimer son compte',
                  onTap: () {},
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = primary,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          onTap: onTap,
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: Colors.grey,
          ),
        ),
        Divider(
          color: Colors.grey[300],
        ),
      ],
    );
  }
}
