import 'package:flutter/material.dart';

class Pinnedmessage extends StatefulWidget {
  const Pinnedmessage({super.key});

  @override
  State<Pinnedmessage> createState() => _Pinnedmessage();
}

class _Pinnedmessage extends State<Pinnedmessage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //   appBar: AppBar(title: Text("Pinned Message")),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            opacity: 0.4,
            repeat: ImageRepeat.repeat,
          ),
        ),
      ),
    );
  }
}
