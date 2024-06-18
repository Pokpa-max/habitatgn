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
                Positioned(
                  top: 225,
                  left: 400,
                  child: Row(
                    children: [
                      _buildFavoriteButton(),
                      _buildGoogleMapButton(),
                    ],
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
