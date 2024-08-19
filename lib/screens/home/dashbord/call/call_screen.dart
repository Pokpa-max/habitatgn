// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:habitatgn/utils/appcolors.dart';
// import 'package:habitatgn/utils/ui_element.dart';
// import 'package:url_launcher/url_launcher.dart';

// class CallPage extends StatelessWidget {
//   const CallPage({super.key});

//   void _makePhoneCall(String phoneNumber) async {
//     final Uri launchUri = Uri(
//       scheme: 'tel',
//       path: phoneNumber,
//     );
//     await launchUrl(launchUri);
//   }

//   Widget _buildContactButton({
//     required IconData icon,
//     required String operatorName,
//     required String phoneNumber,
//     required Color color,
//   }) {
//     return ElevatedButton(
//       onPressed: () => _makePhoneCall(phoneNumber),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(color: lightPrimary2, width: 2),
//         ),
//         elevation: 0.5,
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: color,
//             child: FaIcon(icon, color: Colors.white),
//           ),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 operatorName,
//                 style: TextStyle(
//                   color: color,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 phoneNumber,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Appuyez pour appeler',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey.shade600,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_outlined,
//             color: lightPrimary,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const CustomTitle(
//           text: "Contactez l'agence",
//           textColor: lightPrimary,
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 16),
//             const Text(
//               'Nous sommes là pour vous aider !',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 24),
//             _buildContactButton(
//               icon: FontAwesomeIcons.phoneFlip,
//               operatorName: 'Orange',
//               phoneNumber: '00224 62 00 00 00',
//               color: Colors.orangeAccent,
//             ),
//             const SizedBox(height: 16),
//             _buildContactButton(
//               icon: FontAwesomeIcons.phoneFlip,
//               operatorName: 'Areeba',
//               phoneNumber: '00224 66 00 00 00',
//               color: Colors.yellow,
//             ),
//             const SizedBox(height: 16),
//             _buildContactButton(
//               icon: FontAwesomeIcons.phoneFlip,
//               operatorName: 'Cellcom',
//               phoneNumber: '00224 68 00 00 00',
//               color: Colors.redAccent,
//             ),
//             const Spacer(),
//             Center(
//               child: Text(
//                 'Disponible 24/7 pour toute assistance',
//                 style: TextStyle(
//                   color: Colors.blueGrey.shade700,
//                   fontStyle: FontStyle.italic,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:url_launcher/url_launcher.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchContacts() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot snapshot = await firestore.collection('contacts').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'icon': _iconFromString(data['icon']),
        'operatorName': data['operatorName'],
        'phoneNumber': data['phoneNumber'],
        'color': Color(int.parse(data['color'].replaceFirst('#', '0xFF'))),
      };
    }).toList();
  }

  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'phoneFlip':
        return FontAwesomeIcons.phoneFlip;
      default:
        return FontAwesomeIcons.phone; // Valeur par défaut
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            color: lightPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomTitle(
          text: "Contactez l'agence",
          textColor: lightPrimary,
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: primaryColor,
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun contact disponible.'));
          }
          final contacts = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Nous sommes là pour vous aider !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                // Itération sur la liste des contacts pour générer les boutons
                ...contacts.map((contact) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ElevatedButton(
                        onPressed: () => _makePhoneCall(contact['phoneNumber']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: lightPrimary2, width: 2),
                          ),
                          elevation: 0.5,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: contact['color'],
                              child:
                                  FaIcon(contact['icon'], color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact['operatorName'],
                                  style: TextStyle(
                                    color: contact['color'],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  contact['phoneNumber'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Appuyez pour appeler',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
                const Spacer(),
                Center(
                  child: Text(
                    'Disponible 24/7 pour toute assistance',
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
