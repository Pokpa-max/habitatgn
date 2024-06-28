import 'package:habitatgn/models/house_result_model.dart';

class HouseService {
  Future<List<House>> getHousesByCategory(String category) async {
    // Simuler un délai de chargement
    await Future.delayed(const Duration(seconds: 1));

    // Retourner une liste simulée de maisons pour chaque catégorie
    switch (category) {
      case 'Villas':
        return [
          House(
            type: 'Villa',
            location: 'Paris',
            commune: 'Commune1',
            quartier: 'Quartier1',
            price: 3000,
            imageUrl: 'assets/images/maison.jpg',
            numRooms: 3,
          ),
          // Ajouter d'autres maisons ici
        ];
      case 'Maisons':
        return [
          House(
            type: 'Maison',
            location: 'Lyon',
            commune: 'Commune2',
            quartier: 'Quartier2',
            price: 2500,
            imageUrl: 'assets/images/maison2.jpg',
            numRooms: 4,
          ),
          // Ajouter d'autres maisons ici
        ];
      // Ajouter d'autres catégories ici
      default:
        return [];
    }
  }
}
