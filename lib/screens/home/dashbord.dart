import 'package:flutter/material.dart';
import 'package:habitatgn/screens/home/categories/categories_list.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/widgets/dashbord/dashbord.dart';

class DashbordScreen extends StatelessWidget {
  const DashbordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HABITATGN',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchField(context),
              const SizedBox(height: 20),
              buildSectionTitle('Logements Recommandés'),
              const SizedBox(height: 10),
              _buildRecommendedHousingList(context),
              const SizedBox(height: 20),
              buildSectionTitle('Catégories'),
              const SizedBox(height: 10),
              _buildCategoryGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Rechercher un logement...',
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.cyan,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.cyan),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.cyan),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchPage(),
          ),
        );
      },
    );
  }

  Widget _buildRecommendedHousingList(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HousingDetailPage(
                    imageUrl: 'assets/images/maison.jpg',
                    imageUrls: [
                      'assets/images/maison2.jpg',
                      'assets/images/logo.png',
                    ],
                    title: 'Luxurious Apartment',
                    location: 'Paris, France',
                    price: '€2,000 / mois',
                    description:
                        'Un magnifique appartement situé au cœur de Paris avec une vue imprenable sur la Tour Eiffel. Comprend 2 chambres, 2 salles de bains, un grand salon et une cuisine entièrement équipée.',
                    amenities: [
                      'Wi-Fi gratuit',
                      'Cuisine équipée',
                      'Piscine',
                      'Salle de gym',
                      'Parking gratuit',
                    ],
                    latitude: 48.8588443,
                    longitude: 2.2943506,
                  ),
                ),
              );
            },
            child: RecommendedHousingCard(
              imageUrl: 'assets/images/maison.jpg',
              title: 'Maison en vente ${index + 1}',
              location: 'Ville ${index + 1}',
              price: '\$${(index + 1) * 1000}',
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
        return SizedBox(
          height: crossAxisCount * 100.0, // Ajustez cette valeur si nécessaire
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CategoryCard(
                icon: Icons.villa,
                label: 'Villas',
                onTap: () {},
              ),
              CategoryCard(
                icon: Icons.house,
                label: 'Maisons',
                onTap: () {},
              ),
              CategoryCard(
                icon: Icons.home_work,
                label: 'Studios',
                onTap: () {},
              ),
              CategoryCard(
                icon: Icons.hotel,
                label: 'Hôtels',
                onTap: () {},
              ),
              CategoryCard(
                icon: Icons.store,
                label: 'Magasin',
                onTap: () {},
              ),
              CategoryCard(
                icon: Icons.terrain,
                label: 'Terrain',
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function onTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryListPage(
              category: label,
              icon: icon,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: Colors.cyan),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecommendedHousingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String price;

  const RecommendedHousingCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imageUrl,
            width: 150,
            height: 80,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(location),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.cyan,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
