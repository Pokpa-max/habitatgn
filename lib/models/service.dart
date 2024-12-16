// lib/models/service_request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequestModel {
  final String serviceType;
  final String name;
  final String address;
  final String description;
  final String status;
  final String phone;
  final String userId;
  final String scheduledDate;
  final String scheduledTime;

  ServiceRequestModel({
    required this.serviceType,
    required this.name,
    required this.address,
    required this.description,
    required this.status,
    required this.phone,
    required this.userId,
    required this.scheduledDate,
    required this.scheduledTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'name': name,
      'address': address,
      'phone': phone,
      'userId': userId,
      'description': description,
      'status': status,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'createdAt': Timestamp.now(),
    };
  }

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      serviceType: json['serviceType'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      status: json['status'] as String,
      phone: json['phone'] as String,
      userId: json['userId'] as String,
      description: json['description'] as String,
      scheduledDate: json['scheduledDate'] as String,
      scheduledTime: json['scheduledTime'] as String,
    );
  }
}
