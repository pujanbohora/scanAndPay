// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class AdminEditPage extends StatefulWidget {
  final brandEditName,
      title,
      desc,
      category,
      price,
      discount,
      image,
      productID,
      offer,
      type,
      color;
  const AdminEditPage(
      {Key? key,
      required this.brandEditName,
      required this.title,
      required this.desc,
      required this.price,
      required this.discount,
      this.image,
      required this.category,
      required this.productID,
      required this.offer,
      required this.type,
      required this.color})
      : super(key: key);

  @override
  State<AdminEditPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminEditPage> {
  File? file;
  final box = GetStorage();

  var dropDownCategory = "Category";
  var dropDownOffer = "Offer";
  var dropDownType = "Type";
  var dropDownColor = "Color";

  @override
  void initState() {
    dropDownCategory = widget.category;
    dropDownOffer = widget.offer;
    dropDownType = widget.type;
    dropDownColor = widget.color;
    brandController.text = widget.brandEditName;
    titleController.text = widget.title;
    categoryController.text = widget.category;
    descController.text = widget.desc;
    priceController.text = widget.price;
    discountController.text = widget.discount;
    super.initState();
  }

  final brandController = TextEditingController();
  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final discountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: GestureDetector(
              onTap: () => deleteProduct(context),
              child: const Icon(
                Icons.delete,
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where('email', isEqualTo: user!.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text(
                        'Loading...',
                      );
                    } else {
                      List<QueryDocumentSnapshot<Object?>> firestoreItems =
                          snapshot.data!.docs;
                      return firestoreItems[0]['adminrole'] == 'superAdmin'
                          ? Column(
                              children: [
                                TextFormField(
                                  controller: brandController,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      labelText: "Brand/Store Name"),
                                ),
                                TextFormField(
                                  controller: titleController,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      labelText: "Product Name"),
                                ),
                                TextFormField(
                                  controller: descController,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                      labelText: "Description"),
                                ),
                                TextFormField(
                                  controller: priceController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      const InputDecoration(labelText: "Price"),
                                ),
                                TextFormField(
                                  controller: discountController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.go,
                                  decoration: const InputDecoration(
                                      labelText: "Discount"),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    DropdownButton<String>(
                                      value: dropDownCategory,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropDownCategory = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        "Category",
                                        'DailyFoods',
                                        'Beverage',
                                        'Kids',
                                        'Daily Foods,Beverage',
                                        'Daily Foods,Kids',
                                        'Beverage,Kids'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                    DropdownButton<String>(
                                      value: dropDownOffer,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropDownOffer = newValue!;
                                        });
                                      },
                                      items: <String>["Offer", 'Yes', 'No']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    DropdownButton<String>(
                                      value: dropDownType,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropDownType = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        "Type",
                                        'Sports',
                                        'Classic',
                                        'Casual'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                    DropdownButton<String>(
                                      value: dropDownColor,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropDownColor = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        "Color",
                                        "No Specific",
                                        "Red",
                                        "Black",
                                        "Blue",
                                        "White",
                                        "Yellow"
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          pickImage(ImageSource.camera);
                                        },
                                        child: const Text("Camera")),
                                    const SizedBox(
                                      width: 40,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          pickImage(ImageSource.gallery);
                                        },
                                        child: const Text("Gallery"))
                                  ],
                                )
                              ],
                            )
                          : Column(
                              children: [
                                TextFormField(
                                  controller: brandController,
                                  readOnly: true,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      labelText: "Brand/Store Name"),
                                ),
                                TextFormField(
                                  controller: titleController,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      labelText: "Product Name"),
                                ),
                                TextFormField(
                                  controller: descController,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                      labelText: "Description"),
                                ),
                                TextFormField(
                                  controller: priceController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      const InputDecoration(labelText: "Price"),
                                ),
                                TextFormField(
                                  controller: discountController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.go,
                                  decoration: const InputDecoration(
                                      labelText: "Discount"),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    DropdownButton<String>(
                                      value: dropDownCategory,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropDownCategory = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        "Category",
                                        'Daily Foods',
                                        'Beverage',
                                        'Kids',
                                        'Daily Foods,Beverage',
                                        'Daily Foods,Kids',
                                        'Beverage,Kids'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                    DropdownButton<String>(
                                      value: dropDownOffer,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropDownOffer = newValue!;
                                        });
                                      },
                                      items: <String>["Offer", 'Yes', 'No']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    DropdownButton<String>(
                                      value: dropDownType,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0)),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropDownType = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        "Type",
                                        'Sports',
                                        'Classic',
                                        'Casual'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                    DropdownButton<String>(
                                      value: dropDownColor,
                                      icon: const Icon(Icons.arrow_downward),
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.deepPurple),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropDownColor = newValue!;
                                        });
                                      },
                                      items: <String>[
                                        "Color",
                                        "No Specific",
                                        "Red",
                                        "Black",
                                        "Blue",
                                        "White",
                                        "Yellow"
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {},
                                        child: const Text("Camera")),
                                    const SizedBox(
                                      width: 40,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {},
                                        child: const Text("Gallery"))
                                  ],
                                )
                              ],
                            );
                    }
                  }),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    update(context);
                  },
                  child: const Text("Edit"))
            ],
          ),
        ),
      ),
    );
  }

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      setState(() {
        file = File(image.path);
        box.write("a", file);
      });
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print("Failed to upload image: $e");
    }
  }

  Future update(context) async {
    String url;
    if (file == null) {
      // updates without changing image
      try {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ));
        DocumentReference documentReferencer = FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productID);
        Map<String, dynamic> data = <String, dynamic>{
          'brand_store': brandController.text,
          'productName': titleController.text,
          'description': descController.text,
          'price': priceController.text,
          'discount': discountController.text,
          'category': dropDownCategory.trim(),
          'offer': dropDownOffer.trim(),
          'type': dropDownType.trim(),
          'color': dropDownColor.trim(),
        };
        await documentReferencer
            .update(data)
            .then(((value) => Get.back()))
            .then(((value) => Get.back()))
            .then((value) => Get.snackbar('Success', 'Successfully Edited',
                duration: const Duration(milliseconds: 2000),
                backgroundColor: const Color.fromARGB(126, 255, 255, 255)));
      } on FirebaseException catch (e) {
        Get.snackbar('Error', e.message.toString(),
            duration: const Duration(milliseconds: 2000),
            backgroundColor: const Color.fromRGBO(255, 255, 255, 0.494));
      }
    } else {
      // updates all
      final fileName = basename(file!.path);
      final destination = 'images/$fileName';
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ));
      try {
        final ref = FirebaseStorage.instance.ref(destination);
        UploadTask uploadTask = ref.putFile(File(file!.path));
        uploadTask.whenComplete(() async {
          url = await ref.getDownloadURL();

          DocumentReference documentReferencer = FirebaseFirestore.instance
              .collection('products')
              .doc(widget.productID);
          Map<String, dynamic> data = <String, dynamic>{
            'brand_store': brandController.text,
            'productName': titleController.text,
            'description': descController.text,
            'price': priceController.text,
            'discount': discountController.text,
            'image': url,
            'category': dropDownCategory.trim(),
            'offer': dropDownOffer.trim(),
            'type': dropDownType.trim(),
            'color': dropDownColor.trim(),
          };
          await documentReferencer
              .update(data)
              .then(((value) => Get.back()))
              .then(((value) => Get.back()))
              .then((value) => Get.snackbar('Success', 'Successfully Edited',
                  duration: const Duration(milliseconds: 2000),
                  backgroundColor: const Color.fromARGB(126, 255, 255, 255)));
        });
      } on FirebaseException catch (e) {
        // ignore: avoid_print
        print(e);

        Get.snackbar('Error', e.message.toString(),
            duration: const Duration(milliseconds: 2000),
            backgroundColor: const Color.fromRGBO(255, 255, 255, 0.494));
      }
    }
  }

  Future deleteProduct(context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productID)
        .delete()
        .then(((value) => Get.back()))
        .then(((value) => Get.back()))
        .then((value) => Get.snackbar('Deleted', 'Successfully Deleted',
            duration: const Duration(milliseconds: 2000),
            backgroundColor: const Color.fromRGBO(255, 255, 255, 0.494)));
  }
}
