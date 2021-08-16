import 'package:flora/Widgets/RedditMarkdown.dart';
import 'package:flora/Widgets/node.dart';
import 'package:flora/Widgets/nodeTree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DemoScreen extends StatefulWidget {
  DemoScreen({Key? key}) : super(key: key);

  @override
  _DemoScreenState createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  var text =
      "I recently moved from Windows. but I want to say Linux is amazing.  \nNo bus. No lags for online games. I feel a lot safe in terms of security.  \nI will never go back to Windows.";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Demo"),
        ),
        body: NodeTree(
          nodes: [
            Node(
              Text("Text here"),
              child: [
                Node(
                  Text("Child Text Here"),
                  child: [
                    Node(
                      RedditMarkdown(
                        data: text,
                      ),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
