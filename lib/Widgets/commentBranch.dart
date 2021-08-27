import 'package:draw/draw.dart' as Draw;
import 'package:flora/Widgets/comment.dart';
import 'package:flora/Widgets/node.dart';
import 'package:flora/Widgets/nodeTree.dart';
import 'package:flutter/material.dart';

class CommentBranch extends StatefulWidget {
  CommentBranch(this.comment, {Key? key}) : super(key: key);
  final Draw.Comment comment;

  @override
  _CommentBranchState createState() => _CommentBranchState();
}

class _CommentBranchState extends State<CommentBranch> {
  _generateLeafs() {
    List<Node> _replies = [];
    if ((widget.comment.replies?.length ?? 0) > 0) {
      widget.comment.replies!.comments.forEach((comment) {
        if (comment is Draw.Comment) {
          _replies.add(Node(
            Comment(
              comment,
              hasReplies: (comment.replies?.length ?? 0) > 0,
            ),
          ));
        }
      });
    }

    return Node(
      Comment(widget.comment),
      child: _replies,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: NodeTree(nodes: [_generateLeafs()]),
    );
  }
}
