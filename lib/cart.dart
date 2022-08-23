import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

import 'order.dart';
import 'refresh.dart';
import 'tiles/cart_tile.dart';

class Cart extends StatefulWidget {
  const Cart({
    Key? key,
  }) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final user = FirebaseAuth.instance.currentUser;
  late final price;
  late final discount;
  @override
  Future gettotalId() async {
    QuerySnapshot qn = await FirebaseFirestore.instance
        .collection('cart')
        .doc('${user!.email}')
        .collection('products')
        .get();
    return qn.docs.length.toString();
  }

  Future gettotal() async {
    int total = 0;
    QuerySnapshot qn = await FirebaseFirestore.instance
        .collection('cart')
        .doc('${user!.email}')
        .collection('products')
        .get();
    for (int i = 0; i < qn.docs.length; i++) {
      total = total + int.parse(qn.docs[i]['price']);
      price = total;
    }
    setState(() {
      price = total;
      return price;
    });
    return total;
  }

  @override
  void initState() {
    gettotal();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black, size: 25),
          actionsIconTheme: const IconThemeData(color: Colors.black, size: 28),
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Row(
            children: const [
              SizedBox(
                width: 8,
              ),
              Text(
                "My Basket",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Refresher(
            refreshbody: SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("cart")
                      .doc(user?.email)
                      .collection('products')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      List<QueryDocumentSnapshot<Object?>> firestoreitems =
                          snapshot.data!.docs;
                      return Wrap(
                          children: List.generate(
                              firestoreitems.length,
                              ((index) => CartTile(
                                    barcode: firestoreitems[index]['barcode'],
                                    image: firestoreitems[index]['image'],
                                    title: firestoreitems[index]['productName'],
                                    desc: firestoreitems[index]['description'],
                                    price: firestoreitems[index]['price']
                                        .toString(),
                                    discount: firestoreitems[index]['discount']
                                        .toString(),
                                    productID: firestoreitems[index]
                                        ['productID'],
                                    onTap: () {
                                      Get.to(() => Order(
                                            url: firestoreitems[index]['image'],
                                            price: firestoreitems[index]
                                                    ['price']
                                                .toString(),
                                            title: firestoreitems[index]
                                                ['productName'],
                                            discount: firestoreitems[index]
                                                    ['discount']
                                                .toString(),
                                            description: firestoreitems[index]
                                                ['description'],
                                            brandStore: firestoreitems[index]
                                                ['brand_store'],
                                            category: firestoreitems[index]
                                                ['category'],
                                            offer: firestoreitems[index]
                                                ['offer'],
                                            productId: firestoreitems[index]
                                                ['productID'],
                                            type: firestoreitems[index]['type'],
                                            barcode: firestoreitems[index]
                                                ['barcode'],
                                          ));
                                    },
                                  ))));
                    }
                  }),
            ),
            refreshitem: const SpinKitHourGlass(
              duration: Duration(milliseconds: 1000),
              color: Color.fromARGB(255, 199, 228, 255),
              size: 25.0,
            ),
          ),
        ),
        bottomNavigationBar: FutureBuilder(
            future: gettotalId(),
            builder: (context, snapshot) {
              return Container(
                margin: EdgeInsets.only(left: 35, bottom: 25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.all(25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FutureBuilder(
                              future: gettotal(),
                              builder: (context, Future) {
                                return Text(
                                  "Total:                   " + '${price}',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w300),
                                );
                              }),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey[700],
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Row(
                        children: <Widget>[
                          Text("Quantity",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              )),
                          SizedBox(
                            width: 200,
                          ),
                          // Text(
                          //     snapshot.data != null ? snapshot.data : 'Loading',
                          //     style: TextStyle(
                          //       fontSize: 18,
                          //       fontWeight: FontWeight.w700,
                          //     )),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        KhaltiScope.of(context).pay(
                          config: PaymentConfig(
                            amount: 100 * 10,
                            productIdentity: 'Counsellor fee',
                            productName: 'widget.counsellorId',
                          ),
                          preferences: [
                            PaymentPreference.khalti,
                          ],
                          onSuccess: (su) async {
                            const successsnackBar = SnackBar(
                              content: Text('Payment Successful'),
                            );
                            // ScaffoldMessenger.of(context)
                            //     .showSnackBar(successsnackBar);
                          },
                          onFailure: (fa) {
                            const failedsnackBar = SnackBar(
                              content: Text('Payment Failed'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(failedsnackBar);
                          },
                          onCancel: () {
                            const cancelsnackBar = SnackBar(
                              content: Text('Payment Cancelled'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(cancelsnackBar);
                          },
                        );
                      },
                      child: GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(right: 25),
                          padding: EdgeInsets.all(25),
                          decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Pay",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          // openCheckout();
                        },
                      ),
                    ),
                  ],
                ),
              );
            }));
  }
}
