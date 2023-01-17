import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/screens/showPosts.dart';
import 'package:instagram_clone/utility/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearched = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search for a user',
            ),
            onSubmitted: (String str) {
              print(str);
              setState(() {
                _isSearched = true;
              });
            }),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: _searchController.text)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return _isSearched
                ? ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                    uid: snapshot.data!.docs[index]['uid']))),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                snapshot.data!.docs[index]['photoUrl']),
                          ),
                          title: Text(snapshot.data!.docs[index]['username']),
                        ),
                      );
                    })
                : FutureBuilder(
                    future:
                        FirebaseFirestore.instance.collection('posts').get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return StaggeredGridView.countBuilder(
                          crossAxisCount: 3,
                          itemCount: snapshot.data?.docs.length,
                          itemBuilder: (context, index) => InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ShowPosts(
                                  snap: snapshot.data?.docs[index],
                                ),
                              ),
                            ),
                            child: Image.network(
                              snapshot.data?.docs[index]['postUrl'],
                            ),
                          ),
                          staggeredTileBuilder: (index) => StaggeredTile.count(
                              (index % 7 == 0) ? 2 : 1,
                              (index % 7 == 0) ? 2 : 1),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        );
                      }
                    },
                  );
          }
        },
      ),
    );
  }
}
