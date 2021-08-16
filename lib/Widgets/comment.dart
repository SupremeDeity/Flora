import 'package:draw/draw.dart' as Draw;
import 'package:flora/CommentsScreen.dart';
import 'package:flora/Widgets/RedditMarkdown.dart';
import 'package:flutter/material.dart';

class Comment extends StatefulWidget {
  Comment(
    this.comment, {
    Key? key,
    this.hasReplies = false,
    this.overrideExtendEvent,
  }) : super(key: key);
  final Draw.Comment comment;
  final bool hasReplies;

  /// Overrides the event on press of 'extend' button.
  final void Function()? overrideExtendEvent;

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  bool _isUpvoted = false;
  bool _isDownvoted = false;
  bool _isSaved = false;
  int _votes = 0;

  @override
  void initState() {
    super.initState();
    _isUpvoted = widget.comment.vote == Draw.VoteState.upvoted;
    _isDownvoted = widget.comment.vote == Draw.VoteState.downvoted;
    _isSaved = widget.comment.saved;
    _votes = widget.comment.score;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(6, 2, 6, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).backgroundColor,
            padding: EdgeInsets.all(8),
            //margin: EdgeInsets.fromLTRB(6, 2, 6, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.comment.author,
                  style: TextStyle(fontSize: 10, color: Colors.orange),
                  textAlign: TextAlign.left,
                ),
                RedditMarkdown(
                  data: widget.comment.body!,
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).backgroundColor,
            child: Row(
              children: [
                IconButton(
                    splashRadius: 20,
                    color: _isUpvoted
                        ? Theme.of(context).accentColor
                        : Colors.white,
                    onPressed: () => {
                          _isUpvoted
                              ? {
                                  widget.comment.clearVote(),
                                  setState(() {
                                    _isUpvoted = false;
                                    _votes--;
                                    print(_votes);
                                  })
                                }
                              : {
                                  widget.comment.upvote(),
                                  setState(() {
                                    _isUpvoted = true;
                                    _isDownvoted = false;
                                    _votes++;
                                    print(_votes);
                                  })
                                }
                        },
                    icon: Icon(Icons.arrow_upward_outlined)),
                Text(_votes.toString()),
                IconButton(
                    splashRadius: 20,
                    color: _isDownvoted
                        ? Theme.of(context).accentColor
                        : Colors.white,
                    onPressed: () => _isDownvoted
                        ? {
                            widget.comment.clearVote(),
                            setState(() {
                              _isDownvoted = false;
                              _votes++;
                            })
                          }
                        : {
                            widget.comment.downvote(),
                            setState(() {
                              _isUpvoted = false;
                              _isDownvoted = true;
                              _votes--;
                            })
                          },
                    icon: Icon(Icons.arrow_downward_outlined)),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () => {
                                print(_isSaved),
                                _isSaved
                                    ? widget.comment.unsave()
                                    : widget.comment.save(),
                                setState(() {
                                  _isSaved = !_isSaved;
                                }),
                              },
                          icon: _isSaved
                              ? Icon(Icons.bookmark_added_rounded)
                              : Icon(Icons.bookmark_add_outlined)),
                      IconButton(onPressed: () => {}, icon: Icon(Icons.share)),
                    ],
                  ),
                )
              ],
            ),
          ),
          widget.hasReplies
              ? Container(
                  height: 40,
                  color: Theme.of(context).accentColor,
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                      onPressed: widget.overrideExtendEvent ??
                          () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        CommentsScreen(widget.comment),
                                  ),
                                )
                              },
                      child: Text(
                        "Extend",
                        style:
                            TextStyle(color: Theme.of(context).backgroundColor),
                      )))
              : Container()
        ],
      ),
    );
  }
}
