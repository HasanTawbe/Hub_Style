// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hub_style/screens/cart_screen.dart';
import 'package:hub_style/screens/profile_page.dart';

import 'package:hub_style/screens/help_and_support.dart';
import 'package:hub_style/screens/mainPage.dart';
import 'package:hub_style/screens/pants_product.dart';
import 'package:hub_style/screens/privacy_policy.dart';
import 'package:hub_style/screens/settings_page.dart';
import 'package:hub_style/screens/signin_screen.dart';
import 'package:hub_style/utils/color_utils.dart';

import 'MyDrawer.dart';

class ShirtProduct extends StatefulWidget {
  const ShirtProduct({Key? key}) : super(key: key);

  @override
  State<ShirtProduct> createState() => _ShirtProductState();
}

class _ShirtProductState extends State<ShirtProduct> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  var currentPage = DrawerSections.profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const MyDrawer(),
              MyDrawerList(),
            ],
          ),
        ),
      ),
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
                    _globalKey.currentState!.openDrawer();
                  },
                  icon: const Icon(Icons.menu),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: -10,
              left: MediaQuery.of(context).size.width * 0.5 - 68,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.transparent,
                ),
                child: Image.asset(
                  'assets/images/StyleHub.png',
                  width: 130,
                  height: 130,
                ),
              ),
            ),
            Positioned(
              top: 25,
              right: 25,
              child: CircleAvatar(
                backgroundColor: const Color(0xff8f8f8f),
                radius: 25,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()));
                  },
                  icon: const Icon(Icons.person),
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Text(
                    'Shop with confidence today!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xffc3c3c3),
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xff8f8f8f),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.search,
                            color: Color(0xffc3c3c3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: Color(0xffc3c3c3),
                              ),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ShirtProduct()));
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: const Color(0xff8f8f8f),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size(100, 30),
                        ),
                        child: const Text('Shirt'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PantsProduct()));
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color(0xffc3c3c3),
                          backgroundColor: const Color(0xff8f8f8f),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size(100, 30),
                        ),
                        child: const Text('Pants'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color(0xffc3c3c3),
                          backgroundColor: const Color(0xff8f8f8f),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size(100, 30),
                        ),
                        child: const Text('All'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CarouselSlider(
                    items: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                            'https://via.placeholder.com/350x150'),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                            'https://via.placeholder.com/350x150'),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                            'https://via.placeholder.com/350x150'),
                      ),
                    ],
                    options: CarouselOptions(
                      height: 150,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.8,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        // handle page change here
                      },
                      scrollDirection: Axis.horizontal,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget MyDrawerList() {
    return Container(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        children: [
          menuItem(1, "Profile", Icons.person,
              currentPage == DrawerSections.profile ? true : false),
          menuItem(2, "Cart", Icons.shopping_cart_outlined,
              currentPage == DrawerSections.cart ? true : false),
          menuItem(3, "Settings", Icons.settings,
              currentPage == DrawerSections.settings ? true : false),
          menuItem(4, "Help And Support", Icons.help_outline,
              currentPage == DrawerSections.helpandSupport ? true : false),
          menuItem(5, "Privacy Policy", Icons.policy_outlined,
              currentPage == DrawerSections.privacy_policy ? true : false),
          menuItem(6, "Log Out", Icons.logout,
              currentPage == DrawerSections.logout ? true : false),
        ],
      ),
    );
  }

  Widget menuItem(int id, String title, IconData icon, bool selected) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.pop(context);

          if (id == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfilePage()));
          } else if (id == 2) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Cart()));
          } else if (id == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Settings()));
          } else if (id == 4) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HelpAndSupport()));
          } else if (id == 5) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicy()));
          } else if (id == 6) {
            FirebaseAuth.instance.signOut().then((value) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignInScreen()));
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 6,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
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

enum DrawerSections {
  account,
  helpandSupport,
  cart,
  profile,
  logout,
  settings,
  privacy_policy,
}
