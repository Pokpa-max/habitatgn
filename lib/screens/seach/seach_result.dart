// import 'package:flutter/material.dart';
// import 'package:habitatgn/models/house_result_model.dart';
// import 'package:habitatgn/screens/house/house_detail_screen.dart';
// import 'package:habitatgn/utils/appColors.dart';
// import 'package:habitatgn/utils/ui_element.dart';

// class SearchResultPage extends StatelessWidget {
//   final List<House> results;

//   // ignore: use_super_parameters
//   const SearchResultPage({Key? key, required this.results}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const CustomTitle(
//           text: "Résultats de la recherche",
//         ),
//         iconTheme: const IconThemeData(color: primary),
//       ),
//       body: ListView.builder(
//         itemCount: results.length,
//         itemBuilder: (context, index) {
//           House house = results[index];
//           return Padding(
//             padding: const EdgeInsets.all(5.0),
//             child: Card(
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: InkWell(
//                 onTap: () {
//                   // Gérer l'action lorsque l'utilisateur clique sur un résultat
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const HousingDetailPage(
//                         imageUrl: 'assets/images/maison.jpg',
//                         imageUrls: [
//                           'assets/images/maison2.jpg',
//                           'assets/images/logo.png',
//                         ],
//                         title: 'Luxurious Apartment',
//                         location: 'Paris, France',
//                         price: '€2,000 / mois',
//                         description:
//                             'Un magnifique appartement situé au cœur de Paris avec une vue imprenable sur la Tour Eiffel. Comprend 2 chambres, 2 salles de bains, un grand salon et une cuisine entièrement équipée.',
//                         amenities: [
//                           'Wi-Fi gratuit',
//                           'Cuisine équipée',
//                           'Piscine',
//                           'Salle de gym',
//                           'Parking gratuit',
//                         ],
//                         latitude: 48.8588443,
//                         longitude: 2.2943506,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(12),
//                         bottomLeft: Radius.circular(12),
//                       ),
//                       child: Image.asset(
//                         house.imageUrl,
//                         width: 120,
//                         height: 120,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 house.type,
//                                 style: const TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.location_on,
//                                       size: 18, color: Colors.grey),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     house.location,
//                                     style: const TextStyle(fontSize: 14),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.location_city,
//                                       size: 18, color: Colors.grey),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     house.commune,
//                                     style: const TextStyle(fontSize: 14),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.location_pin,
//                                       size: 18, color: Colors.grey),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     house.quartier,
//                                     style: const TextStyle(fontSize: 14),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Text(
//                               '${house.price.toString()} GN',
//                               style: const TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.bold,
//                                   color: primary),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:habitatgn/models/house_result_model.dart';
import 'package:habitatgn/screens/house/house_detail_screen.dart';
import 'package:habitatgn/utils/appColors.dart';
import 'package:habitatgn/utils/ui_element.dart';

class SearchResultPage extends StatelessWidget {
  final List<House> results;

  const SearchResultPage({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomTitle(
          text: "Résultats de la recherche",
        ),
        iconTheme: const IconThemeData(color: primary),
      ),
      body: ListView.builder(
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
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Image.asset(
                        house.imageUrl,
                        width: 120,
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
      ),
    );
  }
}
