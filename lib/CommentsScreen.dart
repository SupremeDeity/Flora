import 'package:draw/draw.dart';
import 'package:flora/PostScreen.dart';
import 'package:flora/State/PostState.dart';
import 'package:flora/Types/postType.dart';
import 'package:flora/Widgets/commentBranch.dart';
import 'package:flora/Widgets/postCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  CommentsScreen(this.postIndex, {Key? key, this.type = FilterType.Best})
      : super(key: key);

  int postIndex;
  FilterType type;

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  bool loaded = false;
  int _numComments = 0;
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    parsePost();
    fetchComments();
  }

  parsePost() async {
    // await Provider.of<PostState>(context, listen: false)
    //     .getPosts(widget.type)![widget.postIndex]
    //     .parse();

    await Provider.of<PostState>(context, listen: false)
        .getPosts(widget.type)![widget.postIndex]
        .submission
        .refreshComments();

    setState(() {
      _numComments = Provider.of<PostState>(context, listen: false)
          .getPosts(widget.type)![widget.postIndex]
          .numComments;
    });
  }

  fetchComments({int limit = 10}) async {
    Post sub = Provider.of<PostState>(context, listen: false)
        .getPosts(widget.type)![widget.postIndex];
    CommentForest? _commentForest =
        Provider.of<PostState>(context, listen: false)
            .getPosts(widget.type)![widget.postIndex]
            .submission
            .comments;

    // return 10 or ${limit} results, as long as index <= sub.numComments
    for (int x = (_comments.length == 0 ? 0 : _comments.length - 1);
        x <= limit;
        x++) {
      //print(
      //  "$x, ${sub.numComments}, ${(_commentForest?.comments.length ?? 0) - 1}");
      // if we have more comments to fetch
      if ((x <= sub.numComments) &&
          (x <= (_commentForest?.comments.length ?? 0) - 1)) {
        print(_commentForest?.comments[x] is MoreComments);
        // If we get a MoreComments object, fetch the next page of comments
        if (_commentForest?.comments[x] is MoreComments) {
          print("This got called");
          await _commentForest?.replaceMore().then((value) => print("fetched"));
        }

        print("get called");
        // Add them to the total list of comments
        setState(() {
          _comments.add(_commentForest?.comments[x]);
          if (!loaded) {
            loaded = true;
          }
        });
      }
    }
  }

  Widget _generateBranches() {
    return ListView.builder(
      itemCount: _comments.length + 1,
      itemBuilder: (ctx, index) {
        if (index == 0) {
          return PostCard(widget.postIndex, widget.type);
        }
        print('$index, ${_comments.length + 1}, ${_numComments - 1}');

        // If we reached end of comments, fetch more (if we can)
        if (index >= _comments.length && index != _numComments - 1) {
          //print("index: $index");
          fetchComments();
          return Center(
              child: CircularProgressIndicator(
            color: Colors.blue,
          ));
        }

        return CommentBranch(_comments[index - 1]);
      },
    );
  }

  replaceMore() async {
    await Provider.of<PostState>(context, listen: false)
        .getPosts(widget.type)![widget.postIndex]
        .submission
        .comments!
        .replaceMore();
    setState(() {
      _numComments = Provider.of<PostState>(context, listen: false)
          .getPosts(widget.type)![widget.postIndex]
          .submission
          .comments!
          .length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => {
                    SchedulerBinding.instance?.addPostFrameCallback((_) {
                      Navigator.pop(context);
                    })
                  }),
          title: Text("Comments"),
        ),
        body: loaded
            ? _generateBranches()
            : Center(
                child: CircularProgressIndicator(
                color: Colors.blue,
              )),
      ),
    );
  }
}
