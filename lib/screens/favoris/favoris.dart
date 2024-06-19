import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  final List<FavoriteItem> favoriteItems;

  const FavoritesPage({required this.favoriteItems, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        backgroundColor: Colors.cyan,
      ),
      body: ListView.builder(
        itemCount: favoriteItems.length,
        itemBuilder: (context, index) {
          final item = favoriteItems[index];
          return FavoriteCard(
            imageUrl: item.imageUrl,
            title: item.title,
            location: item.location,
            onRemove: () {
              // Ajoutez une logique pour supprimer l'élément des favoris
            },
          );
        },
      ),
    );
  }
}

class FavoriteItem {
  final String imageUrl;
  final String title;
  final String location;

  FavoriteItem({
    required this.imageUrl,
    required this.title,
    required this.location,
  });
}

class FavoriteCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final VoidCallback onRemove;

  const FavoriteCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Image.network(
            imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(location),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FavoritesPage(
      favoriteItems: [
        FavoriteItem(
          imageUrl: 'https://via.placeholder.com/150',
          title: 'Luxurious Apartment',
          location: 'Paris, France',
        ),
        FavoriteItem(
          imageUrl: 'https://via.placeholder.com/150',
          title: 'Cozy House',
          location: 'Lyon, France',
        ),
        FavoriteItem(
          imageUrl: 'https://via.placeholder.com/150',
          title: 'Modern Villa',
          location: 'Nice, France',
        ),
      ],
    ),
  ));
}
