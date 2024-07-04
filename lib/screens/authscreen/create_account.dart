// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:habitatgn/screens/home/dashbord/dashbord.dart';
// import 'package:habitatgn/utils/appcolors.dart';
// import 'package:habitatgn/utils/ui_element.dart';
// import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';

// class CreateAccountPage extends ConsumerWidget {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController =
//       TextEditingController();

//   CreateAccountPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authProvider = ref.watch(authViewModelProvider);
//     final isPasswordVisible = ref.watch(passwordVisibilityProvider);
//     final isConfirmPasswordVisible =
//         ref.watch(confirmPasswordVisibilityProvider);

//     return Scaffold(
//       backgroundColor: lightPrimary,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_outlined),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         centerTitle: true,
//         backgroundColor: primary,
//         title:
//             const CustomTitle(text: "Créer un compte", textColor: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               const SizedBox(
//                 height: 20,
//               ),
//               TextField(
//                 controller: nameController,
//                 cursorColor: primary,
//                 keyboardType: TextInputType.name,
//                 decoration: InputDecoration(
//                   labelText: 'Nom *',
//                   labelStyle: const TextStyle(color: Colors.black),
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     borderSide: const BorderSide(
//                         color: Colors.white), // Couleur du contour en gris
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     borderSide: const BorderSide(
//                         color: Colors
//                             .white), // Couleur du contour en gris quand le champ est focusé
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: emailController,
//                 cursorColor: primary,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: 'Email *',
//                   labelStyle: const TextStyle(color: Colors.black),
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     borderSide: const BorderSide(
//                         color: Colors.white), // Couleur du contour en gris
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     borderSide: const BorderSide(
//                         color: Colors
//                             .white), // Couleur du contour en gris quand le champ est focusé
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: phoneController,
//                 cursorColor: primary,
//                 decoration: InputDecoration(
//                   labelText: 'Numéro de téléphone',
//                   labelStyle: const TextStyle(color: Colors.black),
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     borderSide: const BorderSide(
//                         color: Colors.white), // Couleur du contour en gris
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     borderSide: const BorderSide(
//                         color: Colors
//                             .white), // Couleur du contour en gris quand le champ est focusé
//                   ),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: passwordController,
//                 cursorColor: primary,
//                 decoration: InputDecoration(
//                   labelText: 'Mot de passe *',
//                   labelStyle: const TextStyle(color: Colors.black),
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     borderSide: const BorderSide(
//                         color: Colors.white), // Couleur du contour en gris
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     borderSide: const BorderSide(
//                         color: Colors
//                             .white), // Couleur du contour en gris quand le champ est focusé
//                   ),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       isPasswordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () {
//                       ref
//                           .read(passwordVisibilityProvider.notifier)
//                           .toggleVisibility();
//                     },
//                   ),
//                 ),
//                 obscureText: !isPasswordVisible,
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: confirmPasswordController,
//                 cursorColor: primary,
//                 decoration: InputDecoration(
//                   labelText: 'Confirmer le mot de passe *',
//                   labelStyle: const TextStyle(color: Colors.black),
//                   filled: true,
//                   fillColor: Colors.white,
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     borderSide: const BorderSide(
//                         color: Colors.white), // Couleur du contour en gris
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     borderSide: const BorderSide(
//                         color: Colors
//                             .white), // Couleur du contour en gris quand le champ est focusé
//                   ),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       isConfirmPasswordVisible
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () {
//                       ref
//                           .read(confirmPasswordVisibilityProvider.notifier)
//                           .toggleVisibility();
//                     },
//                   ),
//                 ),
//                 obscureText: !isConfirmPasswordVisible,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 style: ButtonStyle(
//                   backgroundColor: WidgetStateProperty.all(
//                       authProvider.isCreatingAccount
//                           ? Colors.grey[300]
//                           : primary),
//                 ),
//                 onPressed: authProvider.isCreatingAccount
//                     ? null
//                     : () async {
//                         // Vérification si les mots de passe correspondent
//                         if (passwordController.text !=
//                             confirmPasswordController.text) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text(
//                                   'Les mots de passe ne correspondent pas.'),
//                             ),
//                           );
//                           return;
//                         }

//                         // Vérification des champs obligatoires
//                         if (nameController.text.isEmpty ||
//                             emailController.text.isEmpty ||
//                             passwordController.text.isEmpty ||
//                             confirmPasswordController.text.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text(
//                                   'Veuillez remplir tous les champs obligatoires marqués avec *.'),
//                             ),
//                           );
//                           return;
//                         }

//                         await authProvider.createUserWithEmailAndPassword(
//                           context,
//                           emailController.text,
//                           passwordController.text,
//                           nameController.text,
//                           phoneController.text,
//                         );
//                       },
//                 child: authProvider.isCreatingAccount
//                     ? const SpinKitFadingCircle(
//                         color: primary,
//                         size: 40.0,
//                       )
//                     : const Text(
//                         'Créer le compte',
//                         style: TextStyle(color: Colors.white),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:habitatgn/screens/home/dashbord/dashbord.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:habitatgn/viewmodels/auth_provider/auth_provider.dart';

class CreateAccountPage extends ConsumerWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController referenceCodeController =
      TextEditingController(); // Nouveau contrôleur pour le code de référence
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  CreateAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authProvider = ref.watch(authViewModelProvider);
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    final isConfirmPasswordVisible =
        ref.watch(confirmPasswordVisibilityProvider);

    return Scaffold(
      backgroundColor: lightPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: primary,
        title:
            const CustomTitle(text: "Créer un compte", textColor: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                cursorColor: primary,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                cursorColor: primary,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                cursorColor: primary,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller:
                    referenceCodeController, // Nouveau champ pour le code de référence
                cursorColor: primary,
                decoration: InputDecoration(
                  labelText: 'Code de référence',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                cursorColor: primary,
                decoration: InputDecoration(
                  labelText: 'Mot de passe *',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      ref
                          .read(passwordVisibilityProvider.notifier)
                          .toggleVisibility();
                    },
                  ),
                ),
                obscureText: !isPasswordVisible,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                cursorColor: primary,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe *',
                  labelStyle: const TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      ref
                          .read(confirmPasswordVisibilityProvider.notifier)
                          .toggleVisibility();
                    },
                  ),
                ),
                obscureText: !isConfirmPasswordVisible,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      authProvider.isCreatingAccount
                          ? Colors.grey[300]
                          : primary),
                ),
                onPressed: authProvider.isCreatingAccount
                    ? null
                    : () async {
                        // Vérification si les mots de passe correspondent
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Les mots de passe ne correspondent pas.'),
                            ),
                          );
                          return;
                        }

                        // Vérification des champs obligatoires
                        if (nameController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Veuillez remplir tous les champs obligatoires marqués avec *.'),
                            ),
                          );
                          return;
                        }

                        // Concaténation du code de référence avec le numéro de téléphone
                        String phoneNumberWithReference =
                            '${referenceCodeController.text}-${phoneController.text}';

                        await authProvider.createUserWithEmailAndPassword(
                          context,
                          emailController.text,
                          passwordController.text,
                          nameController.text,
                          phoneNumberWithReference,
                        );
                      },
                child: authProvider.isCreatingAccount
                    ? const SpinKitFadingCircle(
                        color: Colors.white,
                        size: 40.0,
                      )
                    : const Text(
                        'Créer le compte',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
