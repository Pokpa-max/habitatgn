import 'package:flutter/material.dart';
import 'package:habitatgn/models/adversting.dart';
import 'package:habitatgn/screens/home/categories/categories_list.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/utils/appColors.dart';

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
        backgroundColor: primary,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(context),
            const SizedBox(height: 20),
            // buildSectionTitle('Logements Recommandés'),
            // const SizedBox(height: 10),
            // _buildRecommendedHousingList(context),
            const SizedBox(height: 20),
            buildSectionTitle('Catégories de Logements'),
            const SizedBox(height: 10),
            _buildCategoryGrid(context, 'Logements'),
            const SizedBox(height: 20),
            buildSectionTitle('Autres Catégories'),
            const SizedBox(height: 10),
            _buildCategoryGrid(context, 'Autres'),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Rechercher un logement...',
          prefixIcon: Icon(
            Icons.search,
            color: primary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.0),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SearchPage(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedHousingList(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
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
              onTap: () {},
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
        elevation: 2,
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

  Widget _buildAdvertisementsList(BuildContext context) {
    final List<AdvertisementData> advertisements = [
      AdvertisementData(
        imageUrl: 'assets/images/advertisement1.jpg',
        title: 'Promotion spéciale',
        description: 'Économisez jusqu\'à 50% sur les appartements de luxe !',
      ),
      AdvertisementData(
        imageUrl: 'assets/images/advertisement2.jpg',
        title: 'Offre exclusive',
        description: 'Découvrez nos nouvelles maisons à des prix incroyables.',
      ),
      // Ajoutez autant d'annonces que nécessaire
    ];

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: advertisements.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () {
                // Action à effectuer lorsque l'utilisateur clique sur une publicité
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.asset(
                        advertisements[index].imageUrl,
                        width: 200,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            advertisements[index].title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            advertisements[index].description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
