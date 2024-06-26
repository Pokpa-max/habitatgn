import 'package:flutter/material.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/adversting/adversting.dart';
import 'package:habitatgn/screens/house/houseList.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/utils/appColors.dart';

class DashbordScreen extends StatelessWidget {
  const DashbordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void performSearch() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SearchPage(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'HABITATGN',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: primary,
        actions: [
          InkWell(
            onTap: performSearch,
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), color: Colors.white),
              child: const Icon(
                Icons.search,
                color: primary,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {},
            child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                child: const Icon(
                  Icons.notifications,
                  color: primary,
                )),
          ),
          const SizedBox(
            width: 5,
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdvertisementCarousel(
            imageUrls: [
              'assets/images/maison.jpg',
              'assets/images/maison2.jpg',
              'assets/images/maison.jpg',
            ],
            subtitles: ['Subtitle  1', 'Subtitle 2', 'Subtitle 3'],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  buildSectionTitle('Catégories de Logements'),
                  const SizedBox(height: 10),
                  _buildCategoryGrid(context, 'Logements'),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  buildSectionTitle('Autres Catégories'),
                  const SizedBox(height: 10),
                  _buildCategoryGrid(context, 'Autres'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, String categoryType) {
    final categories = categoryType == 'Logements'
        ? [
            CategoryData(Icons.villa, 'Villas'),
            CategoryData(Icons.house, 'Maisons'),
            CategoryData(Icons.home_work, 'Studios'),
            CategoryData(Icons.hotel, 'Hôtels'),
          ]
        : [
            CategoryData(Icons.store, 'Magasin'),
            CategoryData(Icons.terrain, 'Terrain'),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          physics: const NeverScrollableScrollPhysics(),
          children: categories.map((category) {
            return CategoryCard(
              icon: category.icon,
              label: category.label,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HouselistScreen(
                      title: category.label,
                      iconData: category.icon,
                      isForSale: false,
                      results: [
                        House(
                            type: 'Villa',
                            location: 'Paris',
                            commune: 'Commune1',
                            quartier: 'Quartier1',
                            price: 3000,
                            imageUrl: 'assets/images/maison.jpg',
                            numRooms: 3),
                        House(
                            type: 'Maison',
                            location: 'Lyon',
                            commune: 'Commune2',
                            quartier: 'Quartier2',
                            price: 2500,
                            numRooms: 2,
                            imageUrl: 'assets/images/maison.jpg'),
                      ],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SearchPage(),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        // fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class CategoryData {
  final IconData icon;
  final String label;

  CategoryData(this.icon, this.label);
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
      onTap: () => onTap(),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: primary),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              imageUrl,
              width: 150,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  price,
                  style: const TextStyle(
                    color: primary,
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
