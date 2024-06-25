import 'package:flutter/material.dart';
import 'package:habitatgn/screens/seach/seach_screen.dart';
import 'package:habitatgn/utils/appColors.dart';

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

// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       appBar: CustomAppBar(
//         title: 'Ma Page',
//         leadingIcon: Icons.arrow_back_ios_outlined,
//       ),
//       body: Center(
//         child: Text('Contenu de la page'),
//       ),
//     ),
//   ));
// }
