
import 'package:cloud_firestore/cloud_firestore.dart';

import 'usage.dart';
import 'cat.dart';

abstract class Message {
  final String id;
  final String type;
  final DateTime dateTime;
  bool isViewed;
  Cat? cat;
  Usage? usage;

  Message({
    required this.id,
    required this.type,
    required this.dateTime,
    required this.isViewed,
  });

  // No need for additional getters as the fields are already public
}

class AbnormalMessage extends Message {
  final String? usageId;

  AbnormalMessage({
    required String id,
    required String type,
    required DateTime dateTime,
    required bool isViewed,
    this.usageId,
  }) : super(id: id, type: type, dateTime: dateTime, isViewed: isViewed);

  // Factory constructor to create an AbnormalMessage from a Firestore document
  factory AbnormalMessage.fromDocument(DocumentSnapshot doc) {
    return AbnormalMessage(
      id: doc.id,
      type: doc['type'] ?? '',
      dateTime: (doc['dateTime'] as Timestamp).toDate(),
      isViewed: doc['isViewed'] ?? false,
      usageId: doc['usageId'],
    );
  }
}

class UnrecognisedMessage extends Message {
  final String? catId;
  final String? existingCat;
  final bool? isAssigned;

  UnrecognisedMessage({
    required String id,
    required String type,
    required DateTime dateTime,
    required bool isViewed,
    this.catId,
    this.existingCat,
    this.isAssigned,
  }) : super(id: id, type: type, dateTime: dateTime, isViewed: isViewed);

  // Factory constructor to create an UnrecognisedMessage from a Firestore document
  factory UnrecognisedMessage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
    return UnrecognisedMessage(
      id: doc.id,
      type: data['type'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      isViewed: data['isViewed'] ?? false,
      catId: data['catId'],
      existingCat: data.containsKey('existingCat') ? data['existingCat'] : null, // Safely access 'existingCat'
      isAssigned: data.containsKey('isAssigned') ? data['isAssigned'] : false,
    );
  }
}
