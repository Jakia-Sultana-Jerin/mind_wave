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

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chats",
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_rounded),
            label: "Filter",

            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.key_rounded),
            label: "Pin",
            backgroundColor: Colors.blue,
          ),
        ],

        currentIndex: 2,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/Prompt');
          }

          if (index == 1) {
            Navigator.pushNamed(context, '/Filter');
          }
        },
      ),
    );
  }
}
