import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Comment {
  final String username;
  final String uid;
  final String description;
  final String commentId;
  final datepublished;
  final String profImage;
  final List likes;

  const Comment({
    required this.username,
    required this.uid,
    required this.description,
    required this.commentId,
    required this.datepublished,
    required this.profImage,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {   // To convert it into an object
    "username" : username,
    "uid" : uid,
    "description" : description,
    "commentId" : commentId,
    "datepublished" : datepublished,
    "profImage" : profImage,
    "likes" : likes
  };
  static Comment fromSnap(DocumentSnapshot snap){
    var snapshot = snap.data() as Map<String , dynamic>;
    return Comment(
      username: snapshot['username'],
      uid: snapshot['uid'],
      description: snapshot['description'],
      commentId: snapshot['postId'],
      datepublished: snapshot['datepublished'],
      profImage: snapshot['profImage'],
      likes: snapshot['likes'],
    );
  }
}
