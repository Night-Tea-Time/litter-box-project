import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/color.dart';
import '../models/usage.dart';

class UsageTile extends StatelessWidget {
  final Usage usage;
  final void Function()? onTap;

  const UsageTile({
    super.key,
    required this.usage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: greyForTile,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            // Clipped image with round corners
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                usage.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 20),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Condition (Normal, Constipation, Diarrhea)
                  Text(
                    usage.condition,
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "${usage.shape} - ${usage.colour}",
                    style: GoogleFonts.fredoka(fontSize: 12),
                  ),
                  Text(
                    "${usage.dateTime.day}-${usage.dateTime.month}-${usage.dateTime.year}  ${usage.dateTime.hour.toString().padLeft(2,'0')}:${usage.dateTime.minute.toString().padLeft(2,'0')}",
                    style: GoogleFonts.fredoka(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
