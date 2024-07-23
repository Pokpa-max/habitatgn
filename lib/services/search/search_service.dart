import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitatgn/models/house_result_model.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<House>> searchHouses({
    required String type,
    required String location,
    required String commune,
    required String quartier,
    required String partNumber,
    required int minPrice,
    required int maxPrice,
    required bool isVenteSelected,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    Query query = _firestore
        .collection('houses')
        .where('houseType.label', isEqualTo: type)
        .where('address.town.value', isEqualTo: location)
        .where('address.commune.value',
            isEqualTo: commune.isEmpty ? null : commune)
        .where('address.zone', isEqualTo: quartier.isEmpty ? null : quartier)
        .where('bedrooms',
            isEqualTo: partNumber.isEmpty ? null : int.parse(partNumber))
        .where('price', isGreaterThanOrEqualTo: minPrice)
        .where('price', isLessThanOrEqualTo: maxPrice)
        .where('isAvailable', isEqualTo: false)
        .where('isPurchaseMode',
            isEqualTo: isVenteSelected); //boolean de vente ou location

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs.map((doc) => House.fromFirestore(doc)).toList();
  }
}
