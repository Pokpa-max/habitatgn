import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:habitatgn/viewmodels/splashScreen/splashscreen_provider.dart';
import 'package:habitatgn/utils/appcolors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
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
      backgroundColor: lightPrimary,
      body: Stack(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "HABITATGN",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Votre Chez-Vous Idéal de Logement",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              SpinKitWave(
                color: primaryColor,
                size: 50.0,
                duration: Duration(seconds: 4),
              ),
            ],
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
                    colors: [primaryColor, primaryColor],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Explorez • Découvrez • Vivez",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black26,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
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

class HousingSearchIcon extends StatelessWidget {
  final double size;
  final Color color;

  const HousingSearchIcon({
    super.key,
    this.size = 25.0,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HousingSearchIconPainter(
            mainColor: color, toolColor: Colors.yellow[700]!),
      ),
    );
  }
}

class _HousingSearchIconPainter extends CustomPainter {
  final Color mainColor;
  final Color toolColor;

  _HousingSearchIconPainter({
    required this.mainColor,
    this.toolColor = Colors.yellow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint mainPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 20;

    final Paint toolPaint = Paint()
      ..color = toolColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 20;

    // Dessiner la maison
    final Path housePath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..close();
    canvas.drawPath(housePath, mainPaint);

    // Dessiner la loupe
    final double magnifierCenter = size.width * 0.7;
    final double magnifierRadius = size.width * 0.2;
    canvas.drawCircle(
      Offset(magnifierCenter, magnifierCenter),
      magnifierRadius,
      mainPaint,
    );

    // Dessiner le manche de la loupe
    canvas.drawLine(
      Offset(magnifierCenter + magnifierRadius * 0.7,
          magnifierCenter + magnifierRadius * 0.7),
      Offset(size.width * 0.95, size.height * 0.95),
      mainPaint,
    );

    // Dessiner l'outil de réparation (marteau) en jaune
    final double toolStartX = size.width * 0.25;
    final double toolStartY = size.height * 0.85;

    // Manche du marteau
    canvas.drawLine(
      Offset(toolStartX, toolStartY),
      Offset(toolStartX, toolStartY - size.height * 0.08),
      toolPaint,
    );

    // Tête du marteau
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(toolStartX, toolStartY - size.height * 0.1),
        width: size.width * 0.08,
        height: size.height * 0.04,
      ),
      toolPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
