import 'package:cat_monitoring_app/components/my_drawer.dart';
import 'package:cat_monitoring_app/pages/unrecognised_cat_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/cat_tile.dart';
import '../components/my_subtitle.dart';
import '../components/notification_tile.dart';
import '../firebase/firebase.dart';
import '../models/cat.dart';
import '../models/message.dart';
import '../theme/color.dart';
import 'cat_details_page.dart';
import 'stool_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  late Stream<DatabaseEvent> _dataStream;
  String userID = 'user123'; // Replace with the actual user ID
  Map<String, dynamic> newMessage = {};
  List<Cat> cats = [];
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _dataStream = _databaseReference.child('notifications').child(userID).onValue;
    _listenToUserData();
    _fetchInitialData();
  }

  void _listenToUserData() {
    _dataStream.listen((DatabaseEvent event) {
      setState(() {
        newMessage = Map<String, dynamic>.from(event.snapshot.value as Map<dynamic, dynamic>);
      });
      _fetchData(); // Refresh the data when there is a new update
    });
  }

  void _fetchInitialData() async {
    List<Cat> initialCats = await fetchActiveCats();
    List<Message> initialMessages = await fetchUnviewedMessagesWithUsage();
    setState(() {
      cats = initialCats;
      messages = initialMessages;
    });
  }

  Future<void> _fetchData() async {
    List<Cat> updatedCats = await fetchActiveCats();
    List<Message> updatedMessages = await fetchUnviewedMessagesWithUsage();
    setState(() {
      cats = updatedCats;
      messages = updatedMessages;
    });
  }

  void navigateToCatDetailsPage(Cat cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CatDetailsPage(cat: cat),
      ),
    );
  }

  void navigateToNotificationDetailsPage(Message notification) {
    setState(() {
      notification.isViewed = true;
      // update to database
      markNotificationAsViewed(notification.id);
    });

    if(notification.type == 'ABNORMAL'){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoolDetailsPage(usage: notification.usage!, cat: notification.cat!),
        ),
      );
    }
    else if(notification.type == 'UNRECOGNISED'){
      UnrecognisedMessage unrecognisedMessage = notification as UnrecognisedMessage;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UnrecognisedCatPage( message: unrecognisedMessage),
        ),
      );
    }

    
  }

  Widget _seeAllTextButton(double fontsize) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/notificationpage');
        },
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.fredoka(
            fontSize: fontsize,
            fontWeight: FontWeight.bold,
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("See All", textAlign: TextAlign.center),
            SizedBox(width: 5),
            Icon(Icons.arrow_right_outlined, size: fontsize),
          ],
        ),
      ),
    );
  }

  Widget _buildCatsSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MySubtitle(title: "My Cats", icon: Icons.pets),
                IconButton(
                  icon: Icon(Icons.add, size: 20, color: primaryColor),
                  onPressed: () {
                    Navigator.pushNamed(context, '/addcatinfopage');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: cats.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 5,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: cats.length,
                    itemBuilder: (context, index) => CatTileSquare(
                      cat: cats[index],
                      onTap: () => navigateToCatDetailsPage(cats[index]),
                    ),
                  )
                : Center(child: Text('No cats found.')),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MySubtitle(title: "Notifications", icon: Icons.notifications),
                _seeAllTextButton(12),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: messages.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) => NotificationTile(
                      notification: messages[index],
                      onTap: () => navigateToNotificationDetailsPage(messages[index]),
                    ),
                  )
                : Center(child: Text('No messages found.')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          "Home Page",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      drawer: MyDrawer(),
      body: ListView(
        children: [
          SizedBox(height: 20),
          _buildCatsSection(),
          _buildNotificationsSection(),
        ],
      ),
    );
  }
}
