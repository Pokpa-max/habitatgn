import 'package:flutter/material.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/utils/appColors.dart';
import 'package:habitatgn/utils/ui_element.dart';

class HouselistScreen extends StatelessWidget {
  final List<House> results;
  final String title;
  final Function onTap;
  final IconData iconData;
  final bool isForSale;

  const HouselistScreen({
    super.key,
    required this.results,
    required this.title,
    required this.iconData,
    required this.isForSale,
    required this.onTap,
  });

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons
              .arrow_back_ios_outlined), // Ici, vous pouvez utiliser n'importe quelle icône
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTitle(text: title, textColor: Colors.white),
            const SizedBox(width: 10),
            Icon(
              iconData,
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                House house = results[index];
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Card(
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
                              saleOrRent: isForSale,
                              hasTerrace: true,
                              hasGarage: true,
                              numRooms: 3,
                              imageUrl: 'assets/images/maison.jpg',
                              imageUrls: const [
                                'assets/images/maison2.jpg',
                                'assets/images/logo.png',
                              ],
                              title: 'Luxurious Apartment',
                              location: 'Paris, France',
                              price: '€2,000 / mois',
                              description:
                                  'Un magnifique appartement situé au cœur de Paris avec une vue imprenable sur la Tour Eiffel. Comprend 2 chambres, 2 salles de bains, un grand salon et une cuisine entièrement équipée.',
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
                          Image.asset(
                            house.imageUrl,
                            width: 150,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      house.type,
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
                                          color: isForSale
                                              ? Colors.green
                                              : Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isForSale ? "À vendre" : "Location",
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
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      house.location,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    // ignore: prefer_const_constructors
                                    Icon(Icons.home,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${house.numRooms} pièces',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    '${house.price.toString()} GN/mois',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: performSearch,
        label: const Text(
          'Recherche',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.search, color: Colors.white),
        backgroundColor: primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
