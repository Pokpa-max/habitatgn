import 'package:flutter/material.dart';
import 'package:habitatgn/utils/appColors.dart';

class CustomTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;

  const CustomTitle({
    super.key,
    required this.text,
    this.fontSize = 18.0,
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
