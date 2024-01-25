import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hub_style/reusable_widgets/reusable_widget.dart';
import 'package:hub_style/screens/ProductList.dart';

import 'package:hub_style/screens/add_product.dart';
import 'package:hub_style/screens/admin_carousel_control.dart';
import 'package:hub_style/screens/customer_orders.dart';
import 'package:hub_style/screens/manage_account.dart';
import 'package:hub_style/screens/signin_screen.dart';

import 'package:hub_style/utils/color_utils.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_label
    debugShowCheckedModeBanner:
    false;
    return Scaffold(
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
        )),
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20.0, MediaQuery.of(context).size.height * 0.1, 20.0, 0),
              child: Column(
                children: <Widget>[
                  const Text(
                    'Hello Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  firebaseButton(context, 'Add New Product', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddProduct()));
                  }),
                  const SizedBox(
                    height: 30,
                  ),
                  firebaseButton(context, 'View All Products', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProductList()));
                  }),
                  const SizedBox(
                    height: 30,
                  ),
                  firebaseButton(context, 'Control Carousel', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AdminControlCarousel()));
                  }),
                  const SizedBox(
                    height: 30,
                  ),
                  firebaseButton(context, 'Customers Orders', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CustomerOrders()));
                  }),
                  const SizedBox(
                    height: 30,
                  ),
                  firebaseButton(context, 'Manage Accounts', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Manage_Account()));
                  }),
                  const SizedBox(
                    height: 30,
                  ),
                  firebaseButton(context, 'Logout', () {
                    FirebaseAuth.instance.signOut().then((value) =>
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignInScreen())));
                  }),
                ],
              )),
        ),
      ),
    );
  }
}
