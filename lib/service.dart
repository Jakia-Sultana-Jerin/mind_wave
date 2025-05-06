import 'package:cloud_firestore/cloud_firestore.dart';

class Fireservices {
  static Future<String> addMessage({time, from, to, media, text}) async {
    final response = await FirebaseFirestore.instance.collection("chat").add({
      "time": time,
      "from": from,
      "to": to,
      "media": media,
      "text": text,
    });
    
    return response.id;
  }
}
