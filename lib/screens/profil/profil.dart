import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: ElevatedButton.icon(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.grey[300]),
        ),
        icon: const Icon(
          Icons.logout,
          color: Colors.red,
        ),
        label: const Text(
          'Se deconnecter',
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {},
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
              color: Colors.cyan,
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 5.0),
                Text(
                  'Guilavogui Pokpa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.blue),
                  title: const Text('Changer le mot de passe '),
                  onTap: () {},
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  ),
                ),
                Divider(
                  color: Colors.grey[300],
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.blue),
                  title: const Text('Parametres'),
                  onTap: () {},
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  ),
                ),
                Divider(
                  color: Colors.grey[300],
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.blue),
                  title: const Text('Privacy Settings'),
                  onTap: () {},
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  ),
                ),
                Divider(
                  color: Colors.grey[300],
                ),
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.blue),
                  title: const Text('Aide & Support'),
                  onTap: () {},
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  ),
                ),
                Divider(
                  color: Colors.grey[300],
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.blue),
                  title: const Text('Se déconnecter'),
                  onTap: () {},
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  ),
                ),
                Divider(
                  color: Colors.grey[300],
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Supprimer son compte'),
                  onTap: () {},
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
