import 'package:flutter/material.dart';

class Node extends StatefulWidget {
  Node(this.widget, {Key? key, this.child, this.margin}) : super(key: key);

  /// This is node.
  final Widget widget;

  /// This is the list of children nodes.
  final List<Node>? child;

  /// This is the margin of the current node
  ///
  /// Child nodes will take this margin in + 5
  final double? margin;

  @override
  _NodeState createState() => _NodeState();
}

class _NodeState extends State<Node> {
  bool _isCollapsed = false;
  
  // generate child node trees
  _generateChildNodes() {
    List<Widget> _nodes = [
      GestureDetector(
        child: Container(
          margin: EdgeInsets.only(left: widget.margin ?? 0),
          child: widget.widget,
        ),
        onLongPress: () => {
          setState(() {
            _isCollapsed = !_isCollapsed;
          })
        },
      )
    ];

    if (widget.child != null && !_isCollapsed) {
      for (Node node in widget.child!) {
        _nodes.add(
          Node(
            node.widget,
            margin: (widget.margin != null) ? widget.margin! + 20 : 20,
            child: node.child,
          ),
        );
      }
    }

    return _nodes;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _generateChildNodes(),
    );
  }
}
