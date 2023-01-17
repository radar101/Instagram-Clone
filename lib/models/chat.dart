import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chat {
  final String username;
  final String receiver_uid;
  final String sender_uid;
  final String description;

  const Chat({
    required this.username,
    required this.receiver_uid,
    required this.sender_uid,
    required this.description,
  });

  Map<String, dynamic> toJson() => {   // To convert it into an object
    "username" : username,
    "receiver_uid" : receiver_uid,
    "sender_uid" : sender_uid,
    "description" : description,
  };
  static Chat fromSnap(DocumentSnapshot snap){
    var snapshot = snap.data() as Map<String , dynamic>;
    return Chat(
      username: snapshot['username'],
      receiver_uid: snapshot['receiver_uid'],
      sender_uid: snapshot['sender_uid'],
      description: snapshot['description'],
    );
  }
}
