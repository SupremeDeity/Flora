import 'package:cached_network_image/cached_network_image.dart';
import 'package:flora/Widgets/RedditMarkdown.dart';
import 'package:flora/Widgets/node.dart';
import 'package:flora/Widgets/nodeTree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:photo_view/photo_view_gallery.dart';

class DemoScreen extends StatefulWidget {
  DemoScreen({Key? key}) : super(key: key);

  @override
  _DemoScreenState createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Demo"),
      ),
      body: ListView.builder(itemBuilder: (context, index) {
        if (index < 10) {
          return Text("text");
        } else {
          return SizedBox(
            width: 200,
            height: 200,
            child: PhotoViewGallery.builder(
                itemCount: 2,
                onPageChanged: (page) => {print(page)},
                builder: (context, index) => PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(
                        "https://picsum.photos/200"))),
          );
        }
      }),
    ));
  }
}
