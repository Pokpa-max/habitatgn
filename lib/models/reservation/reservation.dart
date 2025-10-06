import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  final DateTime requestDate;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  final String? message;
  final ReservationStatus status;
  final DateTime? confirmedAt;
  final String? confirmerId;
  final String? imageUrl;
  final String? contactPhone;
  final HouseType? houseType;
  final Address? address;
  final int numberOfGuests;
  final int numberOfNights;
  final TimeOfDay? checkInTime;

  ReservationDetails({
    required this.userId,
    required this.houseId,
    required this.userName,
    required this.userPhone,
    required this.requestDate,
    required this.numberOfGuests,
    required this.numberOfNights,
    this.checkInDate,
    this.checkOutDate,
    this.checkInTime,
    this.message,
    required this.status,
    this.confirmedAt,
    this.confirmerId,
    this.imageUrl,
    this.contactPhone,
    this.address,
    this.houseType,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'houseId': houseId,
      'userName': userName,
      'userPhone': userPhone,
      'requestDate': Timestamp.fromDate(requestDate),
      'checkInDate':
          checkInDate != null ? Timestamp.fromDate(checkInDate!) : null,
      'checkOutDate':
          checkOutDate != null ? Timestamp.fromDate(checkOutDate!) : null,
      'checkInTime': checkInTime != null
          ? {'hour': checkInTime!.hour, 'minute': checkInTime!.minute}
          : null,
      'message': message,
      'status': status.value,
      'imageUrl': imageUrl,
      'contactPhone': contactPhone,
      'houseType': houseType?.toMap(),
      'address': address?.toMap(),
      'numberOfGuests': numberOfGuests,
      'numberOfNights': numberOfNights,
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
      imageUrl: map['imageUrl'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      numberOfGuests: map['numberOfGuests'],
      numberOfNights: map['numberOfNights'],
      requestDate: (map['requestDate'] as Timestamp).toDate(),
      checkInDate: map['checkInDate'] != null
          ? (map['checkInDate'] as Timestamp).toDate()
          : null,
      checkOutDate: map['checkOutDate'] != null
          ? (map['checkOutDate'] as Timestamp).toDate()
          : null,
      checkInTime: map['checkInTime'] != null &&
              map['checkInTime'] is Map<String, dynamic>
          ? TimeOfDay(
              hour: map['checkInTime']['hour'] ?? 0,
              minute: map['checkInTime']['minute'] ?? 0)
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
