import 'package:cloud_firestore/cloud_firestore.dart';

class Fireservices {
  static final db = FirebaseFirestore.instance;
  Future<String> addMessage({time, from, to, media,height,width, text}) async {
    final response = await db.collection("chat").add({
      "time": time,
      "from": from,
      "to": to,
      "media": media,
      "height":height,
      "width": width,
      "text": text,
    });
    
    return response.id;
  }
}
