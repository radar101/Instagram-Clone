import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utility/colors.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key, required this.receiver_uid}) : super(key: key);
  final String receiver_uid;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  var userData = {};
  bool isLoading = false;
  TextEditingController _messageController = TextEditingController();


  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  void addMessage(String receiver_uid, String username) async {
    String res = await FireStoreMethods().sendMessage(receiver_uid, username,
        FirebaseAuth.instance.currentUser!.uid, _messageController.text);
    print(res);
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var snapUser = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.receiver_uid)
          .get();
      // var snapPost = await FirebaseFirestore.instance
      //     .collection('posts')
      //     .where('uid', isEqualTo: widget.uid)
      //     .get();

      setState(() {
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: CircleAvatar(
            backgroundImage: NetworkImage(userData['photoUrl']),
            // radius: ,
          ),
        ),
        centerTitle: false,
        title: Text(userData['username']),
        backgroundColor: mobileBackgroundColor,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call_outlined),
          ),
        ],
      ),
      body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('messages')
              .where('receiver_uid', isEqualTo: userData['uid'])
              .get(),
          builder: (BuildContext context, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshots.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: snapshots.data!.docs[index]
                                    ['sender_uid'] ==
                                FirebaseAuth.instance.currentUser!.uid
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Material(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30.0),
                                bottomLeft: Radius.circular(30.0),
                                bottomRight: Radius.circular(30.0),
                                topRight: Radius.circular(30.0)),
                            elevation: 5.0,
                            color: snapshots.data!.docs[index]['sender_uid'] ==
                                    FirebaseAuth.instance.currentUser!.uid
                                ? Colors.blue.shade700
                                : Colors.grey.shade800,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              child: Text(
                                snapshots.data!.docs[index]['description'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            }
          }),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.camera_alt,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  addMessage(userData['uid'], userData['username']);
                  _messageController.clear();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
