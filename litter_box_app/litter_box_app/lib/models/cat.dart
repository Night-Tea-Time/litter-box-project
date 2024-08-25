import 'package:cloud_firestore/cloud_firestore.dart';

import 'usage.dart';

class Cat {
  final String? id;
  final String name;
  final String profileImage;
  final String gender;
  late DateTime? createdDate;
  late bool? status;
  late List<Usage>? usages;

  Cat({
    this.id,
    required this.name,
    required this.profileImage,
    required this.gender,
    this.createdDate,
    this.status,
    this.usages,
  });

  factory Cat.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Cat(
      id: doc.id,
      name: data['name'] ?? '',
      gender: data['gender'] ?? '',
      createdDate: (data['timestamp'] as Timestamp).toDate(),
      profileImage: data['profileImage'] ?? '', 
      status: data['status'] ?? '',  
    );
  }
}
