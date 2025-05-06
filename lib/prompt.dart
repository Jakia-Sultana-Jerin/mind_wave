import 'package:bubble/bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mind_wave/service.dart';

class Prompt extends StatefulWidget {
  const Prompt({super.key});

  @override
  State<Prompt> createState() => _PromptState();
}

class _PromptState extends State<Prompt> {
  String? selectedMessageId; // Store selected message's id

  // Mysnackbar(message, context) {
  //   return ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text(message)));
  // }

  TextEditingController messageController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  String? uid;

  @override
  void initState() {
    super.initState();
    if (user?.uid == null) {
      Navigator.pushNamed(context, "/login");
    } else {
      setState(() {
        uid = user!.uid;
      });
    }
  }

  List<Map> history = [];

  void addMessage() async {
    final messageid = await Fireservices.addMessage(
      time: DateTime.now().toString().split(' ')[1].substring(0, 5),
      from: uid,
      to: "system",
      media: [],
      text: messageController.text.trim(),
    );
    print(messageid);
    if (messageController.text.trim().isEmpty) return;

    String timeStamp = DateTime.now().toString().split(' ')[1].substring(0, 5);
    setState(() {
      history.add({
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "time": timeStamp,
        "from": uid,
        "to": "system",
        "media": [],
        "text": messageController.text.trim(),
      });

      history.add({
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "time": timeStamp,
        "from": "system",
        "to": uid,
        "media": [],
        "text": "The quick brown fox jumps over the lazy dog",
      });
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            opacity: 0.4,
            repeat: ImageRepeat.repeat,
          ),
        ),

        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),

                child: ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final message = history[history.length - 1 - index];

                    return Bubble(
                      margin: BubbleEdges.only(top: 10),
                      alignment:
                          message["from"] == "system"
                              ? Alignment.topLeft
                              : Alignment.topRight,
                      nip:
                          message["from"] == "system"
                              ? BubbleNip.leftBottom
                              : BubbleNip.rightBottom,
                      color:
                          message["from"] == "system"
                              ? null
                              : Color.fromRGBO(225, 255, 199, 1.0),
                      child: Text('${message["text"]}'),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          color: Colors.grey[200],
                        ),
                        child: TextField(
                          controller: messageController,
                          maxLines: 4,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: "Write something",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14.0),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color
                        shape: BoxShape.circle, // Optional: makes it circular
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send),
                        color: Theme.of(context).primaryColor, // Icon color
                        onPressed: () => addMessage(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      ),
    );
  }
}
