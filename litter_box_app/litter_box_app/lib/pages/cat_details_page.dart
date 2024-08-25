import 'package:cat_monitoring_app/firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/usage_tile.dart';
import '../models/cat.dart';
import '../models/usage.dart';
import '../theme/color.dart';
import 'stool_details_page.dart';

class CatDetailsPage extends StatelessWidget {
  final Cat cat;

  const CatDetailsPage({
    super.key,
    required this.cat,
  });

  Future<String> latestUsage(String catId) async {
    Usage? lu = await fetchLatestUsageByCatId(catId);
    if (lu != null) {
      return "${lu.dateTime.day}-${lu.dateTime.month}-${lu.dateTime.year}  ${lu.dateTime.hour.toString().padLeft(2, '0')}:${lu.dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "-";
    }
  }

  Widget _buildCatImage() {
    return SizedBox(
        height: 400,
        width: 400,
        child: ClipPath(
          clipper: MyCustomClipper(),
          child: Container(
            color: Colors.orange,
            child: AspectRatio(
              aspectRatio: 16 / 9, // Adjust aspect ratio if needed (optional)
              child: Image.network(
                cat.profileImage, // Fallback URL
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
  }

  Widget _buildAndroid(BuildContext context) {
    Color genderColor = cat.gender == "Female"
        ? const Color.fromARGB(151, 255, 64, 128)
        : const Color.fromARGB(110, 33, 149, 243);
    IconData genderIcon = cat.gender == "Female" ? Icons.female : Icons.male;

    return Scaffold(
      body: ListView(
        children: [
          // image
          _buildCatImage(),

          // information
          Padding(
            padding: const EdgeInsets.all(25),
            child: Container(
              margin: EdgeInsets.only(left: 25, right: 25, top: 10),
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
              child: ListTile(
                minTileHeight: 60,
                title: Text(
                  cat.name,
                  style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                trailing: Container(
                    decoration: BoxDecoration(
                        color: genderColor,
                        borderRadius: BorderRadius.circular(5)),
                    child: Icon(
                      genderIcon,
                      size: 30,
                    )),
              ),
            ),
          ),

          // About
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Row(
              children: [
                Icon(Icons.pets),
                const SizedBox(width: 5),
                Text(
                  "About Cat",
                  style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),

          // show the datetime of last use
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
            child: Column(
              children: [
                const SizedBox(height: 10),
                FutureBuilder<String>(
                  future: latestUsage(cat.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return Text('No usage data available');
                    } else {
                      return MyListTile(
                        title: "Last Use of Litterbox",
                        subtitle: snapshot.data!,
                        width: 300,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          //litterbox usage history
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 50, top: 10),
            child: Row(
              children: [
                Icon(Icons.pets),
                const SizedBox(width: 5),
                Text(
                  "Litter Box Usage History",
                  style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),

          Container(
            height: 300,
            padding: EdgeInsets.only(left: 50, right: 50),
            child: FutureBuilder<List<Usage>>(
              future: fetchUsagesByCatId(cat.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No usages available'));
                }

                List<Usage> usages = snapshot.data!;

                return ListView.builder(
                  itemCount: usages.length,
                  itemBuilder: (context, index) => UsageTile(
                    usage: usages[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StoolDetailsPage(cat: cat, usage: usages[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 30,
            right: 15,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(context) {
    return _buildAndroid(context);
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, size.height - 50, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double width;

  const MyListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle),
        ],
      ),
    );
  }
}
