import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cat_monitoring_app/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../firebase/firebase.dart';
import '../models/cat.dart';
import '../theme/color.dart';

class AddCatImagePage extends StatefulWidget {
  final Cat cat;
  const AddCatImagePage({super.key, required this.cat});

  @override
  State<AddCatImagePage> createState() => _AddCatImagePageState();
}

class _AddCatImagePageState extends State<AddCatImagePage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  int currentStep = 0;
  final List<String> instructions = ["front", "left", "back", "right"];
  final List<String> imagePaths = [];
  bool _showFlash = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;

      // Generate a unique name for the image
      final imageName = '${instructions[currentStep]}.jpg';

      final image = await _controller!.takePicture();

      // Rename the image file
      final directory = await getTemporaryDirectory();
      final newPath = '${directory.path}/$imageName';
      await File(image.path).copy(newPath);

      setState(() {
        imagePaths.add(newPath);
        _showFlash = true;

        // Turn off flash effect after 300 milliseconds
        Timer(Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _showFlash = false;
            });
          }
        });

        if (currentStep < instructions.length - 1) {
          currentStep++;
        } else {
          // All pictures taken, handle accordingly
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DisplayPicturesScreen(
                cat: widget.cat, // Pass the Cat object
                imagePaths: imagePaths,
              ),
            ),
          );
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // return device height and width
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox(
                  width: size.width,
                  height: size.height,
                  child: CameraPreview(_controller!),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),

          // Flash when image taken
          Visibility(
            visible: _showFlash,
            child: Container(
              color: Colors.white.withOpacity(0.7),
              width: size.width,
              height: size.height,
            ),
          ),

          // Instruction text
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 170.0),
              child: Text(
                instructions[currentStep],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Take image button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: SizedBox(
                height: 80,
                width: 80,
                child: FloatingActionButton(
                  shape: CircleBorder(),
                  backgroundColor: Colors.white,
                  child: Icon(Icons.circle, color: primaryColor, size: 50),
                  onPressed: _takePicture,
                ),
              ),
            ),
          ),

          // Close window button
          Positioned(
            top: 30,
            right: 15,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final Cat cat;
  final String imagePath;

  const DisplayPictureScreen({
    Key? key,
    required this.cat,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display Picture')),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}

class DisplayPicturesScreen extends StatelessWidget {
  final Cat cat;
  final List<String> imagePaths;

  DisplayPicturesScreen({required this.cat, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios),
        title: Text(
          "Please Comfirm",
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cat profile details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: FileImage(File(cat.profileImage)),
                  radius: 30,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(cat.gender,
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          Divider(),

          // Images
          Expanded(
            child: ListView.builder(
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(File(imagePaths[index])),
                );
              },
            ),
          ),

          // Confirm button
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: MyButton(
                  onTap: () async {

                    //show loading
                    showDialog(
                      context: context,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    await addNewCat(cat, imagePaths);

                    // go to home page after saving
                    Navigator.pushNamed(context, '/homepage');
                  },
                  text: "Confirm")),
        ],
      ),
    );
  }
}
