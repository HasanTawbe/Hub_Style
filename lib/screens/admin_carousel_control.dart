import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/color_utils.dart';
import 'package:hub_style/reusable_widgets/reusable_widget.dart';

class AdminControlCarousel extends StatefulWidget {
  const AdminControlCarousel({Key? key}) : super(key: key);

  @override
  State<AdminControlCarousel> createState() => _AdminControlCarouselState();
}

class _AdminControlCarouselState extends State<AdminControlCarousel> {
  List<XFile>? _selectedImages;
  List<File> _convertedImages = [];
  final firebaseStorage = firebase_storage.FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;
  final CollectionReference carouselImagesCollection =
      FirebaseFirestore.instance.collection('carousel_images');

  bool _isUploading = false;

  Future<void> _uploadImagesToFirebase() async {
    setState(() {
      _isUploading = true;
    });

    if (_convertedImages.length == 4) {
      // Delete old images from Firestore
      try {
        await carouselImagesCollection.doc('Images').update({
          'images': [],
        });
      } catch (e) {
        // Handle error appropriately
      }

      // Delete old images from Firebase Storage
      final oldImagesSnapshot =
          await carouselImagesCollection.doc('Images').get();
      final oldImagesData = oldImagesSnapshot.data() as Map<String, dynamic>;
      final oldImageUrls =
          List<String>.from(oldImagesData['images'] as List<dynamic>);

      for (var imageUrl in oldImageUrls) {
        try {
          await firebaseStorage.ref(imageUrl).delete();
        } catch (e) {
          // Handle error appropriately
        }
      }

      // Upload new images to Firebase Storage
      List<String> imageUrls = [];
      for (var image in _convertedImages) {
        final fileName = path.basename(image.path);
        final destination = 'images/$fileName';
        final uploadTask =
            firebaseStorage.ref().child(destination).putFile(image);
        await uploadTask.whenComplete(() {});
        final downloadUrl = await uploadTask.snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // Update Firestore with the new image URLs
      try {
        await carouselImagesCollection.doc('Images').update({
          'images': imageUrls,
        });

        Fluttertoast.showToast(
          msg: 'Images updated successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } catch (e) {
        // Handle error appropriately
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Please select 4 images',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }

    setState(() {
      _isUploading = false;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _convertedImages.removeAt(index);
      _selectedImages!.removeAt(index);
    });
  }

  Future<void> _openGallery() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );

    setState(() {
      _selectedImages = images;
      _convertedImages = _selectedImages!
          .map((image) => File(image.path))
          .toList()
          .take(4)
          .toList();
    });

    if (_convertedImages.length < 4) {
      Fluttertoast.showToast(
        msg: 'Please select 4 images',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  bool get canSubmit => _convertedImages.length == 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Control Carousel",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
        ),
      ),
      body: Stack(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.8,
                  child: InkWell(
                    onTap: _openGallery,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(75),
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.cloud_upload,
                        size: 60,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                if (_selectedImages != null)
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Selected Images:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _convertedImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final image = entry.value;
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (canSubmit)
                        firebaseButton(
                          context,
                          'Submit',
                          () {
                            _uploadImagesToFirebase();
                          },
                        )
                      else
                        const Text(
                          'Please select 4 images',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),

          // Loading indicator
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
