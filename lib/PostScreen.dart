import 'package:draw/draw.dart';
import 'package:flora/Types/postType.dart';
import 'package:flora/State/RedditState.dart';
import 'package:flora/Widgets/postCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum FilterType { Best, Hot, Newest }

class PostsRoute extends StatefulWidget {
  PostsRoute(FilterType type, {Key? key})
      : type = type,
        super(key: key);

  final FilterType type;

  @override
  _PostsRouteState createState() => _PostsRouteState();
}

class _PostsRouteState extends State<PostsRoute> {
  late Reddit redditInstance;
  bool _isLoaded = false;
  List<Post> _posts = [];
  List<String> _postsIDs = [];
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("yeah boi they did");
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchPosts(_posts.last.fullname);
      }
    });

    if (mounted) {
      setState(() {
        redditInstance =
            Provider.of<RedditInstanceState>(context, listen: false)
                .getInstance;
      });
      fetchPosts("");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  fetchPosts(String? after) async {
    var stream;

    switch (widget.type) {
      case FilterType.Best:
        stream = redditInstance.front.best(limit: 10, after: after);
        break;
      case FilterType.Hot:
        stream = redditInstance.front.hot(limit: 10, after: after);
        break;
      case FilterType.Newest:
        stream = redditInstance.front.newest(limit: 10, after: after);
        break;
    }

    await for (UserContent post in stream) {
      Submission submission = post as Submission;

      if (!_postsIDs.contains(submission.fullname)) {
        Post pPost = Post(submission);
        pPost.parse().then((value) => {
              setState(() {
                print("${widget.type}: ${submission.id}");
                _posts.add(pPost);
                _postsIDs.add(submission.fullname!);
                _isLoaded = true;
                if (_refreshController.isRefresh) {
                  _refreshController.refreshCompleted();
                }
              })
            });
      }
    }
  }

  // A singular post
  Widget _buildPost(Post post) {
    return PostCard(
      post,
      // key: GlobalKey(),
    );
  }

  _refreshData() {
    if (mounted) {
      setState(() {
        _isLoaded = false;
        _posts.clear();
        _postsIDs.clear();
      });
    }
    fetchPosts("");
  }

  // Fetches and generates posts
  Widget _buildPosts() {
    print("building posts");
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () => {_refreshData()},
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length,
        itemBuilder: (ctx, index) {
          if (index == _posts.length - 1) {
            return Container(
                padding: EdgeInsets.all(5),
                child: Center(
                    child: CircularProgressIndicator(color: Colors.orange)));
          }
          return _buildPost(_posts[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isLoaded
          ? _buildPosts()
          : Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
