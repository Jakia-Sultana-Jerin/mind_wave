import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mind_wave/pinned.dart';
// import 'firebase_options.dart';
// import  'firebase'
//import 'home.dart';
import 'login.dart';
import 'prompt.dart';
import 'filter.dart';
import 'pinned.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      debugShowCheckedModeBanner: false,
      //  home: HomePage(),
      //   home: Login(),
      //   home: Prompt(),
      initialRoute: '/',
      routes: {
        '/': (context) => Login(),
        '/Prompt': (context) => Prompt(),
        '/Filter': (context) => Filterscreen(),
        '/Pin': (context) => Pinnedmessage(),
      },
    );
  }
}
