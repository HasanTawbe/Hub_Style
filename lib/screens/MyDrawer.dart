// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String _username = '';
  String imageUrl = '';

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

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String email = currentUser?.email ?? '';
    return Container(
      color: Colors.grey,
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            height: 70.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageUrl != ''
                      ? NetworkImage(imageUrl)
                      : const NetworkImage(
                          'https://i.pinimg.com/564x/4c/85/31/4c8531dbc05c77cb7a5893297977ac89.jpg'),
                )),
          ),
          Text(
            _username,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 20,
            ),
          ),
          Text(
            email,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }
}
