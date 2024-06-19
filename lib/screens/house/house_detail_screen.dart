import 'package:flutter/material.dart';
import 'package:habitatgn/widgets/dashbord/dashbord.dart';

class HousingDetailPage extends StatefulWidget {
  final String imageUrl;
  final List<String> imageUrls;
  final String title;
  final String location;
  final String price;
  final String description;
  final List<String> amenities;
  final double latitude;
  final double longitude;

  const HousingDetailPage({
    required this.imageUrl,
    required this.imageUrls,
    required this.title,
    required this.location,
    required this.price,
    required this.description,
    required this.amenities,
    required this.latitude,
    required this.longitude,
    super.key,
  });

  @override
  State<HousingDetailPage> createState() => _HousingDetailPageState();
}

class _HousingDetailPageState extends State<HousingDetailPage> {
  bool _isFavorite = false; // État de l'élément dans les favoris
  // dynamic imageData = imageUrls.insert(0, widget.imageUrl);

  @override
  Widget build(BuildContext context) {
    // widget.imageUrls.insert(0, widget.imageUrl);
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   toolbarHeight: 500,
      //   flexibleSpace: ImageCarousel(
      //     imageUrls: widget.imageUrls,
      //   ),
      // ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Ajouter la logique pour contacter le propriétaire
        },
        icon: const Icon(
          Icons.phone,
          color: Colors.white,
        ),
        label: const Text(
          'Appeler',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ImageCarousel(
                  imageUrls: widget.imageUrls,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.cyan,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.location_on,
                    color: Colors.cyan,
                  ),
                  label: const Text(
                    'Localisation',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share,
                    color: Colors.cyan,
                  ),
                  label: const Text(
                    'Partager',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Action pour aimer
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.cyan,
                    size: 35,
                  ),
                  label: const Text(
                    'J\'aime',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.location,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Équipements',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: widget.amenities
                        .map(
                          (amenity) => Row(
                            children: [
                              const Icon(Icons.check, color: Colors.cyan),
                              const SizedBox(width: 10),
                              Text(
                                amenity,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        // Ajoutez ici la logique pour ajouter/retirer des favoris
      },
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : Colors.cyan,
        size: 35,
      ),
    );
  }

  Widget _buildGoogleMapButton() {
    return IconButton(
      onPressed: () {},
      icon: const Icon(
        Icons.location_on,
        color: Colors.cyan,
        size: 35,
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// class HousingDetailPage extends StatelessWidget {
//   final String imageUrl;
//   final List<String> imageUrls;
//   final String title;
//   final String location;
//   final String price;
//   final String description;
//   final List<String> amenities;

//   const HousingDetailPage({
//     super.key,
//     required this.imageUrl,
//     required this.imageUrls,
//     required this.title,
//     required this.location,
//     required this.price,
//     required this.description,
//     required this.amenities,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text(
//       //     'Détail du Logement',
//       //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//       //   ),
//       //   backgroundColor: Colors.cyan,
//       // ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AspectRatio(
//               aspectRatio: 16 / 8,
//               child: PageView.builder(
//                 itemCount: imageUrls.length,
//                 itemBuilder: (context, index) {
//                   return Image.asset(
//                     imageUrls[index],
//                     fit: BoxFit.cover,
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               title,
//               style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),
//             Row(
//               children: [
//                 Icon(Icons.location_on, color: Colors.grey),
//                 SizedBox(width: 8.0),
//                 Text(location),
//               ],
//             ),
//             SizedBox(height: 8.0),
//             Row(
//               children: [
//                 Icon(Icons.attach_money, color: Colors.grey),
//                 SizedBox(width: 8.0),
//                 Text(price),
//               ],
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               'Description',
//               style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),
//             Text(description),
//             SizedBox(height: 16.0),
//             Text(
//               'Équipements',
//               style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.0),
//             Wrap(
//               spacing: 8.0,
//               children: amenities
//                   .map(
//                     (amenity) => Chip(
//                       label: Text(amenity),
//                     ),
//                   )
//                   .toList(),
//             ),
//             SizedBox(height: 16.0),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // Action pour localisation
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Localisation en cours...'),
//                       ),
//                     );
//                   },
//                   icon: Icon(Icons.location_on),
//                   label: Text('Localisation'),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // Action pour sauvegarder
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Sauvegardé avec succès'),
//                       ),
//                     );
//                   },
//                   icon: Icon(Icons.bookmark),
//                   label: Text('Sauvegarder'),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     // Action pour aimer
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Ajouté aux favoris'),
//                       ),
//                     );
//                   },
//                   icon: Icon(Icons.favorite),
//                   label: Text('J\'aime'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
