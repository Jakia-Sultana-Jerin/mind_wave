import 'dart:convert';

import 'package:bubble/bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mind_wave/service.dart';
import 'package:http/http.dart' as http;

class Prompt extends StatefulWidget {
  const Prompt({super.key});

  @override
  State<Prompt> createState() => _PromptState();
}

class _PromptState extends State<Prompt> {
  final ScrollController _scrollController = ScrollController();

  String? selectedMessageId;
  final firebaseService = Fireservices();
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance
          .collection('chat')
          .orderBy('time', descending: false)
          .snapshots();

  TextEditingController messageController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  String? uid;

  List<Map> history = [];

  void addMessage() async {
    final textbody = messageController.text;
    messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(microseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    await firebaseService.addMessage(
      time: DateTime.now().toUtc().millisecondsSinceEpoch,
      from: uid,
      to: "system",
      media: [],
      text: textbody.trim(),
    );

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              StreamBuilder(
                stream: _usersStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Something went wrong!");
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(microseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });

                  print(snapshot.data!.docs);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),

                      child: ListView.builder(
                        controller: _scrollController,

                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> message =
                              snapshot.data!.docs[index].data()!
                                  as Map<String, dynamic>;

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
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
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

          currentIndex: 0,
          onTap: (int index) {
            if (index == 1) {
           
              Navigator.pushNamed(context, '/Filter');
            }

            if (index == 2) {
              Navigator.pushNamed(context, '/Pin');
            }
          },
        ),
      ),
    );
  }

  Future<void> fetchdata() async {
    final response = await http.get(
      Uri.parse("https://api.npoint.io/43a1d81385289c124acc"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data['data']['phone']);
    }
  }
}
