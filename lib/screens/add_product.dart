// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use, unnecessary_null_comparison

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:hub_style/reusable_widgets/reusable_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/color_utils.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final List<File> _image = [];
  final List<File> _images = []; // add a list to hold the selected images
  final picker = ImagePicker(); // create an instance of ImagePicker

  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      }
    });
  }

  int _value = 1;
  String? _selectedCategory; // define a variable to hold the selected category
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  final List<String> _categories = ['Shirt', 'Pants', 'All'];
  final TextEditingController _ProductNameTextController =
      TextEditingController();

  final TextEditingController _ProductPriceTextController =
      TextEditingController();

  final TextEditingController _ProductDescriptionTextController =
      TextEditingController();
  final TextEditingController _ProductIdTextController =
      TextEditingController();

  final TextEditingController _quantitySmallTextController =
      TextEditingController();
  final TextEditingController _quantityMediumTextController =
      TextEditingController();
  final TextEditingController _quantityLargeTextController =
      TextEditingController();
  String _selectedGender = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Add Product",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
        ),
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
        )),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20.0, MediaQuery.of(context).size.height * 0.1, 20.0, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 40,
                ),
                numberTextField('Product ID ', _ProductIdTextController),
                const SizedBox(
                  height: 40,
                ),
                adminTextField('Product name ', _ProductNameTextController),
                const SizedBox(
                  height: 40,
                ),
                numberTextField('Price in \$ ', _ProductPriceTextController),
                const SizedBox(
                  height: 40,
                ),
                adminTextField(
                    'Description ', _ProductDescriptionTextController),
                const SizedBox(
                  height: 40,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Gender",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Radio(
                        value: 1,
                        groupValue: _value,
                        fillColor: MaterialStateColor.resolveWith((states) =>
                            _value == 1 ? Colors.white : Colors.grey),
                        onChanged: (value) {
                          _selectedGender = 'male';
                          setState(() {
                            _value = value!;
                            _selectedGender = 'male';
                          });
                        }),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'Male',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Radio(
                        value: 2,
                        groupValue: _value,
                        fillColor: MaterialStateColor.resolveWith((states) =>
                            _value == 2 ? Colors.white : Colors.grey),
                        onChanged: (value) {
                          setState(() {
                            _value = value!;
                            _selectedGender = 'female';
                          });
                        }),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'Female',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Category",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                DropdownButton<String>(
                  dropdownColor: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                  hint: const Text(
                    'Choose Category',
                    style: TextStyle(color: Color(0xFF9B9B9B)),
                  ),
                  value: _selectedCategory,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(
                  height: 40,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Product Image",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: _getImageFromGallery,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(245, 245, 245, 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.upload,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  children: _images.asMap().entries.map((entry) {
                    int index = entry.key;
                    File image = entry.value;
                    return Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(right: 16, bottom: 16),
                          child: Image.file(
                            image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _images.removeAt(index);
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Size And Quantity",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF9B9B9B),
                      ),
                      child: const Center(
                        child: Text(
                          'S',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: numberTextField(
                          'Small Quantity', _quantitySmallTextController),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF9B9B9B),
                      ),
                      child: const Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: numberTextField(
                          'Medium Quantity', _quantityMediumTextController),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF9B9B9B),
                      ),
                      child: const Center(
                        child: Text(
                          'L',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: numberTextField(
                          'Large Quantity', _quantityLargeTextController),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                firebaseButton(context, 'Add Product', () async {
                  List<String> imageUrls = [];
                  Reference referenceRoot =
                      FirebaseStorage.instance.ref().child('images');
                  for (File image in _images) {
                    String imageName =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    Reference imageReference =
                        referenceRoot.child('$imageName.jpg');
                    UploadTask uploadTask = imageReference.putFile(image);

                    await uploadTask.whenComplete(
                        () => null); // Wait for the upload to complete
                    String imageUrl = await imageReference.getDownloadURL();

                    imageUrls.add(imageUrl);

                    // Now you can save the imageUrl or perform any other operation with it
                  }

                  //Taking input
                  num id = num.parse(_ProductIdTextController.text);
                  num price = num.parse(_ProductPriceTextController.text);
                  num smallQuantity =
                      num.parse(_quantitySmallTextController.text);
                  num mediumQuantity =
                      num.parse(_quantityMediumTextController.text);
                  num largeQuantity =
                      num.parse(_quantityLargeTextController.text);

                  FirebaseFirestore.instance
                      .collection('products')
                      .doc(_ProductIdTextController.text)
                      .set({
                    'id': id,
                    'name': _ProductNameTextController.text,
                    'price': price,
                    'description': _ProductDescriptionTextController.text,
                    'Gender': _selectedGender,
                    'Category': _selectedCategory,
                    'Images': imageUrls,
                    'smallQuantity': smallQuantity,
                    'mediumQuantity': mediumQuantity,
                    'largeQuantity': largeQuantity,
                  });
                  Fluttertoast.showToast(
                    msg: 'Product Added Successfully',
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey.withOpacity(
                        0.8), // Set the background color to transparent grey
                    textColor: Colors.black,
                    fontSize: 16.0,
                  );
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  chooseImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
    });
    if (pickedFile!.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostData response = await picker.getLostData();
    if (response.file != null) {
      setState(() {
        _image.add(File(response.file!.path));
      });
    } else {}
  }
}
