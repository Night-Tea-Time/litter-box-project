import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cat.dart';

class firestoreService{

  // get collections
  final CollectionReference cats = FirebaseFirestore.instance.collection('cats');

  // create
  Future<void> addCat(Cat cat){
    return cats.add ({
      'name' : cat.name,
      'profileImage' : cat.profileImage,
      'gender' : cat.gender,
    });
  }

  // read

  // update

  // delete
}