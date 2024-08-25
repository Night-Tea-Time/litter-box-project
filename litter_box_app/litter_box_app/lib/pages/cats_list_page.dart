import 'dart:io';

import 'package:cat_monitoring_app/components/my_button.dart';
import 'package:cat_monitoring_app/components/my_drawer.dart';
import 'package:cat_monitoring_app/pages/add_cat_info_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/my_subtitle.dart';
import '../firebase/firebase.dart';
import '../models/cat.dart';
import '../models/usage.dart';
import '../theme/color.dart';
import 'cat_details_page.dart';

class CatListPage extends StatefulWidget {
  const CatListPage({super.key});

  @override
  _CatListPageState createState() => _CatListPageState();
}

class _CatListPageState extends State<CatListPage> {
  void navigateToCatDetailsPage(Cat cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CatDetailsPage(cat: cat),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          "My Cats",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      drawer: MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // active cats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: MySubtitle(title: "Active Cats", icon: Icons.pets),
            ),

            // list all active cats
            FutureBuilder<List<Cat>>(
              future: fetchActiveCats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No active cats found.'));
                } else {
                  final activeCats = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: activeCats.length,
                      itemBuilder: (context, index) => CatTile(
                        deleteButton: true,
                        cat: activeCats[index],
                        onTap: () =>
                            navigateToCatDetailsPage(activeCats[index]),
                        onDelete: () async {
                          await deleteCat(context, activeCats[index]);

                          setState(() {}); // Refresh the page
                        },
                      ),
                    ),
                  );
                }
              },
            ),

            // Inactive cats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: MySubtitle(title: "Inactive Cats", icon: Icons.pets),
            ),

            // list all inactive cats
            FutureBuilder<List<Cat>>(
              future: fetchInactiveCats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No inactive cats found.'));
                } else {
                  final inactiveCats = snapshot.data!;
                  return Expanded(
                    child: ListView.builder(
                      itemCount: inactiveCats.length,
                      itemBuilder: (context, index) => CatTile(
                        deleteButton: false,
                        cat: inactiveCats[index],
                        onTap: () =>
                            navigateToCatDetailsPage(inactiveCats[index]),
                        onDelete: () async {
                          await deleteCat(context, inactiveCats[index]);
                          setState(() {}); // Refresh the page
                        },
                      ),
                    ),
                  );
                }
              },
            ),

            // add new cat button
            MyButton(
              onTap: () {
                // navigate to add new cat info page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCatInfoPage(),
                  ),
                );
              },
              text: "Add Cat",
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteCat(BuildContext context, Cat cat) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Cat'),
        content: Text('Are you sure you want to delete ${cat.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      // Update the cat status in Firestore
      inactivateCat(cat.id!);
    }
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  @override
  Widget build(context) {
    return _buildAndroid(context);
  }
}

class CatTile extends StatelessWidget {
  final Cat cat;
  final bool deleteButton;
  final void Function()? onTap;
  Future<void> Function()? onDelete;

  CatTile({
    super.key,
    required this.cat,
    required this.deleteButton,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: greyForTile,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2),
              )
            ]),
        margin: const EdgeInsets.only(left: 20, top: 10, right: 20),
        padding: const EdgeInsets.only(left: 0, right: 10, top: 0, bottom: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Container(
                height: 60,
                width: 80,
                child: Image.network(
                  cat.profileImage,
                  fit: BoxFit.cover, // Make image cover the container width
                ),
              ),
            ),
            SizedBox(width: 10), // Spacer between image and text
            Expanded(
              child: Text(
                cat.name,
                style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            if (deleteButton == true)
              IconButton(onPressed: onDelete, icon: Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }
}
