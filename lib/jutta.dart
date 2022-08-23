import 'package:captcha/categories/casual.dart';
import 'package:captcha/categories/classic.dart';
import 'package:captcha/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'super_admin_view_page.dart';
import 'categories/all.dart';
import 'categories/kids.dart';
import 'categories/dailyfoods.dart';
import 'categories/sports.dart';
import 'categories/beverage.dart';
import 'list/category_list.dart';
import 'super_admin_user_view_page.dart';
import 'tiles/category_tile.dart';
import 'vendor_admin_view_page.dart';

class Jutta extends StatefulWidget {
  const Jutta({
    Key? key,
  }) : super(key: key);

  @override
  State<Jutta> createState() => _KhanaState();
}

class _KhanaState extends State<Jutta> {
  var option = "All";
  late User user;
  int changeColorandSize = 0;
  int quantity = 1;
  var total;
  var locationMessage = "";
  var address = "";
  var total1;
  var discountPercent;

  swtichfunction() {
    switch (option) {
      case "All":
        return const All();
      case "Daily Foods":
        return const DailyFoods();
      case "Beverage":
        return const Beverage();
      case "Kids":
        return const Kids();
      case "Sports":
        return const Sports();
      case "Classic":
        return const Classic();
      case "Casual":
        return const Casual();
      default:
    }
  }

  Future<void> getUserData() async {
    final userData = await FirebaseAuth.instance.currentUser!;
    setState(() {
      user = userData;
      print(userData.uid);
    });
  }

  Future<DocumentSnapshot<Object?>> getUser() async {
    DocumentSnapshot cn = await FirebaseFirestore.instance
        .collection('users')
        .doc('${user.uid}')
        .get();
    return cn;
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getUserData();
  }

  startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            "#ff6666", "Cancel", true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
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
  }

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

    if (barcodeScanRes != '-1' || barcodeScanRes != null) {
      return showDialog(
          context: context,
          builder: (context) {
            return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .where("barcode", isEqualTo: '$barcodeScanRes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Dialog(
                      child: Container(
                          height: 100,
                          child: Text('Product Not Found',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 50,
                                  color: Colors.red))),
                    );
                  } else {
                    return Dialog(
                      child: Container(
                        height: 350,
                        child: Column(children: [
                          Container(
                              height: 350,
                              width: 165,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data?.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot products =
                                      snapshot.data!.docs[index];
                                  return ScanCard(products: products);
                                },
                              )),
                        ]),
                      ),
                    );
                  }
                });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black, size: 25),
        actionsIconTheme: const IconThemeData(color: Colors.black, size: 28),
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
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
                    var fname = firestoreItems[0]['name'].split(" ");
                    return Text(
                      "HELLO,  " + fname[0].toString().toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }
                }),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => const SearchView());
                  },
                  child: const Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 0, 0, 0),
                    size: 24,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () {
                    String mailUrl =
                        "mailto:shikharaa26@gmail.com?subject=Message to JuttaPasal&body";
                    launchUrl(Uri.parse(mailUrl));
                  },
                  child: const Icon(
                    Icons.message,
                    color: Color.fromARGB(255, 65, 65, 65),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(top: 58),
                width: MediaQuery.of(context).size.width,
                child: swtichfunction(),
              ),
            ),
            Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: SizedBox(
                    width: size.width,
                    height: 35,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryList.length,
                        itemBuilder: (context, index) {
                          return CategoryTile(
                            categoryName: categoryList[index]['name'],
                            onTap: () {
                              setState(() {
                                option = categoryList[index]['name'].toString();
                                changeColorandSize = index;
                              });
                            },
                            color: changeColorandSize == index
                                ? "0xff010101"
                                : "0xffededed",
                            textColor: changeColorandSize == index
                                ? "0xffffffff"
                                : "0xff000000",
                            textSize: changeColorandSize == index ? 13.5 : 12.0,
                          );
                        }),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(right: 20.0, bottom: 20),
              child: Align(
                alignment: Alignment.bottomRight,
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .where('email', isEqualTo: user.email)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("Loading...");
                      } else {
                        List<QueryDocumentSnapshot<Object?>> firestoreUsers =
                            snapshot.data!.docs;
                        return firestoreUsers[0]['role'] == 'vendorAdmin'
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                    FloatingActionButton(
                                      backgroundColor:
                                          const Color.fromARGB(255, 1, 1, 1),
                                      onPressed: () {
                                        Get.to(() => VendorAdminViewPage(
                                              adminRole: firestoreUsers[0]
                                                      ['adminrole']
                                                  .toString(),
                                            ));
                                      },
                                      elevation: 0.0,
                                      child: const Icon(
                                          Icons.admin_panel_settings),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    FloatingActionButton(
                                      backgroundColor:
                                          const Color.fromARGB(255, 8, 241, 47),
                                      onPressed: () {
                                        scanBarcodeNormal();
                                      },
                                      elevation: 0.0,
                                      child: const Icon(
                                        FontAwesomeIcons.barcode,
                                      ),
                                    )
                                  ])
                            : firestoreUsers[0]['role'] == 'user'
                                ? FloatingActionButton(
                                    backgroundColor:
                                        Color.fromARGB(255, 8, 241, 47),
                                    onPressed: () {
                                      scanBarcodeNormal();
                                    },
                                    elevation: 0.0,
                                    child: const Icon(
                                      FontAwesomeIcons.barcode,
                                      color: Colors.black,
                                    ),
                                  )
                                : firestoreUsers[0]['role'] == 'superAdmin'
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          FloatingActionButton(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 40, 40, 40),
                                            onPressed: () {
                                              Get.to(
                                                  const SuperAdminUserViewPage());
                                            },
                                            elevation: 0.0,
                                            child: const Icon(Icons.person),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          FloatingActionButton(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 40, 40, 40),
                                            onPressed: () {
                                              Get.to(
                                                  () => const AdminViewPage());
                                            },
                                            elevation: 0.0,
                                            child: const Icon(Icons.edit),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          FloatingActionButton(
                                            backgroundColor:
                                                Color.fromARGB(255, 8, 241, 47),
                                            onPressed: () {
                                              scanBarcodeNormal();
                                            },
                                            elevation: 0.0,
                                            child: const Icon(
                                              FontAwesomeIcons.barcode,
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      )
                                    : const SizedBox(
                                        height: 10,
                                      );
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final url;
  final String title;
  final price;
  final discount;
  final description;
  final brandStore;
  final category;
  final offer;
  final productId;
  final type;
  final barcode;

  ItemCard(
      {Key? key,
      required this.url,
      required this.price,
      required this.title,
      required this.discount,
      required this.description,
      required this.brandStore,
      required this.category,
      required this.offer,
      required this.productId,
      required this.type,
      required this.barcode,
      required this.products})
      : super(key: key);

  final DocumentSnapshot products;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // String _userId;

    FirebaseAuth.instance.currentUser!.uid;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.0),
          height: 180,
          width: 160,
          decoration: BoxDecoration(
              color: Color(0xFF3D82AE),
              borderRadius: BorderRadius.circular(16)),
          child: Image.network(products['image']),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0 / 4),
          child: Text(
            products['name'],
            style: TextStyle(
              color: Color(0xFF535353),
            ),
          ),
        ),
        Row(
          children: [
            Text(
              "\₹ " + products['price'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 60,
            ),
            GestureDetector(
              child: Icon(
                CupertinoIcons.cart_fill_badge_plus,
                color: Colors.black,
                size: 30,
              ),
              onTap: () async {
                DocumentReference documentReferencer = FirebaseFirestore
                    .instance
                    .collection('cart')
                    .doc(user!.email)
                    .collection('products')
                    .doc();
                Map<String, dynamic> data = <String, dynamic>{
                  'barcode': barcode,
                  'brand_store': brandStore,
                  'productName': title,
                  'description': description,
                  'price': price,
                  'discount': discount,
                  'image': url,
                  'productID': productId,
                  'category': category,
                  'offer': offer,
                  'type': type,
                };
                await documentReferencer
                    .set(data)
                    .then((value) => Navigator.pop(context))
                    .then((value) => Get.snackbar("Added", "Item added to cart",
                        duration: const Duration(milliseconds: 2000),
                        backgroundColor:
                            const Color.fromARGB(126, 255, 255, 255)));
              },
            ),
          ],
        )
      ],
    );
  }
}

class ScanCard extends StatelessWidget {
  const ScanCard({
    Key? key,
    required this.products,
  }) : super(key: key);
  final DocumentSnapshot products;

  @override
  Widget build(BuildContext context) {
    String _userId;
    User? user = FirebaseAuth.instance.currentUser;
    // FirebaseAuth.instance.currentUser!.uid;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10.0),
          height: 180,
          width: 160,
          decoration: BoxDecoration(
              color: Color(0xFF3D82AE),
              borderRadius: BorderRadius.circular(16)),
          child: Image.network(products['image']),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0 / 4),
          child: Text(
            products['productName'],
            style: TextStyle(
              color: Color(0xFF535353),
              fontSize: 18,
            ),
          ),
        ),
        Row(
          children: [
            Text(
              "\₹ " + products['price'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              width: 60,
            ),
            Icon(
              Icons.add_shopping_cart,
              color: Colors.black,
              size: 27,
            ),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Color(0xFF3D82AE),
                child: Text(
                  "Add to Basket",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  DocumentReference documentReference = FirebaseFirestore
                      .instance
                      .collection('cart')
                      .doc(user!.email)
                      .collection('products')
                      .doc();
                  documentReference.set({
                    'barcode': products['barcode'],
                    'brand_store': products['brand_store'],
                    'productName': products['productName'],
                    'description': products['description'],
                    'price': products['price'],
                    'discount': products['discount'],
                    'image': products['image'],
                    'productID': products['productID'],
                    'category': products['category'],
                    'offer': products['offer'],
                    'type': products['type'],
                  }).then((result) {
                    dialogTrigger(context);
                  }).catchError((e) {
                    print(e);
                  });
                }),
          ),
        )
      ],
    );
  }
}

//
Future<Future> dialogTrigger(BuildContext context) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Job done', style: TextStyle(fontSize: 22.0)),
          content: Text(
            'Added Successfully',
            style: TextStyle(fontSize: 20.0),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Alright',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}
