import 'package:cloud_firestore/cloud_firestore.dart';

class Usage {
  final String id;
  final String condition;
  final String shape;
  final String colour;
  final DateTime dateTime;
  final String litterboxId;
  final String catId;
  final String image;

  Usage({
    required this.id,
    required this.condition,
    required this.shape,
    required this.colour,
    required this.dateTime,
    required this.litterboxId,
    required this.catId,
    required this.image,
  });

  // getter methods
  String get _condition => condition;
  String get _shape => shape;
  String get _colour => colour;
  DateTime get _date => dateTime;
  String get _litterboxId => litterboxId;
  String get _image => image;

  factory Usage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usage(
      id: doc.id,
      condition: data['condition'] ?? '',
      shape: data['shape'] ?? '',
      colour: data['colour'] ?? '',
      dateTime: data['dateTime'].toDate() ?? '',
      litterboxId: data['litterboxId'] ?? '',
      catId: data['catId'] ?? '',
      image: data['image'] ?? '',
    );
  }
}
