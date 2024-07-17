import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitatgn/models/adversting.dart';

class AdvertisementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'sliderImages';

  Future<List<AdvertisementData>> fetchAdvertisementDatas() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionPath).get();
      List<AdvertisementData> advertisementDatas =
          querySnapshot.docs.map((doc) {
        return AdvertisementData.fromDocument(doc);
      }).toList();
      return advertisementDatas;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données: $e');
    }
  }
}
