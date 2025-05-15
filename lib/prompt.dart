import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bubble/bubble.dart';
import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:imgbb/imgbb.dart';
//import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:mind_wave/service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_saver/file_saver.dart';

import 'package:photo_viewer/photo_viewer.dart';

class Prompt extends StatefulWidget {
  const Prompt({super.key});

  @override
  State<Prompt> createState() => _PromptState();
}

class _PromptState extends State<Prompt> {
  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ImageProvider = Image.network("media").image;

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

  bool generateimage = false;
  bool ispinned = false;
  bool currentstate = false;

  /////share Image

  Future<void> shareImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final temp = await getTemporaryDirectory();
        final file = File('${temp.path}/shared_image.jpg');
        await file.writeAsBytes(response.bodyBytes);

        final params = ShareParams(files: [XFile(file.path)]);

        final result = await SharePlus.instance.share(params);

        if (result.status == ShareResultStatus.success) {
          print('Thank you for sharing the picture');
        } else {
          print('Sharing failed: ${result.status}');
        }
      }
    } catch (e) {
      print('Error sharing image: $e');
    }
  }

  /////Download Image
  mysnackbar(message, context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> downloadImage(String imageurl, BuildContext context) async {
    await FileSaver.instance.saveAs(
      name: "image",

      link: LinkDetails(link: imageurl),
      ext: "png",
      mimeType: MimeType.png,
    );

    mysnackbar("Sucessfully Download", context);
  }

  void tapPin(String messageId, currentsate) async {
    await FirebaseFirestore.instance.collection('chat').doc(messageId).update({
      "pin": !currentsate,
    });
  }

  void addMessage() async {
    final textbody = messageController.text.trim();
    if (textbody.isEmpty) return;

    messageController.clear();

    setState(() {
      generateimage = true;
    });

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
      pin: false,
    );

    await replygpt(messageID, 1024, 1024, textbody);

    setState(() {
      generateimage = false;
    });
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
                Future.delayed(Duration(milliseconds: 100), () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
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
                                      ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AspectRatio(
                                            aspectRatio:
                                                (message['width'] /
                                                    message['height']),

                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    showImageViewer(
                                                      context,
                                                      Image.network(
                                                        media,
                                                      ).image,
                                                      swipeDismissible: true,
                                                      doubleTapZoomable: true,
                                                    );
                                                  },
                                                  child: Image.network(
                                                    media,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Image.asset(
                                                        "assets/images/failedimage.jpg",
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  shareImage(media);
                                                },

                                                icon: Icon(Icons.share),
                                              ),

                                              IconButton(
                                                onPressed: () {
                                                  downloadImage(media, context);
                                                },
                                                icon: Icon(Icons.download),
                                              ),

                                              IconButton(
                                                onPressed:
                                                    () => tapPin(
                                                      snapshot
                                                          .data!
                                                          .docs[index]
                                                          .id,
                                                      message['pin'] 
                                                    ),

                                                icon: Icon(
                                                  
                                                       Icons.push_pin,
                                                      
                                                 color: 
                                                   message['pin']
                                                          ? Colors.orange
                                                          : Colors.blue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                      : Container(
                                        height:
                                            MediaQuery.of(context).size.width *
                                            0.7,
                                        width:
                                            MediaQuery.of(context).size.width *
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
                      focusNode: _focusNode,

                      maxLines: 4,
                      minLines: 1,
                      onTap: () {
                        Future.delayed(Duration(milliseconds: 10), () {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      },
                      decoration: InputDecoration(
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Icon(Icons.tune_rounded), //filter icon
                            ),
                            SizedBox(width: 13),
                          ],
                        ),

                        hintText: "Write something",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14.0),
                      ),
                    ),
                  ),
                ),
                generateimage
                    ? Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : Container(
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
