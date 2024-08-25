import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/cat.dart';
import '../theme/color.dart';
import 'add_cat_image_page.dart';

class AddCatInfoPage extends StatefulWidget {
  final Cat? cat;

  const AddCatInfoPage({super.key, this.cat});

  @override
  State<AddCatInfoPage> createState() => _AddCatInfoPageState();
}

class _AddCatInfoPageState extends State<AddCatInfoPage> {
  String? catProfileImagePath;
  final ImagePicker _picker = ImagePicker();
  String? _selectedGender;
  final _nameController = TextEditingController();

  String? _imageError;
  String? _nameError;
  String? _genderError;

  void _validateAndProceed() {
    setState(() {
      _imageError = catProfileImagePath == null
          ? 'Please add a profile image of your cat'
          : null;
      _nameError = _nameController.text.trim().isEmpty
          ? 'Please enter your cat\'s name'
          : null;
      _genderError =
          _selectedGender == null ? 'Please select your cat\'s gender' : null;
    });

    if (_imageError == null && _nameError == null && _genderError == null) {
      Cat cat = Cat(
        name: _nameController.text.trim(),
        profileImage: catProfileImagePath!,
        gender: _selectedGender!,
      );

      // Navigate to camera page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCatImagePage(cat: cat),
        ),
      );
    }
  }

  Future<void> _showImagePickerDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.camera);
                    setState(() {
                      if (pickedFile != null) {
                        catProfileImagePath = pickedFile.path;
                      }
                    });
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    setState(() {
                      if (pickedFile != null) {
                        catProfileImagePath = pickedFile.path;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    // the page type will be new cat info page if cat is null, else, false.
    // this is to determine the page type
    bool isNewCatType = widget.cat == null? true: false;

    catProfileImagePath = widget.cat?.profileImage;
    print("Cat profile image is ${catProfileImagePath}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              Text(
                "Add New Cat",
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _showImagePickerDialog,
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(75),
                    image: isNewCatType
                        ? // Check if the cat profile path is null
                          (catProfileImagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(catProfileImagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null)
                        : // Display unrecognised cat profile image (http)
                          (catProfileImagePath != null
                              ? DecorationImage(
                                  image: NetworkImage(catProfileImagePath!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                  ),
                  child: catProfileImagePath == null
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              if (_imageError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _imageError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText: "Cat Name",
                  errorText: _nameError,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                hint: const Text('Gender'),
                value: _selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  errorText: _genderError,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validateAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Next",
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
