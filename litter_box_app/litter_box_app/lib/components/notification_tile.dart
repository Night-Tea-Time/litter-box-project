import 'package:cat_monitoring_app/models/message.dart';
import 'package:cat_monitoring_app/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationTile extends StatelessWidget {
  final Message notification;
  final void Function()? onTap;

  
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  String messageText(){

    if(notification.type == 'ABNORMAL'){
      if(notification.usage?.colour == "Red"){
        return "${notification.cat?.name} have blood found in thier stool!";

      }
      else{
        return "${notification.cat?.name} is having ${notification.usage?.condition}.";
      }
    }
    else if(notification.type == 'UNRECOGNISED'){
      return "An unrecognised cat founded in the household!";
    }
    
    return '';
    
  }

  @override
  Widget build(BuildContext context) {

    TextStyle viewedTextStyle = GoogleFonts.fredoka(fontWeight: FontWeight.normal, fontSize: 15);
    TextStyle unviewTextStyle = GoogleFonts.fredoka(fontWeight: FontWeight.bold, fontSize: 15);
  
    TextStyle selectedTextStyle = notification.isViewed ? viewedTextStyle : unviewTextStyle;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: greyForTile,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        padding: const EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // date + time
            Text(
              "${notification.dateTime.day}-${notification.dateTime.month}-${notification.dateTime.year}  ${notification.dateTime.hour.toString().padLeft(2,'0')}:${notification.dateTime.minute.toString().padLeft(2,'0')}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 9,
              ),
            ),

            // title
            Text(
              notification.type == "ABNORMAL"? "Abnormal Stool Detected":"Unrecognised Cat",
              style: selectedTextStyle,
            ),

            // message
            Text(
              messageText(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
