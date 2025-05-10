import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mind_wave/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Login(), // Set the login screen as the home screen
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    if (_googleSignIn.currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            opacity: 0.4,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(),
            Image.asset("assets/images/logo.png", height: 80, width: 80),
            FilledButton.icon(
              onPressed: _handleSignIn,
              label: const Text(
                "Signin with google",
                style: TextStyle(color: Colors.black),
              ),
              icon: const Text("G", style: TextStyle(color: Colors.black)),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle Google Sign-In and Firebase Authentication
  Future<void> _handleSignIn() async {
    try {
      // Trigger the Google Sign-In
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      // Get the authentication credentials from Google
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a Firebase credential
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
       Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
      }
      // ignore: use_build_context_synchronously
    } catch (error) {
      print("Error during sign-in: $error");
    }
  }
}
