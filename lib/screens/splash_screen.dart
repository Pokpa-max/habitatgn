import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitatgn/viewmodels/splashScreen/splashscreen_provider.dart';
import 'package:habitatgn/utils/appcolors.dart'; // Assurez-vous d'importer vos couleurs personnalisées ici

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final SplashScreenViewModel _splashScreenViewModel;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward().whenComplete(() {
        // Appeler checkLoggedIn après l'animation
        _splashScreenViewModel.checkLoggedIn(context);
      });

    _splashScreenViewModel = ref.read(splashScreenViewModelProvider);
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
                width: 300,
                height: 300,
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [primary, primary],
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
