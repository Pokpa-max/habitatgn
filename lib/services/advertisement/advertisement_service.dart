import 'dart:async';

class AdvertisementService {
  Future<Map<String, List<String>>> fetchAdvertisementData() async {
    // Simuler une récupération de données avec un délai
    await Future.delayed(const Duration(seconds: 2));

    // Données simulées
    List<String> imageUrls = [
      'assets/images/maison.jpg',
      'assets/images/maison2.jpg',
      'assets/images/maison.jpg',
    ];
    List<String> subtitles = ['Subtitle 1', 'Subtitle 2', 'Subtitle 3'];

    return {
      'imageUrls': imageUrls,
      'subtitles': subtitles,
    };
  }
}
