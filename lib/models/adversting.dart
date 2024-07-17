import 'package:cloud_firestore/cloud_firestore.dart';

class AdvertisementData {
  final String title;
  final bool isActive;
  final String advertisingStructure;
  final String imageUrl;

  AdvertisementData({
    required this.title,
    required this.isActive,
    required this.advertisingStructure,
    required this.imageUrl,
  });

  factory AdvertisementData.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdvertisementData(
      title: data['title'] ?? '',
      isActive: data['isActive'] ?? false,
      advertisingStructure: data['advertisingStructure'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
