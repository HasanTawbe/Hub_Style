// ignore_for_file: file_names, empty_catches

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hub_style/screens/change_password.dart';

import 'package:hub_style/screens/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/color_utils.dart';
import 'home_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String imageUrl = '';
  String _username = '';

  @override
  void initState() {
    super.initState();

    // Fetch the username from Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          _username = snapshot.data()?['username'] ?? '';
          imageUrl = snapshot.data()?['imageUrl'] ?? '';
        });
      }
    });
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String email = currentUser?.email ?? '';

    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.zero,
          child: Container(),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexStringtoColor("535353"),
                hexStringtoColor("373737"),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 25,
                left: 25,
                child: CircleAvatar(
                  backgroundColor: const Color(0xff8f8f8f),
                  radius: 25,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.black,
                  ),
                ),
              ),
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {},
                    child: CircleAvatar(
                      radius: 150,
                      backgroundImage: imageUrl != ''
                          ? NetworkImage(imageUrl
                              // replace with the actual URL of the profile picture
                              )
                          : const NetworkImage(
                              'https://i.pinimg.com/564x/4c/85/31/4c8531dbc05c77cb7a5893297977ac89.jpg'),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 420,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 500,
                left: 40,
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9B9B9B),
                  ),
                ),
              ),
              Positioned(
                top: 530,
                left: 40,
                child: Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9B9B9B),
                  ),
                ),
              ),
              const Positioned(
                top: 590,
                left: 40,
                child: Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9B9B9B),
                  ),
                ),
              ),
              Positioned(
                top: 620,
                left: 50,
                right: 10,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '*****************',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9B9B9B),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangePassword()));
                            },
                            icon: const Icon(Icons.arrow_forward_ios),
                            color: const Color(0xFF9B9B9B),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 680,
                left: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey)),
                  onPressed: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()));
                    });
                  },
                  child: const Text("Logout"),
                ),
              ),
              Positioned(
                top: 680,
                left: 150,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey)),
                  onPressed: () async {
                    ImagePicker imagePicker = ImagePicker();
                    XFile? file = await imagePicker.pickImage(
                        source: ImageSource.gallery);

                    if (file == null) return;

                    String uniquieFileName =
                        DateTime.now().millisecondsSinceEpoch.toString();

                    Reference refrenceRoot = FirebaseStorage.instance.ref();
                    Reference referenceDirImage = refrenceRoot.child('images');
                    Reference referenceImageToUpload =
                        referenceDirImage.child(uniquieFileName);

                    //Store the image
                    try {
                      await referenceImageToUpload.putFile(File(file.path));
                      imageUrl = await referenceImageToUpload.getDownloadURL();

                      final userRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser?.uid);

                      await userRef.update({'imageUrl': imageUrl});

                      setState(() {});
                    } catch (error) {}
                  },
                  child: const Text("Change Profile"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
