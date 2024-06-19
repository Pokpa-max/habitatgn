import 'package:flutter/material.dart';
import 'package:habitatgn/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const SplashScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward().whenComplete(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
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
            child: ScaleTransition(
              scale: _animationController.drive(
                CurveTween(curve: Curves.easeOutBack),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: TopRoundedClipper(),
              child: Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                color: Colors.cyan,
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
    final path = Path();
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
