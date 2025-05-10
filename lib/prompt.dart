import 'dart:convert';
import 'dart:typed_data';
import 'package:bubble/bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:imgbb/imgbb.dart';
import 'package:mind_wave/service.dart';

class Prompt extends StatefulWidget {
  const Prompt({super.key});

  @override
  State<Prompt> createState() => _PromptState();
}

class _PromptState extends State<Prompt> {
  final ScrollController _scrollController = ScrollController();
  final uploader = Imgbb('3a66d6c1779bf95238fc7d6dbdc8adab');
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
    final textbody = messageController.text.trim();
    if (textbody.isEmpty) return;

    messageController.clear();

    await firebaseService.addMessage(
      time: DateTime.now(),
      from: uid,
      to: "system",
      media: null,
      text: textbody,
    );

    final messageID = await firebaseService.addMessage(
      time: DateTime.now(),
      from: "system",
      to: uid,
      media: null,
      height: 1024,
      width: 1024,
      text: "",
    );

    await replygpt(messageID, 1024, 1024, textbody);
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
                  if (snapshot.hasError) return Text("Something went wrong!");
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> message =
                              snapshot.data!.docs[index].data()
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((message["text"] ?? "").isNotEmpty)
                                  Text('${message["text"]}'),

                                if(message["from"]== "system")
                                Image.network(
                                  message["media"]??"",
                                  height: 1024,
                                  width: 1024,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    return CircularProgressIndicator();
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/images/failedimage.jpg",
                                    );
                                  },
                                ),
                              ],
                            ),
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
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send),
                          color: Theme.of(context).primaryColor,
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
            } else if (index == 2) {
              Navigator.pushNamed(context, '/Pin');
            }
          },
        ),
      ),
    );
  }

  Future<void> replygpt(String messageID, height, width, textbody) async {
    final url = Uri.parse(
      "https://api.cloudflare.com/client/v4/accounts/88713835f93ffe4fce595263dd73c070/ai/run/@cf/stabilityai/stable-diffusion-xl-base-1.0",
    );

    final headers = {
      "Authorization": "Bearer m7vsgH35As9MluEgMqJbLfYrFEWJECKXgmeDkpMj",
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "prompt": textbody,
      "height": height,
      "width": width,
    });

    final response1 = await http.post(url, headers: headers, body: body);
    print("Status Code: ${response1.statusCode}");
    print("Response Body: ${response1.body}");
    if (response1.statusCode == 200) {
      print("Image generated by Cloudflare AI");
      //   final data = jsonDecode(response1.body);
      final base64Image = base64Encode(response1.bodyBytes);
      final imageBase64 = "data:image/png;base64,$base64Image";
      var res = await uploader.uploadImageBase64(
        base64Image: base64Image,
        name: 'example',
        expiration: 600,
      );
      final imageurl = res?.url;
      print(imageurl);

      await FirebaseFirestore.instance.collection("chat").doc(messageID).update(
        {"media": imageurl},
      );
    }
  }
}
