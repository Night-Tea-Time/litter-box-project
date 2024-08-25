import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/cat.dart';
import '../models/device.dart';
import '../models/message.dart';
import '../models/usage.dart';

Future<void> inactivateCat(String id) async{
  await FirebaseFirestore.instance.collection('cats').doc(id).update({'status': false});
}

Future<Usage?> fetchUsageById(String id) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot doc = await firestore.collection('usage').doc(id).get();
    if (doc.exists) {
      return Usage.fromDocument(doc);
    }
    return null; // Return null if the document does not exist
  } catch (e) {
    print('Error fetching usage: $e');
    return null;
  }
}

Future<Usage?> fetchLatestUsageByCatId(String catId) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query usages filtered by catId and ordered by dateTime descending, limit to 1 result
    QuerySnapshot usageSnapshot = await firestore
        .collection('usages')
        .where('catId', isEqualTo: catId)
        .orderBy('dateTime', descending: true)
        .limit(1)
        .get();

    if (usageSnapshot.docs.isNotEmpty) {
      Usage latestUsage = Usage.fromDocument(usageSnapshot.docs.first);
      print('Successfully fetched latest usage for catId $catId');
      return latestUsage;
    } else {
      print('No usages found for catId $catId');
      return null;
    }
  } catch (e) {
    print('Error fetching latest usage: $e');
    return null;
  }
}

Future<List<Usage>> fetchUsagesByCatId(String catId) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Query usages filtered by catId and ordered by dateTime descending
    QuerySnapshot usageSnapshot = await firestore
        .collection('usages')
        .where('catId', isEqualTo: catId)
        .orderBy('dateTime', descending: true)
        .get();

    List<Usage> usages = usageSnapshot.docs
        .map((doc) => Usage.fromDocument(doc))
        .toList();

    print('Successfully fetched ${usages.length} usages for catId $catId');
    return usages;
  } catch (e) {
    print('Error fetching usages: $e');
    return [];
  }
}

Future<void> markNotificationAsViewed(String messageId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('notifications').doc(messageId).update({'isViewed': true});
    } catch (e) {
      print('Error updating notification: $e');
    }
  }

Future<List<Message>> fetchMessagesWithUsage() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch messages ordered by dateTime in descending order
    QuerySnapshot messageSnapshot = await firestore
        .collection('notifications')
        .orderBy('dateTime', descending: true)
        .get();

    List<Message> messages = [];

    // Map documents to corresponding message type
    for (var doc in messageSnapshot.docs) {
      if (doc['type'] == 'ABNORMAL') {
        AbnormalMessage abnormalMessage = AbnormalMessage.fromDocument(doc);
        if (abnormalMessage.usageId != null && abnormalMessage.usageId!.isNotEmpty) {
          // Fetch usage document
          DocumentSnapshot usageDoc =
              await firestore.collection('usages').doc(abnormalMessage.usageId).get();

          if (usageDoc.exists) {
            Usage usage = Usage.fromDocument(usageDoc);
            abnormalMessage.usage = usage; // Update the usage field

            // Fetch cat document from usage
            if (usage.catId.isNotEmpty) {
              DocumentSnapshot catDoc =
                  await firestore.collection('cats').doc(usage.catId).get();

              if (catDoc.exists) {
                abnormalMessage.cat = Cat.fromDocument(catDoc); // Update the cat field
              }
            }
          }
        }
        messages.add(abnormalMessage);
      } else if (doc['type'] == 'UNRECOGNISED') {
        UnrecognisedMessage unrecognisedMessage = UnrecognisedMessage.fromDocument(doc);
        if (unrecognisedMessage.catId != null && unrecognisedMessage.catId!.isNotEmpty) {
          // Fetch unrecognised cat document
          DocumentSnapshot catDoc =
              await firestore.collection('cats').doc(unrecognisedMessage.catId).get();

          if (catDoc.exists) {
            unrecognisedMessage.cat = Cat.fromDocument(catDoc); // Update the cat field
          }
        }
        messages.add(unrecognisedMessage);
      }
    }

    print('Successfully fetched ${messages.length} messages with usages and cats');
    return messages;
  } catch (e) {
    print('Error fetching messages: $e');
    return [];
  }
}


Future<List<Message>> fetchUnviewedMessagesWithUsage() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch messages
    QuerySnapshot messageSnapshot = await firestore
        .collection('notifications')
        .where('isViewed', isEqualTo: false)
        .orderBy('dateTime', descending: true)
        .get();

    List<Message> messages = [];

    // Map documents to corresponding message type
    for (var doc in messageSnapshot.docs) {
      if (doc['type'] == 'ABNORMAL') {
        AbnormalMessage abnormalMessage = AbnormalMessage.fromDocument(doc);
        if (abnormalMessage.usageId != null && abnormalMessage.usageId!.isNotEmpty) {
          // Fetch usage document
          DocumentSnapshot usageDoc =
              await firestore.collection('usages').doc(abnormalMessage.usageId).get();

          if (usageDoc.exists) {
            Usage usage = Usage.fromDocument(usageDoc);
            abnormalMessage.usage = usage; // Update the usage field

            // Fetch cat document from usage
            if (usage.catId.isNotEmpty) {
              DocumentSnapshot catDoc =
                  await firestore.collection('cats').doc(usage.catId).get();

              if (catDoc.exists) {
                abnormalMessage.cat = Cat.fromDocument(catDoc); // Update the cat field
              }
            }
          }
        }
        messages.add(abnormalMessage);
      } else if (doc['type'] == 'UNRECOGNISED') {
        UnrecognisedMessage unrecognisedMessage = UnrecognisedMessage.fromDocument(doc);
        if (unrecognisedMessage.catId != null && unrecognisedMessage.catId!.isNotEmpty) {
          // Fetch unrecognised cat document
          DocumentSnapshot catDoc =
              await firestore.collection('cats').doc(unrecognisedMessage.catId).get();

          if (catDoc.exists) {
            unrecognisedMessage.cat = Cat.fromDocument(catDoc); // Update the cat field
          }
        }
        messages.add(unrecognisedMessage);
      }
    }

    print(
        'Successfully fetched ${messages.length} unviewed messages with usages');
    return messages;
  } catch (e) {
    print('Error fetching messages with usages: $e');
    return [];
  }
}

// Function to fetch all active cats data
Future<List<Cat>> fetchActiveCats() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('cats').get();

    // Filter the cats with status true
    List<Cat> cats = querySnapshot.docs
        .map((doc) => Cat.fromDocument(doc))
        .where((cat) => cat.status == true) // Assuming 'true' is a String
        .toList();
    print('Successfully fetch cats ${cats.length}');
    return cats;
  } catch (e) {
    print('Error fetching cats: $e');
    return [];
  }
}

// Function to fetch all active cats data excepts unrecognised cat
Future<List<Cat>> fetchActiveRecogniseCats() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('cats').get();

    // Filter the cats with status true
    List<Cat> cats = querySnapshot.docs
        .map((doc) => Cat.fromDocument(doc))
        .where((cat) => cat.status == true && cat.name.toLowerCase() != 'unrecognised') // Assuming 'true' is a String
        .toList();
    print('Successfully fetch cats ${cats.length}');
    return cats;
  } catch (e) {
    print('Error fetching cats: $e');
    return [];
  }
}

Future<List<Cat>> fetchInactiveCats() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('cats').get();

    // Filter the cats with status true
    List<Cat> cats = querySnapshot.docs
        .map((doc) => Cat.fromDocument(doc))
        .where((cat) => cat.status == false) // Assuming 'true' is a String
        .toList();

    return cats;
  } catch (e) {
    print('Error fetching cats: $e');
    return [];
  }
}

// This function get the cat by cat id
Future<Cat?> fetchCatByCatId(String catId) async{
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch the document with the given cat ID
    DocumentSnapshot docSnapshot = await firestore.collection('cats').doc(catId).get();

    if (docSnapshot.exists) {
      // If the document exists, convert it to a Cat object
      return Cat.fromDocument(docSnapshot);
    } else {
      print('No cat found with ID: $catId');
      return null;
    }
  } catch (e) {
    print('Error fetching cat: $e');
    return null ;
  }
}

// Add New Cat To Firebase
Future<void> addNewCat(Cat cat, List<String> imagePaths) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    // Create a new document in Firestore and get its reference
    final catRef = await firestore.collection('cats').add({
      'name': cat.name,
      'gender': cat.gender,
      'timestamp': FieldValue.serverTimestamp(),
      'status': true,
    });

    // Rename the cat profile image file to catRef
    String catProfileImage = await renameFile(cat.profileImage, catRef.id);

    // Upload cat profile image to fire storage
    print("Uploading cat profile image");
    // Ensure the profile image path is valid
    if (catProfileImage.isEmpty) {
      print('Profile image path is empty');
      return;
    }
    String profileUrl =
        await uploadImageToFirebase(File(catProfileImage), "cat_profile");

    // Upload cat 4 side images to Firebase Storage and save their URLs
    print("Uploading cats images");
    List<String> imageUrls = [];
    for (var imagePath in imagePaths) {
      var fileName = path.basename(imagePath);
      fileName = await renameFile(imagePath, "${catRef.id}+${fileName}");
      imageUrls.add(await uploadImageToFirebase(File(fileName), "cat_images"));
    }

    // Update the Firestore document with the image URLs
    await catRef.update({
      'profileImage': profileUrl,
      'imageUrls': imageUrls,
    });

    print('Cat information and images saved successfully.');
  } catch (e) {
    print('Error saving cat information and images: $e');
  }
}

Future<void> updateUnrecognisedCatProfile(String unrecognisedCatId, String selectedCatId) async{

  // Find the usage document with the unrecognised catId
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    .collection('usages')
    .where('catId', isEqualTo: unrecognisedCatId)
    .get();

  if (querySnapshot.docs.isNotEmpty) {
    // Assuming there's only one usage document associated with the cat
    DocumentSnapshot usageDoc = querySnapshot.docs.first;
    String existingUsageId = usageDoc.id;

    // Update the usage document with the new catId
    await FirebaseFirestore.instance
        .collection('usages')
        .doc(existingUsageId)
        .update({'catId': selectedCatId});

  } else {
    print('No usage found with the unrecognised cat catId');
    return;
  }

  // Find the message document with the unrecognised catId
  querySnapshot = await FirebaseFirestore.instance
    .collection('notifications')
    .where('catId', isEqualTo: unrecognisedCatId)
    .get();

  if (querySnapshot.docs.isNotEmpty) {
    // Assuming there's only one message document associated with the cat
    DocumentSnapshot messageDoc = querySnapshot.docs.first;
    String existingMessageId = messageDoc.id;

    // Update the usage document with the new catId
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(existingMessageId)
        .update({'existingCat': selectedCatId, 'isAssigned': true,});

  } else {
    print('No usage found with the unrecognised cat catId');
    return;
  }

}

Future<String> uploadImageToFirebase(File imageFile, String filePath) async {
  String imageUrl;
  // Check if file exists
  if (!imageFile.existsSync()) {
    print('File does not exist at path: ${imageFile.path}');
    return '';
  }

  try {
    var fileName = path.basename(imageFile.path);
    Reference reference =
        FirebaseStorage.instance.ref().child("${filePath}/${fileName}");
    await reference.putFile(imageFile).whenComplete(() {
      print('Successful upload image');
    });

    // getDownloadURL
    return await reference.getDownloadURL();
  } catch (e) {
    print('Error upload images: $e');
  }

  return "";
}

// get all connected devices
Future<List<Device>> fetchDevices() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot deviceSnapshot = await firestore.collection('litterboxs').get();

    List<Device> devices = deviceSnapshot.docs.map((doc) => Device.fromDocument(doc)).toList();

    return devices;
  } catch (e) {
    print('Error fetching devices: $e');
    return [];
  }
}

Future<String> renameFile(String oldImagePath, String newFileName) async {
  // Get the directory of the old file
  final directory = path.dirname(oldImagePath);

  // Get the new file path by joining the directory and new file name
  final newFilePath =
      path.join(directory, '$newFileName${path.extension(oldImagePath)}');

  // Create a File instance for the old and new file paths
  final oldFile = File(oldImagePath);
  final newFile = File(newFilePath);

  try {
    // Rename (move) the old file to the new file path
    await oldFile.rename(newFilePath);

    print('File renamed successfully to $newFilePath');
    return newFilePath;
  } catch (e) {
    print('Error renaming file: $e');
  }
  return "";
}
