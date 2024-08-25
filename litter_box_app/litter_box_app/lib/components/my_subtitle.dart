import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MySubtitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const MySubtitle({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 5),
        Text(
          title,
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}