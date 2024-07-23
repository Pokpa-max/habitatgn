import 'package:flutter/material.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:intl/intl.dart';

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

Widget houseCategoryListEmpty({String title = 'Aucun logement disponible'}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.home_outlined,
          size: 100,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Veuillez vérifier ultérieurement',
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

  const FormattedPrice(
      {super.key,
      required this.price,
      this.suffix = '',
      this.color = primaryColor});

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
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class SeparatedText extends StatelessWidget {
  final String text;
  final TextStyle? firstLetterStyle;
  final TextStyle? restOfTextStyle;
  final double spaceBetween;

  const SeparatedText({
    super.key,
    required this.text,
    this.firstLetterStyle,
    this.restOfTextStyle,
    this.spaceBetween = 4.0, // Espace par défaut de 4.0
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const Text('');

    String firstLetter = text[0];
    String restOfText = text.substring(1);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: firstLetter,
            style: firstLetterStyle ?? DefaultTextStyle.of(context).style,
          ),
          WidgetSpan(
            child: SizedBox(width: spaceBetween),
          ),
          TextSpan(
            text: restOfText,
            style: restOfTextStyle ?? DefaultTextStyle.of(context).style,
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    // Définir les valeurs par défaut
    const double defaultWidth = 150;
    const double defaultHeight = 140;

    return CachedNetworkImage(
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
        child: const Center(
          child: Icon(
            Icons.error,
            color: Colors.red,
            size: 40,
          ),
        ),
      ),
    );
  }
}



 // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const HomeScreen(),
                      //   ),
                      //   (route) => false, // Supprime toutes les autres routes
                      // );