import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// Télécharge l'image et la sauvegarde localement
Future<String?> downloadAndSaveImage(String url, String fileName) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath; // Retourne le chemin local de l'image
    } else {
      print("Erreur lors du téléchargement de l'image");
      return null;
    }
  } catch (e) {
    print("Erreur lors du téléchargement de l'image : $e");
    return null;
  }
}
