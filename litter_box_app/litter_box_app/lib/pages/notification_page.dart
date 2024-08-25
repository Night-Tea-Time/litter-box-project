import 'package:cat_monitoring_app/firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/notification_tile.dart';
import '../models/message.dart';
import '../theme/color.dart';
import 'stool_details_page.dart';
import 'unrecognised_cat_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Message>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = fetchMessagesWithUsage();
  }

  void _handleNotificationTap(Message message) async {
    // Mark notification as viewed
    if(!message.isViewed){
      await markNotificationAsViewed(message.id);
    }
    
    // Refresh the notifications
    setState(() {
      _notificationsFuture = fetchMessagesWithUsage();
    });

    if(message.type == 'ABNORMAL'){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoolDetailsPage(usage: message.usage!, cat: message.cat!),
        ),
      );
    }
    else if(message.type == 'UNRECOGNISED'){
      UnrecognisedMessage unrecognisedMessage = message as UnrecognisedMessage;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UnrecognisedCatPage( message: unrecognisedMessage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Message>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No notifications found.'));
            }

            final messages = snapshot.data!;

            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: NotificationTile(
                    notification: message,
                    onTap: () => _handleNotificationTap(message),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
