import 'package:flutter/material.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FavoriteItem> favoriteItems = [
      FavoriteItem(
        imageUrl: 'assets/images/maison.jpg',
        title: ' Apartment',
        location: 'Paris, France',
        commune: 'Ratoma',
        quartier: 'Lambanyi',
        numRooms: 2,
        isForSale: true,
        price: 3000000,
      ),
      FavoriteItem(
        imageUrl: 'assets/images/maison.jpg',
        title: 'Cozy House',
        location: 'Lyon, France',
        commune: 'Ratoma',
        quartier: 'Lambanyi',
        numRooms: 2,
        isForSale: false,
        price: 1000000,
      ),
    ];

    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: AppBar(
        centerTitle: true,
        title: const CustomTitle(
          text: "Mes coups de cœur",
          textColor: Colors.white,
        ),
        backgroundColor: primary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Card(
                    color: backgroundColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HousingDetailPage(
                              saleOrRent: item.isForSale,
                              hasTerrace: true,
                              hasGarage: true,
                              numRooms: item.numRooms,
                              imageUrl: item.imageUrl,
                              imageUrls: const [
                                'assets/images/maison2.jpg',
                                'assets/images/logo.png',
                              ],
                              title: item.title,
                              location: item.location,
                              price: '${item.price.toString()} GN/mois',
                              description:
                                  'Un magnifique appartement situé au cœur de ${item.location} avec une vue imprenable. Comprend ${item.numRooms} chambres, ${item.quartier}, et une cuisine entièrement équipée.',
                              amenities: const [
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            child: Image.asset(
                              item.imageUrl,
                              width: 150,
                              height: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: item.isForSale
                                              ? Colors.green
                                              : Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          item.isForSale
                                              ? "À vendre"
                                              : "Location",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.location_pin,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.commune}, ${item.quartier}',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.home,
                                            size: 18, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item.numRooms} pièces',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.favorite,
                                          color: Colors.red),
                                      onPressed: () {
                                        // Ajouter ici la logique pour supprimer l'élément des favoris
                                      },
                                    )
                                  ],
                                ),
                                Text(
                                  '${item.price.toString()} GN/mois',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
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
          ),
        ],
      ),
    );
  }
}

class FavoriteItem {
  final String imageUrl;
  final String title;
  final String location;
  final String commune;
  final int numRooms;
  final String quartier;
  final double price;
  final bool isForSale;

  FavoriteItem({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.commune,
    required this.numRooms,
    required this.quartier,
    required this.price,
    required this.isForSale,
  });
}
