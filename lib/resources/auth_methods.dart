import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/resources/file_storage.dart';
import 'package:instagram_clone/models/user.dart' as model;

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future <model.User> getUserDetails() async{
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  // Sign up the user
  Future<String> signUpUser({
    required String email,
    required String passWord,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occured";
    try {
      if (email.isNotEmpty ||
          passWord.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        // register the user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: passWord);
        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);
        // add user to our database

        model.User user = model.User(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          photoUrl: photoUrl,
          note: "",
        );

        await _firestore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );
        // This is most important here. first of all we are accessing firestore instance and then creating a collection name 'user' and then creating the document of the valid id and then setting the corresponding data

        //

        /*await _firestore.collection('users').add({
          'username' : username,
          'uid' : cred.user!.uid,
          'email': email,
          'bio' : bio,
          'followers' : [],
          'following' : [],
        });*/

        res = 'Success';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is badly formatted';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }



  // Log in the user
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some erro occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
