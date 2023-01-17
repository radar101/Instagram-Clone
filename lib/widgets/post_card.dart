import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comment_screen.dart';
import 'package:instagram_clone/utility/colors.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;

  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimatingValue = false;
  bool isSaved = false;
  late int size = 0;

  // Function to get the count of total comments for the particular post
  void getCount() async {
    var then = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.snap['postId'])
        .collection('comments')
        .get()
        .then((snap) => {
              setState(() {
                size = snap.size;
              }),
              // print('The Count of the posts is ***** $size')
            });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCount();
  }

  @override
  Widget build(BuildContext context) {
    model.User? user = context.read<UserProvider>().getUser;
    FirebaseAuth _auth = FirebaseAuth.instance;
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
                .copyWith(right: 0),
            // HEADER Section
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.snap['profImage'] ??
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQULy4K64u69tZlK2XF04a66Gj-fWYV4c9PO0iXOQNdbQ&s'),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Text(
                        //   widget.snap['location'],
                        // ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => Dialog(
                              child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shrinkWrap: true,
                                children: ['Delete']
                                    .map((e) => InkWell(
                                          onTap: () async {
                                            FireStoreMethods().deletePost(
                                                widget.snap['postId']);
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 16),
                                            child: Text(e),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ));
                  },
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                ),
              ],
            ),
          ),

          // IMAGE section

          GestureDetector(
            onDoubleTap: () async {
              await FireStoreMethods().likesPost(
                  widget.snap['postId'], user!.uid, widget.snap['likes']);
              setState(() {
                isLikeAnimatingValue = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Image.network(
                    widget.snap['postUrl'],
                    fit: BoxFit.fill,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimatingValue ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimatingValue,
                    duration: Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimatingValue = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //LIKE COMMENT section

          Row(
            children: [
              LikeAnimation(
                // isAnimating: widget.snap['likes'].contains[user.uid],
                isAnimating: true,
                smallLike: true,
                child: IconButton(
                    onPressed: () async {
                      await FireStoreMethods().likesPost(widget.snap['postId'],
                          user!.uid, widget.snap['likes']);
                    },
                    icon:
                        // widget.snap['likes'].contains[_auth.currentUser!.uid]
                        //     ?
                        const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                    // : Icon(
                    //     Icons.favorite_outline_rounded,
                    //   ),
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                      postId: widget.snap['postId'],
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.send,
                ),
              ),
              Expanded(child: Container()),
              IconButton(
                  onPressed: () async {
                    await FireStoreMethods().savePost(
                        widget.snap['postId'], _auth.currentUser!.uid);
                    var snap = await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.snap['postId'])
                        .get();
                    List savedUids = (snap.data as dynamic)['saveId'];
                    if (savedUids.contains(_auth.currentUser!.uid)) {
                      setState(() {
                        isSaved = !isSaved;
                      });
                    }
                  },
                  icon: !isSaved
                      ? const Icon(Icons.bookmark_border_sharp)
                      : const Icon(Icons.bookmark)),
            ],
          ),

          // COMMENT and Description section

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    '${widget.snap['likes'].length} likes',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ' + widget.snap['description'],
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CommentsScreen(
                        postId: widget.snap['postId'],
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'View all $size Comments',
                      style: const TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datepublished'].toDate()),
                    style: const TextStyle(
                      fontSize: 16,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
