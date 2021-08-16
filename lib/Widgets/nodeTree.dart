import 'package:flora/Widgets/node.dart';
import 'package:flutter/material.dart';

class NodeTree extends StatefulWidget {
  NodeTree({Key? key, required this.nodes}) : super(key: key);

  final List<Node> nodes;

  @override
  _NodeTreeState createState() => _NodeTreeState();
}

class _NodeTreeState extends State<NodeTree> {
  @override
  void initState() {
    super.initState();
  }

  /// This will render top-level nodes
  _generateNodeTree() {
    List<Node> _nodes = [];
    for (Node node in widget.nodes) {
      _nodes.add(node);
    }

    return _nodes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      child: Column(
        children: _generateNodeTree(),
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Text("Here"),
      //     Container(
      //       margin: EdgeInsets.only(left: 5),
      //       child: Text("Here is Tree"),
      //     )
      //   ],
    );
  }
}
