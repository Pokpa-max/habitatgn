import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/screens/authscreen/loginscreen.dart';
import 'package:habitatgn/screens/preference/preference.dart';
import 'package:habitatgn/screens/settings/contact_page.dart';
import 'package:habitatgn/screens/settings/helpsupport_page.dart';
import 'package:habitatgn/screens/settings/settings_page.dart';
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
                  icon: Icons.settings,
                  title: 'Paramètres',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()));
                  },
                ),
                // _buildProfileOption(
                //   icon: Icons.help,
                //   title: 'Notifications',
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => HousingPreferencesScreen(
                //                   userId: user!.uid.toString(),
                //                 )));
                //   },
                // ),
                _buildProfileOption(
                  icon: Icons.help,
                  title: 'Aide & Support',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HelpSupportPage()));
                  },
                ),
                _buildProfileOption(
                  icon: Icons.contact_mail_rounded,
                  title: 'Nous contacter',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ContactPage()));
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
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(Colors.grey),
                                  foregroundColor:
                                      WidgetStateProperty.all(Colors.white)),
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              child: const Text('annuler'),
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
