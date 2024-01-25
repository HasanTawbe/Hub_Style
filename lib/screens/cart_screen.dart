// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hub_style/reusable_widgets/reusable_widget.dart';
import 'package:hub_style/screens/products.dart';
import 'package:hub_style/screens/profile_page.dart';
import 'package:hub_style/screens/signin_screen.dart';
import 'package:lottie/lottie.dart';
import '../utils/color_utils.dart';
import 'home_screen.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  double total = 0.0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');
  List<Map<String, dynamic>> cartItems = [];
  List<int> itemCounts = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  void fetchCartItems() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final cartSnapshot =
            await _firestore.collection('usersCart').doc(userId).get();
        final items = cartSnapshot.data()?['items'] ?? [];

        // Update cartItems and itemCounts with the fetched data
        setState(() {
          cartItems = List<Map<String, dynamic>>.from(items);
          itemCounts =
              List<int>.from(items.map((item) => item['quantity'] ?? 1));
        });
      }
      // ignore: empty_catches
    } catch (error) {}
  }

  void removeItemFromCart(int index) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;

        // Remove item from Firestore
        await _firestore.collection('usersCart').doc(userId).update({
          'items': FieldValue.arrayRemove([cartItems[index]])
        });

        // Remove item from local cartItems list
        setState(() {
          cartItems.removeAt(index);
          itemCounts.removeAt(index);
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
    return false;
  }

  late LatLng selectedLocation;
  TextEditingController addressController = TextEditingController();

  String address = '';
  String phoneNumber = '';
  String? getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      // Handle the case when the user is not logged in or user is null
      // You can return a default value or throw an exception, depending on your requirement
      return null;
    }
  }

  void showCheckoutDialog(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    String address = '';
    String phoneNumber = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Checkout'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Address',
                  ),
                  onChanged: (value) {
                    address = value; // Update the address variable
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  onChanged: (value) {
                    phoneNumber = value; // Update the phoneNumber variable
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Type of Shipping: Payment on Delivery',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Failed to fetch user data'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          }
                          final userData = snapshot.data?.data();
                          final username = userData is Map<String, dynamic>
                              ? userData['username'] ?? 'N/A'
                              : 'N/A';

                          return AlertDialog(
                            title: const Text('Order Confirmation'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Order Summary:'),
                                  const SizedBox(height: 10),
                                  Text('Username: $username'),
                                  const SizedBox(height: 10),
                                  Text('Address: $address'),
                                  const SizedBox(height: 10),
                                  Text('Phone Number: $phoneNumber'),
                                  const SizedBox(height: 10),
                                  Text('Total: \$${total.toString()}'),
                                  const SizedBox(height: 10),
                                  const Text(
                                      'Cart Items:'), // Display cart items
                                  for (var item in cartItems)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Name: ${item['name']}'),
                                        Text('Quantity: ${item['quantity']}'),
                                        Text('Size: ${item['size']}'),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Confirm Order'),
                                onPressed: () async {
                                  final newOrderRef = FirebaseFirestore.instance
                                      .collection('orders')
                                      .doc(); // Generate a new document ID

                                  // Save order details to Firestore
                                  final orderData = {
                                    'Username': username,
                                    'Address': address,
                                    'PhoneNumber': phoneNumber,
                                    'date': DateTime.now(),
                                    'userid': userId,
                                    'total': total,
                                    'items': cartItems,
                                  };

                                  try {
                                    await newOrderRef.set(orderData);

                                    // Clear the cart items
                                    cartItems.clear();

                                    // Remove cart items from Firestore
                                    final cartRef = FirebaseFirestore.instance
                                        .collection('usersCart')
                                        .doc(userId);
                                    await cartRef.delete();

                                    Navigator.of(context)
                                        .pop(); // Close the dialog

                                    // Show the success animation dialog
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        Future.delayed(
                                            const Duration(seconds: 3), () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Cart()),
                                          );
                                        });

                                        return AlertDialog(
                                          title: const Text('Order Status'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                  'Your order is on delivery!'),
                                              const SizedBox(height: 20),
                                              Lottie.network(
                                                'https://assets4.lottiefiles.com/packages/lf20_ivftmpdk.json',
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                    Fluttertoast.showToast(
                                      msg: 'Thank You for Your Order !',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                    );
                                  } catch (error) {
                                    // Handle error
                                  }
                                },
                              ),
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                              ),
                            ],
                          );
                        } else {
                          return const AlertDialog(
                            title: Text('Loading'),
                            content: LinearProgressIndicator(),
                          );
                        }
                      },
                    );
                  },
                );
              },
              child: const Text('Checkout'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void incrementItem(int index) async {
    final item = cartItems[index];
    final productId = item['productId'].toString();
    final size = item['size'];

    final productSnapshot = await _productsCollection.doc(productId).get();
    final productData = productSnapshot.data() as Map<String, dynamic>;
    final largeQuantity = productData['largeQuantity'];
    final mediumQuantity = productData['mediumQuantity'];
    final smallQuantity = productData['smallQuantity'];

    int maxQuantity;

    switch (size) {
      case 'L':
        maxQuantity = largeQuantity;
        break;
      case 'M':
        maxQuantity = mediumQuantity;
        break;
      case 'S':
        maxQuantity = smallQuantity;
        break;
      default:
        maxQuantity = 0;
        break;
    }

    if (itemCounts[index] < maxQuantity) {
      setState(() {
        itemCounts[index]++;
      });
      updateItemQuantityAndPrice(index);
    } else {
      Fluttertoast.showToast(
        msg: 'No more stock available',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  void decrementItem(int index) async {
    if (itemCounts[index] > 1) {
      setState(() {
        itemCounts[index]--;
      });
      updateItemQuantityAndPrice(index);
    }
  }

  void updateItemQuantityAndPrice(int index) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        final item = cartItems[index];

        final updatedItems = List<Map<String, dynamic>>.from(cartItems);
        updatedItems[index]['quantity'] = itemCounts[index];
        updatedItems[index]['price'] =
            item['originalprice'] * itemCounts[index];

        await _firestore.collection('usersCart').doc(userId).update({
          'items': updatedItems,
        });
      }
    } catch (error) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    double calculateTotalPrice() {
      double totalPrice = 0.0;
      for (int i = 0; i < cartItems.length; i++) {
        final item = cartItems[i];
        final productPrice = item['price'];
        totalPrice += productPrice;
      }
      return totalPrice;
    }

    total = calculateTotalPrice();

    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xff8f8f8f),
                        radius: 25,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_back_ios),
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        width: 270,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Icons.shopping_cart,
                          color: Color(0xff8f8f8f),
                          size: 45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Text(
                    'Shopping Cart',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Text(
                    '${cartItems.length} Items', // Display the length of cartItems
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9B9B9B),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 5,
                    width: 400,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: SizedBox(
                    height: 380,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final productId = item['productId'].toString();
                        final size = item['size'];

                        return Column(
                          children: [
                            FutureBuilder<DocumentSnapshot>(
                              future: _productsCollection.doc(productId).get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return const Text(
                                      'Error retrieving product data');
                                }
                                if (!snapshot.hasData) {
                                  return const Text('Product not found');
                                }

                                final productData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                final productName = productData['name'];
                                final productPrice = productData['price'];
                                final productImages =
                                    productData['Images'] as List<dynamic>;
                                final firstImage = productImages.isNotEmpty
                                    ? productImages[0]
                                    : null;

                                return SizedBox(
                                  height: 100,
                                  child: ListTile(
                                    leading: firstImage != null
                                        ? Image.network(
                                            firstImage,
                                            width: 50,
                                            height: 100,
                                            fit: BoxFit.fitHeight,
                                          )
                                        : const SizedBox(),
                                    title: Text(
                                      '$productName',
                                      style: const TextStyle(
                                        color: Color(0xFF9B9B9B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Size: $size',
                                          style: const TextStyle(
                                            color: Color(0xFF9B9B9B),
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          'Price: \$${productPrice * itemCounts[index]}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            decrementItem(index);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Colors.grey[400],
                                            ),
                                            child: const Icon(Icons.remove,
                                                color: Colors.black),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          itemCounts[index].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () => incrementItem(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Colors.grey[400],
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.black),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              removeItemFromCart(index),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(
                              // Add Divider between items
                              color: Colors.grey,
                              height: 1,
                              thickness: 1,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: SizedBox(
                    height: 1,
                    width: 400,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B9B9B),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Text(
                    'Total: \$$total',
                    style: const TextStyle(
                      color: Color(0xFF9B9B9B),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 5, 0, 0),
                  child: Text(
                    'Delivery Fee: 5\$',
                    style: TextStyle(
                      color: Color(0xFF9B9B9B),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                  child: Text(
                    'Grand Total: \$${total + 5.0}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: firebaseButton(context, 'Check Out', () {
                    showCheckoutDialog(context);
                  }),
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.home,
                  color: Color(0xFF4A4A4A),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Color(0xFF4A4A4A),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const Products(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const Cart(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.person,
                  color: Color(0xFF4A4A4A),
                ),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
