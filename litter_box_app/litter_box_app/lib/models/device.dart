import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String name;
  final String id;

  Device({required this.name, required this.id});

  // Factory method to create a Device instance from a Firestore document
  factory Device.fromDocument(DocumentSnapshot doc) {
    return Device(
      name: doc['name'],
      id: doc.id,
    );
  }
}