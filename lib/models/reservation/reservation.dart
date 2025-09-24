import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitatgn/models/house_result_model.dart';

enum ReservationStatus {
  available('available', 'Disponible'),
  pending('pending', 'En attente'),
  confirmed('confirmed', 'Confirmé'),
  cancelled('cancelled', 'Annulé'),
  completed('completed', 'Terminé');

  const ReservationStatus(this.value, this.label);
  final String value;
  final String label;
}

class ReservationDetails {
  final String userId;
  final String houseId;
  final String userName;
  final String userPhone;
  final String userEmail;
  final DateTime requestDate;
  final DateTime? visitDate;
  final String? message;
  final ReservationStatus status;
  final DateTime? confirmedAt;
  final String? confirmerId;
  final String? imageUrl;
  final String? contactPhone;
  final HouseType? houseType;
  final Address? address;

  ReservationDetails(
      {required this.userId,
      required this.houseId,
      required this.userName,
      required this.userPhone,
      required this.userEmail,
      required this.requestDate,
      this.visitDate,
      this.message,
      required this.status,
      this.confirmedAt,
      this.confirmerId,
      this.imageUrl,
      this.contactPhone,
      this.address,
      this.houseType});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'houseId': houseId,
      'userName': userName,
      'userPhone': userPhone,
      'userEmail': userEmail,
      'requestDate': Timestamp.fromDate(requestDate),
      'visitDate': visitDate != null ? Timestamp.fromDate(visitDate!) : null,
      'message': message,
      'status': status.value,
      'imageUrl': imageUrl,
      'contactPhone': contactPhone,
      'houseType': houseType?.toMap(),
      'address': address?.toMap(),
      'confirmedAt':
          confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'confirmerId': confirmerId,
    };
  }

  static ReservationDetails fromMap(Map<String, dynamic> map) {
    return ReservationDetails(
      userId: map['userId'] ?? '',
      houseId: map['houseId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      userEmail: map['userEmail'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      requestDate: (map['requestDate'] as Timestamp).toDate(),
      visitDate: map['visitDate'] != null
          ? (map['visitDate'] as Timestamp).toDate()
          : null,
      message: map['message'],
      status: ReservationStatus.values.firstWhere(
        (s) => s.value == map['status'],
        orElse: () => ReservationStatus.available,
      ),
      address: map['address'] != null && map['address'] is Map<String, dynamic>
          ? Address.fromMap(map['address'])
          : null,
      houseType:
          map['houseType'] != null && map['houseType'] is Map<String, dynamic>
              ? HouseType.fromMap(map['houseType'])
              : null,
      confirmedAt: map['confirmedAt'] != null
          ? (map['confirmedAt'] as Timestamp).toDate()
          : null,
      confirmerId: map['confirmerId'],
    );
  }
}
