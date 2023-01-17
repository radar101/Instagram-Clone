import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/utility/colors.dart';
import 'package:provider/provider.dart';

import '../Providers/user_provider.dart';
import 'message_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    model.User? user = context.read<UserProvider>().getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'radar',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.video_call_outlined,
              color: primaryColor,
              size: 35,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add,
              color: primaryColor,
              size: 35,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: FirebaseFirestore.instance.collection('users').get(),
              builder: (BuildContext context, snapshots) {
                if (snapshots.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Stack(
                                    alignment: AlignmentDirectional.bottomEnd,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          snapshots.data!.docs[index]
                                              ['photoUrl'],
                                        ),
                                        radius: 40,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.grey.shade800),
                                        child: snapshots.data!.docs[index]
                                                    ['uid'] ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? IconButton(
                                                onPressed: () {},
                                                icon: const Icon(Icons.add),
                                              )
                                            : const Text(
                                                ' This is note ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ]),
                              )
                            ],
                          );
                        }),
                  );
                }
              }),
          Padding(
            padding: const EdgeInsets.only(right: 15, left: 15, bottom: 20),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Messages',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Requests',
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: FirebaseFirestore.instance.collection('users').get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Expanded(
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MessageScreen(
                                  receiver_uid: snapshot.data!.docs[index]
                                      ['uid'],
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                      snapshot.data!.docs[index]['photoUrl']),
                                ),
                                title: Text(
                                  snapshot.data!.docs[index]['username'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.camera_alt_outlined),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}