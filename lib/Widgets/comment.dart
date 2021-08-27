import 'package:cached_network_image/cached_network_image.dart';
import 'package:draw/draw.dart' as Draw;
import 'package:flora/CommentsScreen.dart';
import 'package:flora/State/themes.dart';
import 'package:flora/Widgets/MoreComments.dart';
import 'package:flora/Widgets/RedditMarkdown.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  String _iconLink = "";

  @override
  void initState() {
    super.initState();
    _isUpvoted = widget.comment.vote == Draw.VoteState.upvoted;
    _isDownvoted = widget.comment.vote == Draw.VoteState.downvoted;
    _isSaved = widget.comment.saved;
    _votes = widget.comment.score;

    _getAvatarImageLink();
  }

  _getAvatarImageLink() async {
    await widget.comment.author.populate().then((value) => {
          if (mounted)
            setState(() {
              _iconLink = value.data!['icon_img'];
            })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Charcoal,
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
                ListTile(
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  minLeadingWidth: 20,
                  leading: CircleAvatar(
                    maxRadius: 12,
                    foregroundImage: _iconLink != ""
                        ? CachedNetworkImageProvider(_iconLink)
                        : null,
                    child: _iconLink == ""
                        ? FaIcon(FontAwesomeIcons.redditAlien)
                        : null,
                    backgroundColor: Color.fromARGB(0, 0, 0, 0),
                  ),
                  title: Text(
                    widget.comment.author.displayName,
                    style: TextStyle(fontSize: 10, color: Colors.orange),
                    textAlign: TextAlign.left,
                  ),
                ),
                Divider(
                  color: Colors.black54,
                ),
                RedditMarkdown(
                  data: widget.comment.body!,
                ),
              ],
            ),
          ),
          Divider(color: Colors.black54),
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
                                          // MoreCommentsScreen(widget.comment),
                                          Container()),
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
