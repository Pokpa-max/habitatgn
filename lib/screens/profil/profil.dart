import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/screens/authscreen/loginscreen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    final userProfileViewModel = ref.read(authViewModelProvider);
    userProfileViewModel.fetchUserProfile(context);
  }

  @override
  Widget build(BuildContext context) {
    final userProfileViewModel = ref.watch(authViewModelProvider);
    final user = userProfileViewModel.user;
    final Map<String, dynamic>? userFireStore =
        userProfileViewModel.userProfile;

    return Scaffold(
      backgroundColor: lightPrimary,
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
              color: primaryColor,
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.displayName ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
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
                  onTap: () {
                    // TODO: Implémenter la logique pour changer le mot de passe
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Changer le mot de passe'),
                          content: const Text(
                              'Implémenter le formulaire pour changer le mot de passe ici.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Implémenter la logique de changement de mot de passe ici
                                Navigator.of(context).pop();
                              },
                              child: const Text('Changer'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                _buildProfileOption(
                  icon: Icons.settings,
                  title: 'Paramètres',
                  onTap: () {
                    // TODO: Naviguer vers la page des paramètres
                    // Exemple de navigation : Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                  },
                ),
                _buildProfileOption(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Settings',
                  onTap: () {
                    // TODO: Naviguer vers la page des paramètres de confidentialité
                    // Exemple de navigation : Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacySettingsPage()));
                  },
                ),
                _buildProfileOption(
                  icon: Icons.help,
                  title: 'Aide & Support',
                  onTap: () {
                    // TODO: Naviguer vers la page d'aide et de support
                    // Exemple de navigation : Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportPage()));
                  },
                ),
                _buildProfileOption(
                  icon: Icons.logout,
                  title: 'Se déconnecter',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Se déconnecter'),
                          content: const Text(
                              'Êtes-vous sûr de vouloir vous déconnecter ?'),
                          actions: [
                            TextButton(
                              style: ButtonStyle(
                                  foregroundColor:
                                      WidgetStateProperty.all(Colors.blue)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(primaryColor),
                                  foregroundColor:
                                      WidgetStateProperty.all(backgroundColor)),
                              onPressed: () async {
                                userProfileViewModel.signOut(context);
                              },
                              child: const Text('Se déconnecter'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  color: Colors.red,
                ),
                _buildProfileOption(
                  icon: Icons.delete,
                  title: 'Supprimer son compte',
                  onTap: () {
                    // TODO: Implémenter la logique pour supprimer le compte
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Supprimer son compte'),
                          content: const Text(
                              'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Implémenter la logique de suppression de compte ici
                                Navigator.of(context)
                                    .popUntil(ModalRoute.withName('/'));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildProfileOption({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color color = primaryColor,
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
