import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;

  const CustomTitle({
    super.key,
    required this.text,
    this.fontSize = 20.0,
    this.textColor = primary,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize, color: textColor, fontWeight: FontWeight.w700),
    );
  }
}

class CustomSubTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;

  const CustomSubTitle({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.textColor = primary,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
      ),
    );
  }
}

Widget buildSearchField(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextField(
      decoration: const InputDecoration(
        hintText: 'Rechercher un logement...',
        prefixIcon: Icon(
          Icons.search,
          color: primary,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 14.0),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SearchPage(),
          ),
        );
      },
    ),
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_outlined),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

Widget houseCategoryListEmpty(
    {String title = 'Aucun logement disponible',
    subtitle = 'Veuillez vérifier ultérieurement'}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.home_outlined,
          size: 80,
          color: Colors.grey[400],
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// Définissez votre couleur primaire
const Color primary = Colors.blue;

class FormattedPrice extends StatelessWidget {
  final double price;
  final String suffix;
  final Color color;
  final double size;

  const FormattedPrice(
      {super.key,
      required this.price,
      this.suffix = '',
      this.color = primaryColor,
      this.size = 16});

  @override
  Widget build(BuildContext context) {
    // Formater le prix en GNF
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'fr_GN', // Vous pouvez ajuster la locale ici
      symbol: 'GNF', // Symbole monétaire
      decimalDigits: 0, // Pas de décimales pour les devises en GNF
    );

    String formattedPrice = currencyFormatter.format(price);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        '$formattedPrice $suffix',
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class CustomCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;

  const CustomCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
  });

  // Gestionnaire de cache partagé pour toute l'application
  static final customCacheManager = CacheManager(
    Config(
      'customImageCache',
      stalePeriod: const Duration(days: 30), // Augmenté à 30 jours
      maxNrOfCacheObjects: 200, // Plus d'objets en cache
      repo: JsonCacheInfoRepository(databaseName: 'customImageCache'),
      fileService: HttpFileService(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    const double defaultWidth = 150;
    const double defaultHeight = 140;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8), // Ajout de coins arrondis
      child: CachedNetworkImage(
        cacheManager: customCacheManager,
        imageUrl: imageUrl,
        width: width ?? defaultWidth,
        height: height ?? defaultHeight,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: width ?? defaultWidth,
            height: height ?? defaultHeight,
            color: Colors.grey[300],
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: width ?? defaultWidth,
          height: height ?? defaultHeight,
          color: Colors.grey.shade200,
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey.shade400,
            size: 40,
          ),
        ),
      ),
    );
  }
}

void showToast(context, String message, Color backgroundColor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

void showError(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red[600],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Future<bool> checkConnectivity(BuildContext context) async {
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    showError('Connexion Internet indisponible', context);
    return false;
  }
  return true;
}

Future<void> makePhoneCall(String phoneNumber, context) async {
  if (!await checkConnectivity(context)) return;
  if (phoneNumber == null) {
    showError('Numéro de téléphone non disponible', context);
    return;
  }

  await launchPhoneCall("tel:$phoneNumber");
}

Future<void> launchPhoneCall(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}
