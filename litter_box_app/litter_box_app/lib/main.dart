
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/add_cat_info_page.dart';
import 'pages/cats_list_page.dart';
import 'pages/device_list_page.dart';
import 'pages/home_page.dart';
import 'pages/notification_page.dart';

var cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(), //AuthPage()
      routes: {
        '/catlistpage' : (context) =>  const CatListPage(),
        '/devicelistpage' : (context) => const DeviceListPage(),
        '/homepage' : (context) => const HomePage(),
        '/notificationpage': (context) => const NotificationPage(),
        '/addcatinfopage': (context) => const AddCatInfoPage(),
        //'/cartpage': (context) => const CartPage(),
      },
    );
  }
}
