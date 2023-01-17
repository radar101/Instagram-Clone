import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/models/chat.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/file_storage.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// upload post
  Future<String> uploadPost(String description, String uid, Uint8List file,
      String username, String profImage, String location) async {
    String res = "Some error occured";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId =
          const Uuid().v1(); // It creates unique postId based on the time
      Post post = Post(
          username: username,
          uid: uid,
          description: description,
          postId: postId,
          datepublished: DateTime.now(),
          profImage: profImage,
          postUrl: photoUrl,
          likes: [],
          location: location,
          saveId: []);
      _firestore.collection('posts').doc(postId).set(
            post.toJson(),
          );
      res = "Success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  /// To like the post

  Future<void> likesPost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          /// We are using update() method and not set() method because we have to change only one parameter not complete document
          'likes': FieldValue.arrayRemove([uid]),

          /// To remove the uid from the likes array
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          /// We are using update() method and not set() method because we have to change only one parameter not complete document
          'likes': FieldValue.arrayUnion([uid]),

          /// To add the uid in the likes array
        });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  /// Adding the comment to the post

  Future<String> commentPost(String description, String uid, String username,
      String profImage, String postId) async {
    String res = 'Some error occured';
    try {
      String commentId = const Uuid().v1();
      Comment comment = Comment(
          username: username,
          uid: uid,
          description: description,
          commentId: commentId,
          datepublished: DateTime.now(),
          profImage: profImage,
          likes: []);
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set(comment.toJson());
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  /// Deleting the post

  Future<void> deletePost(String postId) async {
    try {
      _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  /// To follow the another user

  Future<void> followUser(
      {required String uid, required String followId}) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];
      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /// To log out the current user

  Future<void> signOutUser() async {
    await FirebaseAuth.instance.signOut();
  }

  /// To save the post
  Future<void> savePost(String postId, String uid) async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();
      List usersSaved = (snap.data()! as dynamic)['saveId'];
      if (usersSaved.contains(uid)) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({
          'saveId': FieldValue.arrayRemove([uid])
        });
      } else {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({
          'saveId': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  /// Chatting setup

  Future<String> sendMessage(String receiver_uid, String username, String uid,
      String description) async {
    String res = "Some error occured";
    try {
      String chatId = const Uuid().v1();
      Chat chat = Chat(
          username: username,
          receiver_uid: receiver_uid,
          sender_uid: uid,
          description: description,
          );
       _firestore
          .collection('users')
          .doc(uid)
          .collection('messages')
          .doc(chatId)
          .set(chat.toJson()
       );

      _firestore
          .collection('users')
          .doc(receiver_uid)
          .collection('messages')
          .doc(chatId)
          .set(chat.toJson()
      );
      res = 'success';
    } catch (e) {
      print(e.toString());
      res = e.toString();
    }
    return res;
  }
}
