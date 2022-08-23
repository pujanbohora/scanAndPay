import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class AdminUploadPage extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final brandUploadName;
  const AdminUploadPage({Key? key, this.brandUploadName}) : super(key: key);

  @override
  State<AdminUploadPage> createState() => _AdminUploadPageState();
}

class _AdminUploadPageState extends State<AdminUploadPage> {
  File? file;
  final box = GetStorage();
  var dropDownCategory = "Category";
  var dropDownOffer = "Offer";
  var dropDownType = "Type";
  var dropDownColor = "Color";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    brandController.text = widget.brandUploadName;
    super.initState();
  }

  @override
  void dispose() {
    widget.brandUploadName;
    super.dispose();
  }

  final brandController = TextEditingController();
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final discountController = TextEditingController();
  String? barcode;
  String? _scanBarcode;

  startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            "#ff6666", "Cancel", true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  clearTextInput() {
    titleController.clear();
    descController.clear();
    categoryController.clear();
    priceController.clear();
    discountController.clear();
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  // Widget floatingBar() => Ink(
  //       decoration: ShapeDecoration(
  //         shape: StadiumBorder(),
  //       ),
  //       child: FloatingActionButton.extended(
  //         onPressed: () => scanQR(),
  //         backgroundColor: Colors.black,
  //         icon: Icon(
  //           FontAwesomeIcons.barcode,
  //           color: Colors.white,
  //         ),
  //         label: Text(
  //           "SCAN",
  //           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //     );

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

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
              onTap: clearTextInput,
              child: const Icon(
                Icons.clear,
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Form(
          key: formKey,
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
                                  autofocus: true,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      labelText: "Brand/Store Name"),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) =>
                                      (value != null && value.isEmpty)
                                          ? 'Brand/Store Must Not be Empty'
                                          : null,
                                ),
                                TextFormField(
                                  controller: titleController,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      labelText: "Product Name"),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) =>
                                      (value != null && value.isEmpty)
                                          ? 'Product Name Must Not be Empty'
                                          : null,
                                ),
                                TextFormField(
                                  controller: descController,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                      labelText: "Description"),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) =>
                                      (value != null && value.isEmpty)
                                          ? 'Description Must Not be Empty'
                                          : null,
                                ),
                                TextFormField(
                                  controller: priceController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      const InputDecoration(labelText: "Price"),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) =>
                                      (value != null && value.isEmpty)
                                          ? 'Price Must Not be Empty'
                                          : null,
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
                                Container(
                                  height: 40,
                                  width: 350,
                                  child: Text(
                                    // 'Barcode $_scanBarcode'
                                    'Barcode$_scanBarcode',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.vertical(),
                                    shape: BoxShape.rectangle,
                                  ),
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
                                  decoration: const InputDecoration(
                                      labelText: "Brand/Store Name"),
                                ),
                                TextFormField(
                                  controller: titleController,
                                  autofocus: true,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                      labelText: "Product Name"),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) =>
                                      (value != null && value.isEmpty)
                                          ? 'Product Name Must Not be Empty'
                                          : null,
                                ),
                                TextFormField(
                                  controller: descController,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                      labelText: "Description"),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) =>
                                      (value != null && value.isEmpty)
                                          ? 'Description Must Not be Empty'
                                          : null,
                                ),
                                TextFormField(
                                  controller: priceController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      const InputDecoration(labelText: "Price"),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) =>
                                      (value != null && value.isEmpty)
                                          ? 'Price Must Not be Empty'
                                          : null,
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
                                Container(
                                  height: 40,
                                  width: 350,
                                  child: Text(
                                    // 'Barcode $_scanBarcode'
                                    'Barcode$_scanBarcode',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.vertical(),
                                    shape: BoxShape.rectangle,
                                  ),
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
                            );
                    }
                  }),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    upload(context);
                  },
                  child: const Text("Upload")),
              ElevatedButton(
                  onPressed: () => scanQR(), child: const Text("Scan"))
            ],
          ),
        ),
      )),
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

  Future upload(context) async {
    String url;
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    if (dropDownCategory == "Category") {
      return Get.snackbar('Category Required', "Please insert the category",
          duration: const Duration(milliseconds: 2000),
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.494));
    }

    if (dropDownOffer == "Offer") {
      return Get.snackbar('Offer Required', "Please insert offer",
          duration: const Duration(milliseconds: 2000),
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.494));
    }

    if (dropDownColor == "Color") {
      return Get.snackbar('Colour Required', "Please insert the colour",
          duration: const Duration(milliseconds: 2000),
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.494));
    }

    if (dropDownType == "Type") {
      return Get.snackbar('Type Required', "Please insert the type",
          duration: const Duration(milliseconds: 2000),
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.494));
    }

    if (file == null) {
      // updates without changing image
      return Get.snackbar('Image Required', "Please upload product image",
          duration: const Duration(milliseconds: 2000),
          backgroundColor: const Color.fromRGBO(255, 255, 255, 0.494));
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

          var docid =
              FirebaseFirestore.instance.collection('products').doc().id;
          DocumentReference documentReferencer =
              FirebaseFirestore.instance.collection('products').doc(docid);
          Map<String, dynamic> data = <String, dynamic>{
            'barcode': '$_scanBarcode',
            'brand_store': brandController.text,
            'productName': titleController.text,
            'description': descController.text,
            'price': priceController.text,
            'discount': discountController.text,
            'image': url,
            'productID': docid.trim(),
            'category': dropDownCategory.trim(),
            'offer': dropDownOffer.trim(),
            'type': dropDownType.trim(),
            'color': dropDownColor.trim(),
          };
          await documentReferencer
              .set(data)
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
}
