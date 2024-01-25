import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:hub_style/screens/cart_screen.dart';
import 'package:hub_style/screens/profile_page.dart';
import 'package:hub_style/screens/signin_screen.dart';
import 'package:hub_style/screens/products.dart';
// Replace with the actual path to the sign-in screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navBarIndex = 0;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    getCarouselImages();
  }

  void getCarouselImages() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('carousel_images')
          .doc('Images')
          .get();

      final data = snapshot.data() as Map<String, dynamic>;
      final images = data['images'] as List<dynamic>;
      final urls = images.map((imageUrl) => imageUrl.toString()).toList();

      setState(() {
        imageUrls = urls;
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_navBarIndex != 0) {
          setState(() {
            _navBarIndex = 0;
          });
          return false; // Prevent the default back navigation
        }
        return true; // Allow the default back navigation
      },
      child: Scaffold(
        body: Stack(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                onPageChanged: (index, reason) {
                  setState(() {});
                },
                scrollDirection: Axis.vertical,
                scrollPhysics: const ClampingScrollPhysics(),
                pageSnapping: true,
                reverse: false,
                enlargeCenterPage: false,
                aspectRatio: 2.0,
                initialPage: 0,
              ),
              items: imageUrls.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _navBarIndex,
          onTap: (index) {
            setState(() {
              _navBarIndex = index;
            });

            if (index == 0) {
              // Home tab
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            } else if (index == 1) {
              // Search tab
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Products()),
              );
            } else if (index == 2 || index == 3) {
              // Shopping Bag and Profile tabs
              FirebaseAuth auth = FirebaseAuth.instance;
              if (auth.currentUser != null) {
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Cart()),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                }
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              }
            }
          },
          backgroundColor: Colors.grey[400],
          selectedItemColor: Colors.black,
          unselectedItemColor: const Color(0xFF4A4A4A),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Shopping Bag',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
