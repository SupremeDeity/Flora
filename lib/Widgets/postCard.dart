import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flora/CommentsScreen.dart';
import 'package:flora/Types/postType.dart';
import 'package:flora/Widgets/RedditMarkdown.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:photo_view/photo_view.dart';

import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

class PostCard extends StatefulWidget {
  PostCard(this.post, {Key? key}) : super(key: key);
  final Post post;

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String imagePath = "";
  int currentImageIndex = 1;
  bool isUpvoted = false;
  bool isDownvoted = false;
  int votes = 0;
  String redditorAvatar = "";
  String videoLink = "";
  bool overflow = false;
  bool _loaded = false;
  bool _isSaved = false;
  var previewData;

  // Video Player
  late VideoPlayerController? videoPlayerController;
  late ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    print("got called again: ${widget.key}");
    setState(() {
      isUpvoted = widget.post.isUpvoted;
      isDownvoted = widget.post.isDownvoted;
      votes = widget.post.votes;
      _isSaved = widget.post.submission.saved;

      if (widget.post.type == PostType.VIDEO ||
          widget.post.type == PostType.GIF) {
        videoLink = widget.post.link;
        videoPlayerController = VideoPlayerController.network(
          videoLink,
        );
      }

      if (widget.post.type == PostType.VIDEO ||
          widget.post.type == PostType.GIF) {
        videoPlayerController!.initialize();
        setState(() {
          chewieController = ChewieController(
            videoPlayerController: videoPlayerController!,
            looping: false,
          );
        });
      }

      _loaded = true;
    });
  }

  @override
  void dispose() {
    if (widget.post.type == PostType.VIDEO) {
      videoPlayerController!.dispose();
      chewieController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loaded
        ? GestureDetector(
            onTap: () {
              print(overflow);
              setState(() {
                overflow = !overflow;
              });
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              color: Theme.of(context).backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      foregroundImage: widget.post.avatar != ""
                          ? CachedNetworkImageProvider(widget.post.avatar!)
                          : null,
                      child: widget.post.avatar == ""
                          ? FaIcon(FontAwesomeIcons.redditAlien)
                          : null,
                      backgroundColor: Color.fromARGB(0, 0, 0, 0),
                    ),
                    title: Text(widget.post.authorName),
                    subtitle: Text(widget.post.subredditName),
                    trailing: IconButton(
                        onPressed: () => {
                              print(_isSaved),
                              _isSaved
                                  ? widget.post.submission.unsave()
                                  : widget.post.submission.save(),
                              setState(() {
                                _isSaved = !_isSaved;
                              }),
                            },
                        icon: _isSaved
                            ? Icon(Icons.bookmark_added_rounded)
                            : Icon(Icons.bookmark_add_outlined)),
                  ),
                  ListTile(
                    title: Text(widget.post.title),
                    subtitle: widget.post.type == PostType.SELF
                        ? RedditMarkdown(
                            data:
                                (widget.post.selfText.length > 200 && !overflow)
                                    ? widget.post.selfText.substring(0, 200) +
                                        "...."
                                    : widget.post.selfText,
                          )
                        : null,
                  ),
                  (widget.post.type == PostType.GALLERY)
                      ? Container(
                          height: 300,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              PhotoViewGallery.builder(
                                onPageChanged: (index) {
                                  setState(() {
                                    currentImageIndex = index + 1;
                                  });
                                },
                                itemCount: widget.post.galleryLink.length,
                                builder: (ctx, index) {
                                  return PhotoViewGalleryPageOptions(
                                    minScale:
                                        PhotoViewComputedScale.contained * .8,
                                    maxScale:
                                        PhotoViewComputedScale.contained * 1.2,
                                    imageProvider: CachedNetworkImageProvider(
                                      widget.post.galleryLink[index],
                                    ),
                                  );
                                },
                                loadingBuilder: (ctx, event) {
                                  return Center(
                                    child: Container(
                                      width: 30.0,
                                      height: 30.0,
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.orange,
                                        value: event == null
                                            ? 0
                                            : event.cumulativeBytesLoaded /
                                                event.expectedTotalBytes!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  child: Text(
                                    "$currentImageIndex/${widget.post.galleryLink.length}",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : (widget.post.type == PostType.IMAGE)
                          ? CachedNetworkImage(
                              imageUrl: widget.post.link,
                              progressIndicatorBuilder:
                                  (context, url, progress) => Center(
                                        child: Container(
                                          width: 30.0,
                                          height: 30.0,
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.orange,
                                            value: progress.progress,
                                          ),
                                        ),
                                      ))
                          : (widget.post.type == PostType.VIDEO ||
                                  widget.post.type == PostType.GIF)
                              ? SizedBox(
                                  child: Chewie(controller: chewieController!),
                                  height: widget.post.height,
                                )
                              : (widget.post.type == PostType.LINK)
                                  ? LinkPreviewGenerator(
                                      placeholderWidget:
                                          CircularProgressIndicator(
                                              backgroundColor: Colors.orange),
                                      titleStyle: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.copyWith(fontSize: 16),
                                      backgroundColor:
                                          Color.fromRGBO(47, 50, 54, 1.0),
                                      borderRadius: 0,
                                      bodyMaxLines: 3,
                                      link: widget.post.link,
                                      linkPreviewStyle: LinkPreviewStyle.small,
                                      removeElevation: true,
                                      showGraphic: true,
                                    )
                                  : Container(),
                  Row(
                    children: [
                      IconButton(
                          splashRadius: 20,
                          color: isUpvoted
                              ? Theme.of(context).accentColor
                              : Colors.white,
                          onPressed: () => {
                                isUpvoted
                                    ? {
                                        widget.post.submission.clearVote(),
                                        setState(() {
                                          isUpvoted = false;
                                          votes--;
                                          print(votes);
                                        })
                                      }
                                    : {
                                        widget.post.submission.upvote(),
                                        setState(() {
                                          isUpvoted = true;
                                          isDownvoted = false;
                                          votes++;
                                          print(votes);
                                        })
                                      }
                              },
                          icon: Icon(Icons.arrow_upward_outlined)),
                      Text(votes.toString()),
                      IconButton(
                          splashRadius: 20,
                          color: isDownvoted
                              ? Theme.of(context).accentColor
                              : Colors.white,
                          onPressed: () => isDownvoted
                              ? {
                                  widget.post.submission.clearVote(),
                                  setState(() {
                                    isDownvoted = false;
                                    votes++;
                                  })
                                }
                              : {
                                  widget.post.submission.downvote(),
                                  setState(() {
                                    isUpvoted = false;
                                    isDownvoted = true;
                                    votes--;
                                  })
                                },
                          icon: Icon(Icons.arrow_downward_outlined)),
                      IconButton(
                          splashRadius: 20,
                          onPressed: () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CommentsScreen(widget.post),
                                    ))
                              },
                          icon: Icon(Icons.message_outlined)),
                      Text(widget.post.numComments.toString()),
                      Expanded(
                        child: Align(
                          child: IconButton(
                            splashRadius: 20,
                            onPressed: () => {
                              Share.share(
                                  widget.post.submission.shortlink.toString())
                            },
                            icon: Icon(Icons.share),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
  }
}
