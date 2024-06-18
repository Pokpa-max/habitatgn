// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:habitatgn/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _animationController.drive(
                    CurveTween(curve: Curves.easeOutBack),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 250,
                    height: 250,
                    // fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: TopRoundedClipper(),
              child: Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 60);
    path.quadraticBezierTo(size.width / 2, 0, size.width, 60);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
