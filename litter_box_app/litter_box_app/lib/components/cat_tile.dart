import 'package:flutter/material.dart';
import '../models/cat.dart';

class CatTileSquare extends StatelessWidget {
  final Cat cat;
  final VoidCallback onTap;

  const CatTileSquare({
    Key? key,
    required this.cat,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                cat.profileImage, // Fallback URL
                fit: BoxFit.cover,
                width: 70,
                height: 70, // Adjust height as needed
              ),
            ),
          ),
          Center(
            child: Text(
              cat.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              textAlign: TextAlign.center, // Center align text
            ),
          ),
        ],
      ),
    );
  }
}
