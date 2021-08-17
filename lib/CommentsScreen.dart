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

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  fetchComments() async {
    // If we want to look at all comments.
    await Provider.of<PostState>(context, listen: false)
        .getPosts(widget.type)![widget.postIndex]
        .parse();
    await Provider.of<PostState>(context, listen: false)
        .getPosts(widget.type)![widget.postIndex]
        .submission
        .refreshComments()
        .then((value) => setState(() {
              loaded = true;
              _numComments = value.length;
            }));
  }

  Widget _generateBranches() {
    return ListView.builder(
      itemCount: _numComments + 1,
      itemBuilder: (ctx, index) {
        if (index == 0) {
          return PostCard(widget.postIndex, widget.type);
        }

        if (Provider.of<PostState>(context, listen: false)
                .getPosts(widget.type)![widget.postIndex]
                .submission
                .comments?[index - 1]
                .runtimeType ==
            Comment) {
          return CommentBranch(
            Provider.of<PostState>(context, listen: false)
                .getPosts(widget.type)![widget.postIndex]
                .submission
                .comments?[index - 1],
          );
        } else {
          return ElevatedButton(
            onPressed: () {},
            child: Text("More"),
          );
        }
      },
    );
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
