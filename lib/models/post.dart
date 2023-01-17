import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post {
  final String username;
  final String uid;
  final String description;
  final String postId;
  final datepublished;
  final String profImage;
  final String postUrl;
  final List likes;
  final String location;
  final List saveId;

  const Post({
    required this.username,
    required this.uid,
    required this.description,
    required this.postId,
    required this.datepublished,
    required this.profImage,
    required this.postUrl,
    required this.likes,
    required this.location,
    required this.saveId
  });

  Map<String, dynamic> toJson() => {   // To convert it into an object
    "username" : username,
    "uid" : uid,
    "description" : description,
    "postId" : postId,
    "datepublished" : datepublished,
    "profImage" : profImage,
    "postUrl" : postUrl,
    "likes" : likes,
    "location" : location,
    "saveId" : saveId
  };
  static Post fromSnap(DocumentSnapshot snap){
    var snapshot = snap.data() as Map<String , dynamic>;
    return Post(
      username: snapshot['username'],
      uid: snapshot['uid'],
      description: snapshot['description'],
      postId: snapshot['postId'],
      datepublished: snapshot['datepublished'],
      profImage: snapshot['profImage'],
      postUrl: snapshot['postUrl'],
      likes: snapshot['likes'],
      location: snapshot['location'],
      saveId: snapshot['saveId'],
    );
  }
}
