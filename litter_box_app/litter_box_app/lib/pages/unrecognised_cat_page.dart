import 'package:cat_monitoring_app/firebase/firebase.dart';
import 'package:cat_monitoring_app/models/message.dart';
import 'package:cat_monitoring_app/pages/add_cat_info_page.dart';
import 'package:cat_monitoring_app/pages/cat_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';

import '../models/cat.dart';
import '../theme/color.dart';

class UnrecognisedCatPage extends StatefulWidget {
  final UnrecognisedMessage message;

  const UnrecognisedCatPage({Key? key, required this.message})
      : super(key: key);

  @override
  _UnrecognisedCatPageState createState() => _UnrecognisedCatPageState();
}

class _UnrecognisedCatPageState extends State<UnrecognisedCatPage> {
  Cat? unrecognisedCat;
  Cat? assignedCat;
  bool? isAssigned;
  String? comment = '';

  @override
  void initState() {
    super.initState();
    unrecognisedCat = widget.message.cat;
    isAssigned = widget.message.isAssigned;

    // Check if the unrecognised notification has been solved
    if (isAssigned == true) {
      _initializeAssignedCat(widget.message.existingCat!);

      // Check if merge with existing cat or create a new one
      if (widget.message.catId == widget.message.existingCat) {
        comment = "New cat profile created for this cat.";
      } else {
        comment = "Merged to existing cat profile";
      }
    }
  }

  Future<void> _initializeAssignedCat(String catId) async {
    assignedCat = await fetchCatByCatId(catId);
    setState(() {}); // Notify the UI that the state has changed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25),
            Column(
              children: [
                Container(
                  width: 300, // Fixed width
                  height: 300, // Fixed height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                    image: DecorationImage(
                      image: NetworkImage(unrecognisedCat!.profileImage),
                      fit: BoxFit
                          .cover, // Ensures the image covers the container
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 100,
                  width: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Color.fromARGB(255, 209, 209, 209).withOpacity(0.5),
                        spreadRadius: 0.5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      Text(
                        "Unrecognised Cat",
                        style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      if (isAssigned == true && assignedCat != null)
                        Row(
                          children: [
                            Text(comment!),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CatDetailsPage(cat: assignedCat!),
                                    ),
                                  );
                                },
                                child: Text(assignedCat!.name))
                          ],
                        )
                    ],
                  ),
                ),
              ],
            ),
            Spacer(),
            if (isAssigned! == false)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddCatInfoPage(cat: unrecognisedCat!),
                      ),
                    ),
                    label: Text(
                      "New Cat",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCatSelectionDialog(context),
                    label: Text(
                      "Exsiting Cat",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showCatSelectionDialog(BuildContext context) async {
    // Fetch active cats using the provided function
    List<Cat> activeCats = await fetchActiveRecogniseCats();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select a Cat'),
          content: activeCats.isNotEmpty
              ? Container(
                  width: double.minPositive,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: activeCats.length,
                    itemBuilder: (context, index) {
                      Cat cat = activeCats[index];
                      return ListTile(
                        title: Text(cat.name),
                        onTap: () => _confirmCatSelection(context, cat.id!),
                      );
                    },
                  ),
                )
              : Text('No active cats available.'),
        );
      },
    );
  }

  Future<void> _confirmCatSelection(
      BuildContext context, String selectedCatId) async {
    Navigator.of(context).pop(); // Close the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Update the usage document with the selected catId
      await updateUnrecognisedCatProfile(unrecognisedCat!.id!, selectedCatId);

      Navigator.of(context).pop(); // Close the loading dialog

      Navigator.pushNamed(context, '/homepage');
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading dialog
      print('Error updating usage catId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update cat. Please try again.')),
      );
    }
  }
}
