import 'package:draw/draw.dart';
import 'package:flora/globalState.dart';
import 'package:flora/postCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class BestPostsRoute extends StatefulWidget {
  BestPostsRoute({Key? key}) : super(key: key);

  @override
  _BestPostsRouteState createState() => _BestPostsRouteState();
}

class _BestPostsRouteState extends State<BestPostsRoute> {
  late Reddit redditInstance;
  List<Submission> _posts = [];
  bool _loaded = false;

  fetchPosts(String? after) async {
    var stream = redditInstance.front.best(limit: 10, after: after);
    await for (UserContent post in stream) {
      Submission submission = post as Submission;
      setState(() {
        _posts.add(submission);
        _loaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        redditInstance =
            Provider.of<RedditInstanceState>(context, listen: false)
                .getInstance;
      });
      fetchPosts("");
    }
  }

  // Fetches and generates posts
  Widget _buildPosts() {
    return ListView.builder(
      itemCount: _posts.length + 1,
      itemBuilder: (ctx, index) {
        if (index < _posts.length) {
          return _buildPost(_posts.elementAt(index));
        } else {
          fetchPosts(_posts.last.fullname);

          return SpinKitDualRing(color: Colors.white);
        }
      },
    );
  }

  // A singular post
  Widget _buildPost(Submission post) {
    return PostCard(post);
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Container(
      child: _loaded ? _buildPosts() : SpinKitDualRing(color: Colors.white),
    );
  }
}
