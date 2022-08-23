import 'package:captcha/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:provider/provider.dart';

import 'provider/google_sign_in.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  // ignore: must_call_super
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: KhaltiScope(
        publicKey: "test_public_key_761aff13c5a14fafa192fc609dcd9749",
        builder: (context, navigatorKey) {
          return Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 214, 240, 249),
                Color.fromARGB(255, 243, 243, 243),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
            )),
            child: GetMaterialApp(
              localizationsDelegates: const [
                KhaltiLocalizations.delegate,
              ],
              title: 'Jutta Pasal',
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: Colors.white,
              ),
              home: const Splash(),
            ),
          );
        },
      ),
      // GetMaterialApp(
      //   title: 'Jutta Pasal',
      //   debugShowCheckedModeBanner: false,
      //   navigatorKey: navigatorKey,
      //   theme: ThemeData(
      //     brightness: Brightness.light,
      //     primaryColor: Colors.white,
      //   ),
      //   home: const Splash(),
      // ),
    );
  }
}
