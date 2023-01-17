import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/following.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/screens/savedPostsScreen.dart';
import 'package:instagram_clone/screens/showPosts.dart';
import 'package:instagram_clone/utility/colors.dart';
import '../widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var snapUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      var snapPost = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      isFollowing = snapUser
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        postLen = snapPost.docs.length;
        userData = snapUser.data()!;
      });
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: Text(userData['username']),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const savedPostsScreen()));
                  },
                  icon: const Icon(
                    Icons.bookmark,
                  ),
                ),
              ],
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userData['photoUrl']),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStateColumn(postLen, 'Posts'),
                                    InkWell(
                                      onTap: () => ListView(),
                                      child: buildStateColumn(
                                          userData['followers'].length,
                                          'followers'),
                                    ),
                                    InkWell(
                                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => FollowingScreen(followerCount: userData['following'].length ,))),
                                      child: buildStateColumn(
                                          userData['following'].length,
                                          'following'),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            function: () async {
                                              await FireStoreMethods()
                                                  .signOutUser();
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginScreen(),
                                                ),
                                              );
                                            },
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            borderColor: Colors.grey,
                                            text: 'Sign Out',
                                            textColor: primaryColor,
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                function: () async {
                                                  await FireStoreMethods()
                                                      .followUser(
                                                          uid: FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid,
                                                          followId:
                                                              userData['uid']);
                                                  setState(() {
                                                    isFollowing = false;
                                                    userData['followers']
                                                        .length -= 1;
                                                  });
                                                },
                                                backgroundColor: Colors.white,
                                                borderColor: Colors.grey,
                                                text: 'Unfollow',
                                                textColor: Colors.black,
                                              )
                                            : FollowButton(
                                                function: () async {
                                                  await FireStoreMethods()
                                                      .followUser(
                                                          uid: FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid,
                                                          followId:
                                                              userData['uid']);
                                                  setState(() {
                                                    isFollowing = true;
                                                    userData['followers']
                                                        .length += 1;
                                                  });
                                                },
                                                backgroundColor: Colors.blue,
                                                borderColor: Colors.grey,
                                                text: 'Follow',
                                                textColor: Colors.white,
                                              ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          userData['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          userData['bio'],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('posts')
                        .where('uid', isEqualTo: widget.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return GridView.builder(
                            shrinkWrap: true,
                            itemCount: (snapshot.data! as dynamic).docs.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 1.5,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              DocumentSnapshot snap =
                                  (snapshot.data! as dynamic).docs[index];
                              return InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ShowPosts(
                                      snap: snapshot.data?.docs[index],
                                    ),
                                  ),
                                ),
                                child: Container(
                                  child: Image(
                                    image: NetworkImage(
                                      snap['postUrl'],
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            });
                      }
                    })
              ],
            ),
          );
  }

  Column buildStateColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w100,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
