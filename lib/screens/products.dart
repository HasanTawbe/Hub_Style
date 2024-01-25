import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hub_style/screens/profile_page.dart';
import 'package:hub_style/screens/signin_screen.dart';
import 'package:hub_style/screens/viewProduct.dart';

import '../utils/color_utils.dart';
import 'cart_screen.dart';
import 'home_screen.dart';

class FavoritesHelper {
  static Future<void> addToFavorites(int productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final favoritesCollection =
          FirebaseFirestore.instance.collection('usersFavorites');
      final favoriteDoc = favoritesCollection.doc(userId);

      final favoritesData = await favoriteDoc.get();
      final favorites = favoritesData.data()?['favorites'] ?? [];

      if (favorites.contains(productId)) {
        // Remove the product from favorites
        await favoriteDoc.update({
          'favorites': FieldValue.arrayRemove([productId]),
        });
        Fluttertoast.showToast(
          msg: 'Item removed from favorites',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        // Add the product to favorites
        await favoriteDoc.update({
          'favorites': FieldValue.arrayUnion([productId]),
        });
        Fluttertoast.showToast(
          msg: 'Item added to favorites',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }
}

class ProductItem {
  ProductItem({
    required this.name,
    required this.gender,
    required this.price,
    required this.images,
    required this.category,
    required this.id,
    required this.description,
    required this.smallQuantity,
    required this.mediumQuantity,
    required this.largeQuantity,
  });

  final String category;
  String description;
  final String gender;
  final int id;
  final List<String> images;
  int largeQuantity;
  int mediumQuantity;
  String name;
  double price;
  int smallQuantity;
}

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<List<ProductItem>> fetchProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    final products = <ProductItem>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final images = List<String>.from(data['Images'] ?? []);
      final name = data['name'] as String? ?? '';
      final price = (data['price'] as num?)?.toDouble() ?? 0.0;

      final product = ProductItem(
        name: name,
        gender: data['Gender'] as String? ?? '',
        price: price,
        images: images,
        category: data['Category'] as String? ?? '',
        id: data['id'] as int? ?? 0,
        description: data['description'] as String? ?? '',
        smallQuantity: data['smallQuantity'] as int? ?? 0,
        mediumQuantity: data['mediumQuantity'] as int? ?? 0,
        largeQuantity: data['largeQuantity'] as int? ?? 0,
      );

      products.add(product);
    }

    return products;
  }

  List<ProductItem> filterProducts(List<ProductItem> products) {
    if (_searchQuery.isEmpty) {
      return products;
    }

    return products.where((product) {
      final productName = product.name.toLowerCase();
      final productGender = product.gender.toLowerCase();
      final productCategory = product.category.toLowerCase();
      final productPrice = product.price;

      final searchQuery = _searchQuery.toLowerCase();
      final parsedPrice = double.tryParse(searchQuery);

      return productName.contains(searchQuery) ||
          productGender == searchQuery ||
          productCategory.contains(searchQuery) ||
          (parsedPrice != null && productPrice < parsedPrice);
    }).toList();
  }

  Future<void> addToFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final favoritesCollection =
          FirebaseFirestore.instance.collection('usersFavorites');
      final favoriteDoc = favoritesCollection.doc(userId);

      await favoriteDoc.set({
        'favorites': FieldValue.arrayUnion(['hello']),
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: null,
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Shirt'),
              Tab(text: 'Pants'),
              Tab(icon: Icon(Icons.favorite))
            ],
            labelColor: Colors.black,
            unselectedLabelColor: const Color(0xFF4A4A4A),
            indicatorColor: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
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
                  child: FutureBuilder<List<ProductItem>>(
                    future: fetchProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final products = filterProducts(snapshot.data ?? []);

                      if (products.isEmpty) {
                        return const Center(child: Text('No products found.'));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return GestureDetector(
                            onTap: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ViewProduct(
                                        product:
                                            product), // Pass the selected product
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SignInScreen(),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      product.images.first,
                                      fit: BoxFit.fill,
                                      height: 270,
                                      width: 190,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('usersFavorites')
                                          .doc(FirebaseAuth
                                              .instance.currentUser?.uid)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final favorites =
                                              (snapshot.data?.data()
                                                              as Map<String,
                                                                  dynamic>?)?[
                                                          'favorites']
                                                      as List<dynamic>? ??
                                                  [];
                                          final isFavorite =
                                              favorites.contains(product.id);

                                          return IconButton(
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                            ),
                                            onPressed: () {
                                              FavoritesHelper.addToFavorites(
                                                  product.id);
                                            },
                                            color: isFavorite
                                                ? Colors.red
                                                : Colors.white,
                                            splashColor: Colors.red,
                                          );
                                        }
                                        return IconButton(
                                          icon:
                                              const Icon(Icons.favorite_border),
                                          onPressed: () {
                                            FavoritesHelper.addToFavorites(
                                                product.id);
                                          },
                                          color: Colors.white,
                                          splashColor: Colors.red,
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Spacer(),
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(
                                              ' \$${product.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            if (product.gender == 'male')
                                              const Icon(Icons.male,
                                                  color: Colors.blue),
                                            if (product.gender == 'female')
                                              const Icon(Icons.female,
                                                  color: Colors.pink),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
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
                  child: FutureBuilder<List<ProductItem>>(
                    future: fetchProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final products = filterProducts(snapshot.data ?? [])
                          .where((product) =>
                              product.category.toLowerCase() == 'shirt')
                          .toList();

                      if (products.isEmpty) {
                        return const Center(child: Text('No products found.'));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return GestureDetector(
                            onTap: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ViewProduct(
                                        product:
                                            product), // Pass the selected product
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SignInScreen(),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      product.images.first,
                                      fit: BoxFit.fill,
                                      height: 270,
                                      width: 190,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('usersFavorites')
                                          .doc(FirebaseAuth
                                              .instance.currentUser?.uid)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final favorites =
                                              (snapshot.data?.data()
                                                              as Map<String,
                                                                  dynamic>?)?[
                                                          'favorites']
                                                      as List<dynamic>? ??
                                                  [];
                                          final isFavorite =
                                              favorites.contains(product.id);
                                          return IconButton(
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                            ),
                                            onPressed: () {
                                              FavoritesHelper.addToFavorites(
                                                  product.id);
                                            },
                                            color: isFavorite
                                                ? Colors.red
                                                : Colors.white,
                                            splashColor: Colors.red,
                                          );
                                        }
                                        return IconButton(
                                          icon:
                                              const Icon(Icons.favorite_border),
                                          onPressed: () {
                                            FavoritesHelper.addToFavorites(
                                                product.id);
                                          },
                                          color: Colors.white,
                                          splashColor: Colors.red,
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Spacer(),
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(
                                              ' \$${product.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            if (product.gender == 'male')
                                              const Icon(Icons.male,
                                                  color: Colors.blue),
                                            if (product.gender == 'female')
                                              const Icon(Icons.female,
                                                  color: Colors.pink),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
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
                  child: FutureBuilder<List<ProductItem>>(
                    future: fetchProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final products = filterProducts(snapshot.data ?? [])
                          .where((product) =>
                              product.category.toLowerCase() == 'pants')
                          .toList();

                      if (products.isEmpty) {
                        return const Center(child: Text('No products found.'));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return GestureDetector(
                            onTap: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ViewProduct(
                                        product:
                                            product), // Pass the selected product
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SignInScreen(),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      product.images.first,
                                      fit: BoxFit.fill,
                                      height: 270,
                                      width: 190,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('usersFavorites')
                                          .doc(FirebaseAuth
                                              .instance.currentUser?.uid)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final favorites =
                                              (snapshot.data?.data()
                                                              as Map<String,
                                                                  dynamic>?)?[
                                                          'favorites']
                                                      as List<dynamic>? ??
                                                  [];
                                          final isFavorite =
                                              favorites.contains(product.id);
                                          return IconButton(
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                            ),
                                            onPressed: () {
                                              FavoritesHelper.addToFavorites(
                                                  product.id);
                                            },
                                            color: isFavorite
                                                ? Colors.red
                                                : Colors.white,
                                            splashColor: Colors.red,
                                          );
                                        }
                                        return IconButton(
                                          icon:
                                              const Icon(Icons.favorite_border),
                                          onPressed: () {
                                            FavoritesHelper.addToFavorites(
                                                product.id);
                                          },
                                          color: Colors.white,
                                          splashColor: Colors.red,
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Spacer(),
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(
                                              ' \$${product.price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            if (product.gender == 'male')
                                              const Icon(Icons.male,
                                                  color: Colors.blue),
                                            if (product.gender == 'female')
                                              const Icon(Icons.female,
                                                  color: Colors.pink),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
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
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('usersFavorites')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final favoritesData =
                          snapshot.data?.data() as Map<String, dynamic>?;

                      if (favoritesData == null || favoritesData.isEmpty) {
                        return const Center(
                            child: Text('No favorite products found.'));
                      }

                      final favorites =
                          favoritesData['favorites'] as List<dynamic>;

                      if (favorites.isEmpty) {
                        return const Center(
                            child: Text('No favorite products found.'));
                      }

                      return FutureBuilder<List<ProductItem>>(
                        future: fetchProducts(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          final products = snapshot.data ?? [];

                          final favoriteProducts = products
                              .where(
                                  (product) => favorites.contains(product.id))
                              .toList();

                          if (favoriteProducts.isEmpty) {
                            return const Center(
                                child: Text('No favorite products found.'));
                          }

                          return CustomScrollView(
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.all(10),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.55,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final product = favoriteProducts[index];
                                      return GestureDetector(
                                        onTap: () {
                                          // Handle tapping on the favorite product
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ViewProduct(
                                                product: product,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                  product.images.first,
                                                  fit: BoxFit.fill,
                                                  height: 270,
                                                  width: 190,
                                                ),
                                              ),
                                              Positioned(
                                                top: 10,
                                                right: 10,
                                                child: StreamBuilder<
                                                    DocumentSnapshot>(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'usersFavorites')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser?.uid)
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      final favorites = (snapshot
                                                                          .data
                                                                          ?.data()
                                                                      as Map<String,
                                                                          dynamic>)[
                                                                  'favorites']
                                                              as List<
                                                                  dynamic>? ??
                                                          [];
                                                      final isFavorite =
                                                          favorites.contains(
                                                              product.id);
                                                      return IconButton(
                                                        icon: Icon(
                                                          isFavorite
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                        ),
                                                        onPressed: () {
                                                          FavoritesHelper
                                                              .addToFavorites(
                                                                  product.id);
                                                        },
                                                        color: isFavorite
                                                            ? Colors.red
                                                            : Colors.white,
                                                        splashColor: Colors.red,
                                                      );
                                                    }
                                                    return IconButton(
                                                      icon: const Icon(Icons
                                                          .favorite_border),
                                                      onPressed: () {
                                                        FavoritesHelper
                                                            .addToFavorites(
                                                                product.id);
                                                      },
                                                      color: Colors.white,
                                                      splashColor: Colors.red,
                                                    );
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Spacer(),
                                                    Text(
                                                      product.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          ' \$${product.price.toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                        if (product.gender ==
                                                            'male')
                                                          const Icon(Icons.male,
                                                              color:
                                                                  Colors.blue),
                                                        if (product.gender ==
                                                            'female')
                                                          const Icon(
                                                              Icons.female,
                                                              color:
                                                                  Colors.pink),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    childCount: favoriteProducts.length,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
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
                color: Colors.black,
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
                color: Color(0xFF4A4A4A),
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
    );
  }
}
