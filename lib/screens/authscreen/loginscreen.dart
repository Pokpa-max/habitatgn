import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:habitatgn/screens/authscreen/create_account.dart';
import 'package:habitatgn/screens/forgot_password/forgotPasswordScreen.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.read(authViewModelProvider);
    final isLoading =
        ref.watch(authViewModelProvider.select((value) => value.isLoading));
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    return Scaffold(
      body: Container(
        color: primaryColor,
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                    width: 100,
                    height: 100,
                    child: HousingSearchIcon(
                      size: 48.0,
                      color: lightPrimary,
                    )),
                const SizedBox(height: 20),
                Text(
                  "HABITATGN",
                  style: TextStyle(
                    color: Colors.yellow[700],
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Explorez,Découvrez,Vivez",
                  style: TextStyle(
                    color: Colors.teal[100],
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: emailController,
                          hintText: 'Email',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: passwordController,
                          hintText: 'Mot de passe',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isVisible: isPasswordVisible,
                          onVisibilityToggle: () {
                            ref
                                .read(passwordVisibilityProvider.notifier)
                                .toggleVisibility();
                          },
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgotUserPasswordScreen()),
                                    );
                                  },
                            child: const Text(
                              'Mot de passe oublié?',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildElevatedButton(
                          borderColor: Colors.transparent,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  // Vérification de la connectivité
                                  final connectivityResult =
                                      await Connectivity().checkConnectivity();
                                  if (connectivityResult ==
                                      ConnectivityResult.none) {
                                    authViewModel.showErrorMessage(
                                      context,
                                      "Pas de connexion Internet. Veuillez vérifier votre connexion.",
                                    );
                                    return;
                                  }

                                  // Validation des champs
                                  if (emailController.text.isEmpty ||
                                      passwordController.text.isEmpty) {
                                    authViewModel.showErrorMessage(
                                      color: primaryColor,
                                      context,
                                      "Veuillez remplir tous les champs.",
                                    );
                                    return;
                                  }

                                  // Validation de l'email
                                  if (!_isValidEmail(emailController.text)) {
                                    authViewModel.showErrorMessage(
                                      context,
                                      "Veuillez entrer une adresse email valide.",
                                    );
                                    return;
                                  }

                                  // Tentative de connexion
                                  await authViewModel
                                      .signInWithEmailAndPassword(
                                    context,
                                    emailController.text,
                                    passwordController.text,
                                  );
                                },
                          label: isLoading
                              ? const SpinKitFadingCircle(
                                  color: primaryColor,
                                  size: 30.0,
                                )
                              : const Text(
                                  'Se connecter',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                          backgroundColor: primaryColor,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Ou connectez-vous avec",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 20),
                        _buildElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  authViewModel
                                      .navigateToCreateAccount(context);
                                },
                          label: const Text(
                            "Creer un Compte",
                            style: TextStyle(fontSize: 16, color: primaryColor),
                          ),
                          backgroundColor: lightPrimary,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(
                              icon: const Icon(Icons.facebook,
                                  color: Colors.white),
                              color: Colors.blue[700]!,
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      try {
                                        final connectivityResult =
                                            await Connectivity()
                                                .checkConnectivity();
                                        if (connectivityResult ==
                                            ConnectivityResult.none) {
                                          authViewModel.showErrorMessage(
                                            context,
                                            "Pas de connexion Internet. Veuillez vérifier votre connexion.",
                                          );
                                          return;
                                        }
                                        await authViewModel
                                            .signInWithFacebook(context);
                                      } catch (e) {
                                        print(
                                            'Erreur de connexion Facebook: $e');
                                      }
                                    },
                            ),
                            const SizedBox(width: 20),
                            _buildSocialButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.google,
                                color: Colors.white,
                              ),
                              color: Colors.red[600]!,
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      try {
                                        final connectivityResult =
                                            await Connectivity()
                                                .checkConnectivity();
                                        if (connectivityResult ==
                                            ConnectivityResult.none) {
                                          authViewModel.showErrorMessage(
                                            context,
                                            "Pas de connexion Internet. Veuillez vérifier votre connexion.",
                                          );
                                          return;
                                        }
                                        await authViewModel
                                            .signInWithGoogle(context);
                                      } catch (e) {
                                        print('Erreur de connexion Google: $e');
                                      }
                                    },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  bool isPassword = false,
  bool isVisible = true,
  VoidCallback? onVisibilityToggle,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(30),
    ),
    child: TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    ),
  );
}

Widget _buildElevatedButton({
  required VoidCallback? onPressed,
  required Widget label,
  required Color backgroundColor,
  Color borderColor = primaryColor,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
      minimumSize: const Size(double.infinity, 0),
    ),
    child: label,
  );
}

Widget _buildSocialButton({
  required Widget icon,
  required Color color,
  required VoidCallback? onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(15),
    ),
    child: icon,
  );
}

class HousingSearchIcon extends StatelessWidget {
  final double size;
  final Color color;

  const HousingSearchIcon({
    super.key,
    this.size = 24.0,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HousingSearchIconPainter(color: color),
      ),
    );
  }
}

class _HousingSearchIconPainter extends CustomPainter {
  final Color color;

  _HousingSearchIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 12;

    // Dessiner la maison
    final Path housePath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..close();

    canvas.drawPath(housePath, paint);

    // Dessiner la loupe
    final double magnifierCenter = size.width * 0.7;
    final double magnifierRadius = size.width * 0.2;
    canvas.drawCircle(
      Offset(magnifierCenter, magnifierCenter),
      magnifierRadius,
      paint,
    );

    // Dessiner le manche de la loupe
    canvas.drawLine(
      Offset(magnifierCenter + magnifierRadius * 0.7,
          magnifierCenter + magnifierRadius * 0.7),
      Offset(size.width * 0.95, size.height * 0.95),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
