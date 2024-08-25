import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/login_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.pets,
                size: 80,
              ),
            ),
          ),

          // HOME PAGE
          ListTile(
            leading: Icon(Icons.home),
            title: const Text("H O M E"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/homepage');
            },
          ),

          // CAT LIST
          ListTile(
            leading: Icon(Icons.pets),
            title: const Text("C A T"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/catlistpage');
              },
          ),

          ListTile(
            leading: Icon(Icons.devices),
            title: const Text("L I T T E R  B O X"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/devicelistpage');
            },
          ),

          // Long drawer contents are often segmented.
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),

          // Log out
          ListTile(
            leading: Icon(Icons.logout),
            title: const Text("L O G O U T"),
            onTap: () {
              Navigator.pop(context);

              // logout
              logout(context);
            },
          ),
        ],
      ),
    );
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    
    // Clear the login state
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);

    // Navigate back to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(type: "LOGIN")),
    );
  }
}