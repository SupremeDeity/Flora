import 'package:draw/draw.dart';
import 'package:flora/State/PostState.dart';
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
  late Post _post;
  bool _isLoaded = false;
  // List<Post> Provider.of<PostState>(context).getPosts(widget.type) = [];
  List<String> _postsIDs = [];
  ScrollController _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchPosts(Provider.of<PostState>(context, listen: false)
            .getPosts(widget.type)!
            .last
            .fullname);
      }
    });

    if (mounted) {
      setState(() {
        redditInstance =
            Provider.of<RedditInstanceState>(context, listen: false)
                .getInstance;
      });
      if (Provider.of<PostState>(context, listen: false)
          .getPosts(widget.type)!
          .isEmpty) {
        fetchPosts("");
      } else {
        _isLoaded = true;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
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
                Provider.of<PostState>(context, listen: false)
                    .addPost(widget.type, pPost);
                _postsIDs.add(submission.fullname!);
                _isLoaded = true;
                if (_refreshController.isRefresh) {
                  _refreshController.refreshCompleted();
                  _refreshController = RefreshController(initialRefresh: false);
                }
              })
            });
      }
    }
  }

  // A singular post
  Widget _buildPost(Post post) {
    return PostCard(
      Provider.of<PostState>(context, listen: false)
          .getPosts(widget.type)!
          .indexOf(post),
      widget.type,
    );
  }

  _refreshData() {
    if (mounted) {
      setState(() {
        _isLoaded = false;
        Provider.of<PostState>(context, listen: false).clearPost(widget.type);
        _postsIDs.clear();
      });
    }
    fetchPosts("");
  }

  // Fetches and generates posts
  Widget _buildPosts() {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () => {_refreshData()},
      child: ListView.builder(
        controller: _scrollController,
        itemCount:
            Provider.of<PostState>(context).getPosts(widget.type)!.length,
        itemBuilder: (ctx, index) {
          if (index ==
              Provider.of<PostState>(context).getPosts(widget.type)!.length -
                  1) {
            return Container(
                padding: EdgeInsets.all(5),
                child: Center(
                    child: CircularProgressIndicator(color: Colors.orange)));
          }
          return _buildPost(
              Provider.of<PostState>(context).getPosts(widget.type)![index]);
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
