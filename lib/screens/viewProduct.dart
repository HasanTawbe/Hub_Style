// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hub_style/reusable_widgets/reusable_widget.dart';
import 'package:hub_style/screens/products.dart';

import '../utils/color_utils.dart';

class ViewProduct extends StatefulWidget {
  final ProductItem product;

  const ViewProduct({Key? key, required this.product}) : super(key: key);

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  void _addToCart(String size) async {
    if (_user != null) {
      final userId = _user!.uid;
      final productId = widget.product.id;
      final double price = widget.product.price;
      final String name = widget.product.name;
      // Assuming the price is stored in the product object

      // Get the current cart items for the user
      final cartDoc =
          await _firestore.collection('usersCart').doc(userId).get();
      List<Map<String, dynamic>> cartItems = [];

      if (cartDoc.exists) {
        final cartData = cartDoc.data()!;
        final items = cartData['items'];
        if (items != null && items is List) {
          cartItems = List<Map<String, dynamic>>.from(items);
        }
      }

      // Check if the product with the same ID and size already exists in the cart
      final existingItemIndex = cartItems.indexWhere(
          (item) => item['productId'] == productId && item['size'] == size);

      if (existingItemIndex == -1) {
        // Product does not exist in the cart, add a new item
        final newItem = {
          'productId': productId,
          'size': size,
          'quantity': 1, // Set the default quantity to 1
          'price': price,
          'originalprice': price,
          'name': name
          // Set the price from the product object
        };
        cartItems.add(newItem);

        // Update the cart in Firestore
        await _firestore.collection('usersCart').doc(userId).set({
          'items': cartItems,
        });

        // Show a success message or perform any other desired actions
        Fluttertoast.showToast(
          msg: 'Item added to cart',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );

        // Navigate back to the previous screen
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        // Product with the same ID and size already exists in the cart, ignore adding it
        Fluttertoast.showToast(
          msg: 'Item already exists in the cart',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
      }
    }
  }

  int selectedImageIndex = 0;
  bool isExpanded = false;
  String selectedSize = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

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
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: CircleAvatar(
                  backgroundColor: const Color(0xff8f8f8f),
                  radius: 25,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          SizedBox(
                            height:
                                440, // Set a specific height for the PageView
                            child: PageView.builder(
                              itemCount: product.images.length,
                              onPageChanged: (index) {
                                setState(() {
                                  selectedImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Image.network(
                                  product.images[index],
                                  fit: BoxFit.fill,
                                  height: 440,
                                  width: 450,
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 200,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (selectedImageIndex > 0) {
                                      setState(() {
                                        selectedImageIndex--;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_back_ios),
                                  color: Colors.white,
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (selectedImageIndex <
                                        product.images.length - 1) {
                                      setState(() {
                                        selectedImageIndex++;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_forward_ios),
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${product.price.toString()}\$',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9B9B9B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Text.rich(
                    TextSpan(
                      text: isExpanded || product.description.length <= 30
                          ? product.description
                          : '${product.description.substring(0, 30)}...',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        if (!isExpanded && product.description.length > 30)
                          const TextSpan(
                            text: ' Read More',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text(
                  'Size:',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedSize = 'S';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor:
                            selectedSize == 'S' ? Colors.white : Colors.grey,
                        padding: const EdgeInsets.all(15),
                        elevation: selectedSize == 'S' ? 0 : 0,
                        shadowColor: Colors.black,
                      ),
                      child: const Text(
                        'S',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedSize = 'M';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor:
                            selectedSize == 'M' ? Colors.white : Colors.grey,
                        padding: const EdgeInsets.all(15),
                        elevation: selectedSize == 'M' ? 5 : 0,
                        shadowColor: Colors.black,
                      ),
                      child: const Text(
                        'M',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedSize = 'L';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor:
                            selectedSize == 'L' ? Colors.white : Colors.grey,
                        padding: const EdgeInsets.all(15),
                        elevation: selectedSize == 'L' ? 5 : 0,
                        shadowColor: Colors.black,
                      ),
                      child: const Text(
                        'L',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              firebaseButton(context, 'Add to Cart', () {
                _addToCart(selectedSize);
              })
            ],
          ),
        ),
      ),
    );
  }
}
