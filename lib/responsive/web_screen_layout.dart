import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/screens/add_post.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';
import '../screens/chat_screen.dart';
import '../utility/colors.dart';

class WebScreenLayout extends StatefulWidget {
  const WebScreenLayout({Key? key}) : super(key: key);

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  int _page = 0;

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onBarTapped(int page) {
    pageController.jumpToPage(page);
    setState(() {
      _page = page;
    });
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: mobileBackgroundColor,
        title: SvgPicture.asset(
          'assets/ic_instagram.svg',
          color: primaryColor,
          height: 32,
        ),
        actions: [
          IconButton(
            onPressed: () {
              onBarTapped(0);
            },
            icon: const Icon(Icons.home),
            color: _page == 0 ? primaryColor : secondaryColor,
          ),
          IconButton(
            onPressed: () {
              onBarTapped(1);
            },
            icon: const Icon(Icons.search),
            color: _page == 1 ? primaryColor : secondaryColor,
          ),
          IconButton(
            onPressed: () {
              onBarTapped(2);
            },
            icon: const Icon(Icons.add_a_photo),
            color: _page == 2 ? primaryColor : secondaryColor,
          ),
          IconButton(
            onPressed: () {
              onBarTapped(3);
            },
            icon: const Icon(Icons.favorite_outline),
            color: _page == 3 ? primaryColor : secondaryColor,
          ),
          IconButton(
            onPressed: () {
              onBarTapped(4);
            },
            icon: const Icon(Icons.person),
            color: _page == 4 ? primaryColor : secondaryColor,
          ),
          IconButton(
            onPressed: () {
              onBarTapped(5);
            },
            icon: const Icon(Icons.messenger_outline),
            color: _page == 5 ? primaryColor : secondaryColor,
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const FeedScreen(),
          const SearchScreen(),
          const AddPost(),
          const ChatScreen(),
          ProfileScreen(
            uid: FirebaseAuth.instance.currentUser!.uid,
          ),
          // const ChatScreen(),
        ],
      )
    );
  }
}
