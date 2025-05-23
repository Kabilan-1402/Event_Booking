import 'dart:io';

import 'package:booking_event/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

class UploadEvent extends StatefulWidget {
  UploadEvent({Key? key}) : super(key: key);

  @override
  State<UploadEvent> createState() => UploadEventState();
}

class UploadEventState extends State<UploadEvent> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  List<String> eventCategory = ["Music", "Food", "Clothing", "Festival"];

  String? dropdownValue;
  ImagePicker _picker = ImagePicker();
  File? selectedImage;

  DateTime? selectedDate = DateTime.now();
  TimeOfDay? selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    dropdownValue = eventCategory.first;
    _signInAnonymously();
  }

  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      print("Signed in anonymously: ${FirebaseAuth.instance.currentUser?.uid}");
    } catch (e) {
      print("Anonymous sign-in failed: $e");
    }
  }

  Future<void> _getImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _upload() async {
    String imageUrl = "";
    if (selectedImage != null) {
      String imgId = randomAlphaNumeric(10);
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("blogImages")
          .child(imgId);
      try {
        // await the upload but don’t assign it to a local variable
        await ref.putFile(selectedImage!);
        imageUrl = await ref.getDownloadURL();
      } catch (e) {
        print("Image upload failed: $e");
      }
    }

    User currentUser = FirebaseAuth.instance.currentUser!;
    Map<String, dynamic> data = {
      "ownerId": currentUser.uid,
      "Image": imageUrl,
      "Name": nameController.text.trim(),
      "Price": priceController.text.trim(),
      "Category": dropdownValue ?? "",
      "Location": locationController.text.trim(),
      "Details": detailController.text.trim(),
      "Date": DateFormat('yyyy-MM-dd').format(selectedDate!),
      "Time": selectedTime!.format(context),
    };

    String docId = randomAlphaNumeric(10);
    try {
      await DatabaseMethods().addEvent(data, docId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("Event uploaded successfully!"),
        ),
      );
      setState(() {
        nameController.clear();
        priceController.clear();
        detailController.clear();
        locationController.clear();
        dropdownValue = eventCategory.first;
        selectedImage = null;
        selectedDate = DateTime.now();
        selectedTime = TimeOfDay.now();
      });
    } catch (e) {
      print("Database write failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Upload failed!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text("Upload Event",
                style: TextStyle(color: Colors.white, fontSize: 25))),
        backgroundColor: Color(0xff6351ec),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _getImage,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(selectedImage!, fit: BoxFit.cover),
                    )
                        : Icon(Icons.camera_alt_outlined, size: 50),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text("Event Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: Color(0xffececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      hintText: "  Enter Event Name", border: InputBorder.none),
                ),
              ),
              SizedBox(height: 20),
              Text("Ticket Price",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: Color(0xffececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "   Enter Price", border: InputBorder.none),
                ),
              ),
              SizedBox(height: 20),
              Text("Event Location",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: Color(0xffececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                      hintText: "   Enter a Location", border: InputBorder.none),
                ),
              ),
              SizedBox(height: 20),
              Text("Select Category",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: dropdownValue,
                items: eventCategory
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    dropdownValue = v;
                  });
                },
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              Text("Date & Time",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month,
                            color: Colors.blue, size: 30),
                        SizedBox(width: 10),
                        Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate!),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 90),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Row(
                      children: [
                        Icon(Icons.alarm, color: Colors.blue, size: 30),
                        SizedBox(width: 10),
                        Text(
                          selectedTime!.format(context),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text("Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: Color(0xffececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: detailController,
                  maxLines: 4,
                  decoration: InputDecoration(
                      hintText: "   What will be on the event",
                      border: InputBorder.none),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _upload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff6351ec),
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.1, vertical: height * 0.01),
                  ),
                  child: Text("Upload",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 26)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
