// lib/models/service_request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequestModel {
  final String serviceType;
  final String name;
  final String address;
  final String phone;
  final String userId;

  ServiceRequestModel({
    required this.serviceType,
    required this.name,
    required this.address,
    required this.phone,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'name': name,
      'address': address,
      'phone': phone,
      'userId': userId,
      'createdAt': Timestamp.now(),
    };
  }

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      serviceType: json['serviceType'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      userId: json['userId'] as String,
    );
  }
}
