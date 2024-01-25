// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously, library_private_types_in_public_api, file_names

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/color_utils.dart';

class Product {
  String name;
  final String gender;
  double price;
  final String category;
  final List<String> images;
  final int id;
  String description;
  int smallQuantity;
  int mediumQuantity;
  int largeQuantity;

  Product({
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
}

class ProductCard extends StatelessWidget {
  final Product product;
  final Function() onDelete;
  final Function() onEdit;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String firstImage = product.images.isNotEmpty ? product.images[0] : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.white),
        ),
        color: Colors.grey,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  firstImage,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                'Id: ${product.id}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                product.name,
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Gender: ${product.gender}',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Price: ${product.price}\$',
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                'Category: ${product.category}',
                style: const TextStyle(color: Colors.white),
              ),
              if (product.images.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onDelete,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  const ProductList({Key? key});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List<Product> products = [];
  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    setState(() {
      products = snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: (data['id'] ?? 0.0).toInt(),
          name: data['name'] ?? 'No name available',
          gender: data['Gender'] ?? 'No gender available',
          price: (data['price'] ?? 0.0).toDouble(),
          category: data['Category'] ?? 'No category available',
          images: List<String>.from(data['Images'] ?? []),
          description: data['description'] ?? 'No description available',
          smallQuantity: (data['smallQuantity'] ?? 0).toInt(),
          mediumQuantity: (data['mediumQuantity'] ?? 0).toInt(),
          largeQuantity: (data['largeQuantity'] ?? 0).toInt(),
        );
      }).toList();
      filteredProducts = List.from(products);
    });
  }

  void filterProducts(String query) {
    setState(() {
      filteredProducts = products.where((product) {
        final name = product.name.toLowerCase();
        final id = product.id.toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || id.contains(searchQuery);
      }).toList();
    });
  }

  void deleteProduct(int index) async {
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != null && confirmed) {
      final product = products[index];
      setState(() {
        products.removeAt(index);
      });

      // Delete product's images from Firebase Storage
      for (final image in product.images) {
        final ref = FirebaseStorage.instance.refFromURL(image);
        await ref.delete();
      }

      await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: product.name)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    }
  }

  Future<void> editProduct(int index) async {
    final product = products[index];

    TextEditingController nameController =
        TextEditingController(text: product.name);
    TextEditingController priceController =
        TextEditingController(text: product.price.toString());
    TextEditingController descriptionController =
        TextEditingController(text: product.description);
    TextEditingController smallQuantityController =
        TextEditingController(text: product.smallQuantity.toString());
    TextEditingController mediumQuantityController =
        TextEditingController(text: product.mediumQuantity.toString());
    TextEditingController largeQuantityController =
        TextEditingController(text: product.largeQuantity.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: smallQuantityController,
                  decoration:
                      const InputDecoration(labelText: 'Small Quantity'),
                ),
                TextField(
                  controller: mediumQuantityController,
                  decoration:
                      const InputDecoration(labelText: 'Medium Quantity'),
                ),
                TextField(
                  controller: largeQuantityController,
                  decoration:
                      const InputDecoration(labelText: 'Large Quantity'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                product.name = nameController.text;
                product.price = double.parse(priceController.text);
                product.description = descriptionController.text;
                product.smallQuantity = int.parse(smallQuantityController.text);
                product.mediumQuantity =
                    int.parse(mediumQuantityController.text);
                product.largeQuantity = int.parse(largeQuantityController.text);

                await FirebaseFirestore.instance
                    .collection('products')
                    .where('id', isEqualTo: product.id)
                    .get()
                    .then((querySnapshot) {
                  for (var doc in querySnapshot.docs) {
                    doc.reference.update({
                      'name': product.name,
                      'price': product.price,
                      'description': product.description,
                      'smallQuantity': product.smallQuantity,
                      'mediumQuantity': product.mediumQuantity,
                      'largeQuantity': product.largeQuantity,
                    });
                  }
                });

                setState(() {});

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "View Products",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterProducts,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Container(
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
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 1.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.5,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: filteredProducts[index],
                    onDelete: () => deleteProduct(index),
                    onEdit: () => editProduct(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Product List')),
        body: const ProductList(),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
