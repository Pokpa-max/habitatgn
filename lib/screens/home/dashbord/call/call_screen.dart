// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitatgn/utils/appcolors.dart';
import 'package:habitatgn/utils/ui_element.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallPage extends StatelessWidget {
  const CallPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchContacts() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final QuerySnapshot snapshot =
          await firestore.collection('callPhoneOperators').get();
      final contacts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final operatorColor =
            OperatorInfo.fromName(data['operatorName']).colorValue;

        return {
          'operatorName': data['operatorName'],
          'phoneNumber': data['phoneNumber'],
          'color': operatorColor,
        };
      }).toList();

      // Sauvegarde des contacts en local
      _saveContactsLocally(contacts);
      return contacts;
    } catch (e) {
      // Si une erreur se produit, récupérez les contacts sauvegardés localement
      return _loadContactsLocally();
    }
  }

  Future<void> _saveContactsLocally(List<Map<String, dynamic>> contacts) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'contacts',
        contacts
            .map(
                (c) => '${c['operatorName']},${c['phoneNumber']},${c['color']}')
            .join(';'));
  }

  // List<Map<String, dynamic>>
  _loadContactsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsString = prefs.getString('contacts') ?? '';

    if (contactsString.isEmpty) return [];

    return contactsString.split(';').map((s) {
      final parts = s.split(',');
      return {
        'operatorName': parts[0],
        'phoneNumber': parts[1],
        'color': Color(int.parse(parts[2])),
      };
    }).toList();
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
                child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            print('snapshot.error: ${snapshot.error}');
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
                            const CircleAvatar(
                              backgroundColor: primaryColor,
                              child: FaIcon(FontAwesomeIcons.phone,
                                  color: Colors.white),
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
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Appuyez pour appeler',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
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

enum OperatorInfo {
  orange('Orange', Colors.orange),
  cellcom('Cellcom', Colors.red),
  arreba('Areeba', Colors.yellow),
  watshapp('Whatsapp', Colors.green);

  final String name;
  final Color colorValue;

  const OperatorInfo(this.name, this.colorValue);

  static OperatorInfo fromName(String name) {
    switch (name.toLowerCase()) {
      case 'orange':
        return OperatorInfo.orange;
      case 'cellcom':
        return OperatorInfo.cellcom;
      case 'areeba':
        return OperatorInfo.arreba;
      case 'whatsapp':
        return OperatorInfo.watshapp;
      default:
        throw Exception('Opérateur inconnu : $name');
    }
  }
}
