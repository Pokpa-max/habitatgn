import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/screens/favoris/favoris.dart';
import 'package:habitatgn/screens/home/dashbord/dashbord.dart';
import 'package:habitatgn/screens/profil/profil.dart';
import 'package:habitatgn/utils/appcolors.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      backgroundColor: lightPrimary,
      body: Center(
        child: IndexedStack(
          index: selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: lightPrimary,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const DashbordScreen(),
    const FavoritesPage(),
    const ProfilePage(),
  ];
}
