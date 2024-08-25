import 'dart:io';
import 'dart:typed_data';

import 'package:cat_monitoring_app/pages/cat_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../models/cat.dart';
import '../models/usage.dart';
import '../theme/color.dart';

class StoolDetailsPage extends StatefulWidget {
  final Usage usage;
  final Cat? cat;

  const StoolDetailsPage({Key? key, required this.usage, this.cat})
      : super(key: key);

  @override
  _StoolDetailsPageState createState() => _StoolDetailsPageState();
}

class _StoolDetailsPageState extends State<StoolDetailsPage> {
  late Usage usage;
  Cat? cat;

  @override
  void initState() {
    super.initState();
    usage = widget.usage;
    cat = widget.cat;
  }

  Future<void> downloadImage() async {
    try {
      final byteData = await NetworkAssetBundle(Uri.parse(usage.image)).load("");
      final Uint8List bytes = byteData.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final String imagePath = '${directory.path}/${usage.image.split('/').last}';
      final File imgFile = File(imagePath);
      await imgFile.writeAsBytes(bytes);

      final result = await GallerySaver.saveImage(imagePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result != null && result ? "Image saved to gallery" : "Error saving image to gallery")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error downloading image: $e")));
    }
  }

  Future<void> shareImage() async {
    try {
      final byteData = await NetworkAssetBundle(Uri.parse(usage.image)).load("");
      final Uint8List bytes = byteData.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final File imgFile = File('${directory.path}/${usage.image.split('/').last}');
      await imgFile.writeAsBytes(bytes);

      await FlutterShare.shareFile(
        title: 'Share Image',
        filePath: imgFile.path,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sharing image: $e")));
    }
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

            // Cat profile details
            if (cat != null) ...[
              GestureDetector(
                // navigate to cat profile on click
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CatDetailsPage(cat: cat!),
                  ),
                ),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(cat!.profileImage),
                          radius: 30,
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat!.name,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(cat!.gender,
                                style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(),
            ],
            SizedBox(height: 25),
            Column(
              children: [
                Container(
                  width: 300,  // Fixed width
                  height: 300, // Fixed height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                    image: DecorationImage(
                      image: NetworkImage(usage.image),
                      fit: BoxFit.cover,  // Ensures the image covers the container
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
                        color: Color.fromARGB(255, 209, 209, 209).withOpacity(0.5),
                        spreadRadius: 0.5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usage.condition,
                        style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "${usage.shape} - ${usage.colour}",
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        "${usage.dateTime.day}-${usage.dateTime.month}-${usage.dateTime.year} ${usage.dateTime.hour.toString().padLeft(2, '0')}:${usage.dateTime.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: downloadImage,
                  icon: Icon(Icons.download, color: primaryColor,),
                  label: Text("Download", style: TextStyle(color:primaryColor),),
                ),
                ElevatedButton.icon(
                  onPressed: shareImage,
                  icon: Icon(Icons.share, color: primaryColor,),
                  label: Text("Share",style: TextStyle(color: primaryColor),),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
