import 'package:flutter/material.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/widgets/dashbord/dashbord.dart';

class HousingDetailPage extends StatefulWidget {
  final String imageUrl;
  final List<String> imageUrls;
  final String title;
  final String location;
  final String price;
  final String description;
  final List<String> amenities;
  final int numRooms; // Nombre de pièces
  final bool hasGarage; // Indicateur de garage
  final bool hasTerrace; // Indicateur de terrasse
  final double latitude;
  final double longitude;
  final bool saleOrRent; // Vente ou location

  const HousingDetailPage({
    required this.imageUrl,
    required this.imageUrls,
    required this.title,
    required this.location,
    required this.price,
    required this.description,
    required this.amenities,
    required this.numRooms,
    required this.hasGarage,
    required this.hasTerrace,
    required this.latitude,
    required this.longitude,
    required this.saleOrRent, // Ajout de la variable saleOrRent
    super.key,
  });

  @override
  State<HousingDetailPage> createState() => _HousingDetailPageState();
}

class _HousingDetailPageState extends State<HousingDetailPage> {
  bool _isFavorite = false; // État de l'élément dans les favoris

  late List<String> allImageUrls; // Liste d'URL d'images incluant imageUrl

  @override
  void initState() {
    super.initState();
    allImageUrls = [widget.imageUrl, ...widget.imageUrls];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const CustomTitle(
          textColor: Colors.white,
          text: "Details",
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: primary,
      ),
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
            ImageCarousel(
              imageUrls: allImageUrls,
              
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconButton(
                    icon: Icons.location_on,
                    onPressed: () {},
                    tooltip: 'Localisation',
                  ),
                  _buildIconButton(
                    isliked: _isFavorite,
                    icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                    tooltip: 'J\'aime',
                  ),
                  _buildIconButton(
                    icon: Icons.share,
                    onPressed: () {},
                    tooltip: 'Partager',
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20, // Augmentation de la taille du texte
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.location,
                    style: const TextStyle(
                      fontSize: 18, // Augmentation de la taille du texte
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.price,
                    style: const TextStyle(
                      fontSize: 20, // Augmentation de la taille du texte
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Détails',
                    style: TextStyle(
                      fontSize: 18, // Augmentation de la taille du texte
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 8.0,
                    children: [
                      _buildDetailItem(
                          Icons.king_bed, '${widget.numRooms} pièces'),
                      _buildDetailItem(Icons.local_parking,
                          widget.hasGarage ? 'Garage' : 'Pas de garage'),
                      _buildDetailItem(Icons.terrain,
                          widget.hasTerrace ? 'Terrasse' : 'Pas de terrasse'),
                      _buildDetailItem(Icons.home,
                          widget.saleOrRent ? 'À vendre' : 'À louer'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18, // Augmentation de la taille du texte
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
                  const SizedBox(height: 10),
                  const Text(
                    'Équipements',
                    style: TextStyle(
                      fontSize: 18, // Augmentation de la taille du texte
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.amenities
                        .map(
                          (amenity) => _buildAmenityCard(amenity),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
      {required IconData icon,
      required VoidCallback onPressed,
      required String tooltip,
      bool isliked = false}) {
    return IconButton(
      icon: Icon(icon, size: 30, color: isliked ? Colors.red : primary),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: primary),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildAmenityCard(String amenity) {
    return Card(
      color: lightPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, color: primary),
            const SizedBox(width: 8),
            Text(
              amenity,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
