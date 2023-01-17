import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utility/colors.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({Key? key, required this.followerCount}) : super(key: key);
  final followerCount;

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following', style: TextStyle(color: Colors.white),),
        backgroundColor: mobileBackgroundColor,
      ),
      body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc('following')
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                  itemCount:
                  widget.followerCount,
                  itemBuilder:
                      (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                  uid: (snapshot.data! as dynamic).docs[index]['uid']))),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              (snapshot.data! as dynamic).docs[index]['photoUrl']),
                        ),
                        title: Text((snapshot.data! as dynamic).docs[index]['username']),
                      ),
                    );
                  });
            }
          })
    );
  }
}
