// ignore_for_file: file_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../reusable_widgets/reusable_widget.dart';
import '../utils/color_utils.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
          // Set the width and height of the container to the device's width and height
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          // Set the decoration of the container to a gradient
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Set the direction of the gradient to start from the top and end at the bottom
              colors: [
                hexStringtoColor("535353"),
                hexStringtoColor("373737"),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter New Password", Icons.lock_outlined,
                    false, _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
                firebaseButton(context, "Change Password", () async {
                  try {
                    // Get the current user
                    User? user = FirebaseAuth.instance.currentUser;

                    // Use the updatePassword method to change the user's password
                    await user!.updatePassword(_passwordTextController.text);

                    // Show a success message
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Password changed successfully')));
                  } catch (e) {
                    // Show an error message
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }),
              ],
            ),
          ))),
    );
  }
}
