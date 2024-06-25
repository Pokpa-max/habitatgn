import 'package:flutter/material.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/utils/appColors.dart';

Widget seachResult({results}) {
  return ListView.builder(
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
                  builder: (context) => const HousingDetailPage(
                    saleOrRent: false,
                    hasTerrace: true,
                    hasGarage: true,
                    numRooms: 3,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  child: Image.asset(
                    house.imageUrl,
                    width: 150,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            house.type,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                house.location,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_city,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                house.commune,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_pin,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                house.quartier,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.home,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${house.numRooms} pièces',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          '${house.price.toString()} GN',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: primary),
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
  );
}
