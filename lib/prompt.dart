import 'dart:convert';
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
    return Container(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Something went wrong!"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
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
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: snapshot.data!.docs.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        Map<String, dynamic> message =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
    
                        return Bubble(
                          margin: BubbleEdges.symmetric(vertical: 8),
                          padding: BubbleEdges.symmetric(vertical: 8),
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
                                  : const Color.fromRGBO(225, 255, 199, 1.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (message["from"] != "system" &&
                                  (message["text"] ?? "").isNotEmpty)
                                Text('${message["text"]}'),
    
                              if (message["from"] == "system")
                                Builder(
                                  builder: (context) {
                                    final media = message["media"];
                                    final hasMedia =
                                        media != null &&
                                        media.toString().isNotEmpty;
    
                                    return hasMedia
                                        ? Image.network(
                                          media,
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.7,
                                          height:
                                              (MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.7) *
                                              (message['width'] /
                                                  message['height']),
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Image.asset(
                                              "assets/images/failedimage.jpg",
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  .7,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                        : Container(
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.7,
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.7,
                                          color: Colors.grey.shade200,
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
            Divider(
              height: 1,
              color: Theme.of(context).dividerColor.withAlpha(100),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
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
                        onTap: () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
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
          ],
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
    if (response1.statusCode == 200) {
      final base64Image = base64Encode(response1.bodyBytes);
      var res = await uploader.uploadImageBase64(base64Image: base64Image);
      final imageurl = res?.url;
      await FirebaseFirestore.instance.collection("chat").doc(messageID).update(
        {"media": imageurl},
      );
    }
  }
}
