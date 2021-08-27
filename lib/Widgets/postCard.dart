import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:draw/draw.dart';
import 'package:flora/CommentsScreen.dart';
import 'package:flora/PostScreen.dart';
import 'package:flora/State/PostState.dart';
import 'package:flora/Types/postType.dart';
import 'package:flora/Widgets/RedditMarkdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:photo_view/photo_view.dart';

import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';

class PostCard extends StatefulWidget {
  PostCard(this.postIndex, this.type, {Key? key}) : super(key: key);
  final int postIndex;
  final FilterType type;

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
  bool change = false;

  // Video Player
  late VideoPlayerController? videoPlayerController;
  late ChewieController? chewieController;

  @override
  void initState() {
    print("postCard Init");
    super.initState();
    setState(() {
      isUpvoted = Provider.of<PostState>(context, listen: false)
          .getPosts(widget.type)![widget.postIndex]
          .isUpvoted;
      isDownvoted = Provider.of<PostState>(context, listen: false)
          .getPosts(widget.type)![widget.postIndex]
          .isDownvoted;
      votes = Provider.of<PostState>(context, listen: false)
          .getPosts(widget.type)![widget.postIndex]
          .votes;
      _isSaved = Provider.of<PostState>(context, listen: false)
          .getPosts(widget.type)![widget.postIndex]
          .saved;

      print('isSaved: $_isSaved');

      if (Provider.of<PostState>(context, listen: false)
                  .getPosts(widget.type)![widget.postIndex]
                  .type ==
              PostType.VIDEO ||
          Provider.of<PostState>(context, listen: false)
                  .getPosts(widget.type)![widget.postIndex]
                  .type ==
              PostType.GIF) {
        videoLink = Provider.of<PostState>(context, listen: false)
            .getPosts(widget.type)![widget.postIndex]
            .link;
        videoPlayerController = VideoPlayerController.network(
          videoLink,
        );
      }

      if (Provider.of<PostState>(context, listen: false)
                  .getPosts(widget.type)![widget.postIndex]
                  .type ==
              PostType.VIDEO ||
          Provider.of<PostState>(context, listen: false)
                  .getPosts(widget.type)![widget.postIndex]
                  .type ==
              PostType.GIF) {
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
    if (Provider.of<PostState>(context, listen: false)
            .getPosts(widget.type)![widget.postIndex]
            .type ==
        PostType.VIDEO) {
      videoPlayerController!.dispose();
      chewieController!.dispose();
    }
    super.dispose();
  }

  onVote(bool upvote, {bool clearVote = false}) {
    Post _post = Provider.of<PostState>(context, listen: false)
        .getPosts(widget.type)![widget.postIndex];

    // Clear any votes and then vote appropriately.
    _post.submission.clearVote();
    if (!clearVote) {
      upvote ? _post.submission.upvote() : _post.submission.downvote();
    }

    // Update internal state
    setState(() {
      upvote ? votes++ : votes--;
    });

    // Update PostState
    _post.setVotes = votes;
    _post.setVoted = clearVote
        ? VoteState.none
        : upvote
            ? VoteState.upvoted
            : VoteState.downvoted;

    // Notify of changes
    Provider.of<PostState>(context, listen: false).notify();
  }

  onSave(bool save) {
    Post _post = Provider.of<PostState>(context, listen: false)
        .getPosts(widget.type)![widget.postIndex];

    // Save/unsave the post
    save ? _post.submission.save() : _post.submission.unsave();

    // Update internal state
    setState(() {
      _isSaved = save;
    });

    // Update PostState
    _post.setSaved = save;

    // Notify of changes
    Provider.of<PostState>(context, listen: false).notify();
  }

  @override
  Widget build(BuildContext context) {
    print("post card build call");
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
                      foregroundImage: Provider.of<PostState>(context)
                                  .getPosts(widget.type)![widget.postIndex]
                                  .avatar !=
                              ""
                          ? CachedNetworkImageProvider(
                              Provider.of<PostState>(context)
                                  .getPosts(widget.type)![widget.postIndex]
                                  .avatar!)
                          : null,
                      child: Provider.of<PostState>(context)
                                  .getPosts(widget.type)![widget.postIndex]
                                  .avatar ==
                              ""
                          ? FaIcon(FontAwesomeIcons.redditAlien)
                          : null,
                      backgroundColor: Color.fromARGB(0, 0, 0, 0),
                    ),
                    title: Text(Provider.of<PostState>(context)
                        .getPosts(widget.type)![widget.postIndex]
                        .authorName),
                    subtitle: Text(Provider.of<PostState>(context)
                        .getPosts(widget.type)![widget.postIndex]
                        .subredditName),
                    trailing: IconButton(
                        onPressed: () => {
                              Provider.of<PostState>(context, listen: false)
                                      .getPosts(widget.type)![widget.postIndex]
                                      .saved
                                  ? onSave(false)
                                  : onSave(true),
                            },
                        icon: Provider.of<PostState>(context)
                                .getPosts(widget.type)![widget.postIndex]
                                .saved
                            ? Icon(Icons.bookmark_added_rounded)
                            : Icon(Icons.bookmark_add_outlined)),
                  ),
                  Divider(color: Colors.black54),
                  ListTile(
                    title: Text(Provider.of<PostState>(context)
                        .getPosts(widget.type)![widget.postIndex]
                        .title),
                    subtitle: Provider.of<PostState>(context)
                                .getPosts(widget.type)![widget.postIndex]
                                .type ==
                            PostType.SELF
                        ? RedditMarkdown(
                            data: (Provider.of<PostState>(context)
                                            .getPosts(
                                                widget.type)![widget.postIndex]
                                            .selfText
                                            .length >
                                        200 &&
                                    !overflow)
                                ? Provider.of<PostState>(context)
                                        .getPosts(
                                            widget.type)![widget.postIndex]
                                        .selfText
                                        .substring(0, 200) +
                                    "...."
                                : Provider.of<PostState>(context)
                                    .getPosts(widget.type)![widget.postIndex]
                                    .selfText,
                          )
                        : null,
                  ),
                  (Provider.of<PostState>(context)
                              .getPosts(widget.type)![widget.postIndex]
                              .type ==
                          PostType.GALLERY)
                      ? SizedBox(
                          height: 300,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              PhotoViewGallery.builder(
                                pageController: PageController(initialPage: 0),
                                onPageChanged: (index) {
                                  setState(() {
                                    currentImageIndex = index + 1;
                                  });
                                },
                                itemCount: Provider.of<PostState>(context)
                                    .getPosts(widget.type)![widget.postIndex]
                                    .galleryLink
                                    .length,
                                builder: (ctx, index) {
                                  return PhotoViewGalleryPageOptions(
                                    minScale:
                                        PhotoViewComputedScale.contained * .8,
                                    maxScale:
                                        PhotoViewComputedScale.contained * 1.2,
                                    imageProvider: CachedNetworkImageProvider(
                                      Provider.of<PostState>(context)
                                          .getPosts(
                                              widget.type)![widget.postIndex]
                                          .galleryLink[index],
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
                                    "$currentImageIndex/${Provider.of<PostState>(context).getPosts(widget.type)![widget.postIndex].galleryLink.length}",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : (Provider.of<PostState>(context)
                                  .getPosts(widget.type)![widget.postIndex]
                                  .type ==
                              PostType.IMAGE)
                          ? SizedBox(
                              child: CachedNetworkImage(
                                  imageUrl: Provider.of<PostState>(context)
                                      .getPosts(widget.type)![widget.postIndex]
                                      .link,
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
                                          )),
                            )
                          : (Provider.of<PostState>(context)
                                          .getPosts(
                                              widget.type)![widget.postIndex]
                                          .type ==
                                      PostType.VIDEO ||
                                  Provider.of<PostState>(context)
                                          .getPosts(
                                              widget.type)![widget.postIndex]
                                          .type ==
                                      PostType.GIF)
                              ? SizedBox(
                                  child: Chewie(controller: chewieController!),
                                  height: Provider.of<PostState>(context)
                                      .getPosts(widget.type)![widget.postIndex]
                                      .height,
                                )
                              : (Provider.of<PostState>(context)
                                          .getPosts(
                                              widget.type)![widget.postIndex]
                                          .type ==
                                      PostType.LINK)
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
                                      link: Provider.of<PostState>(context)
                                          .getPosts(
                                              widget.type)![widget.postIndex]
                                          .link,
                                      linkPreviewStyle: LinkPreviewStyle.large,
                                      removeElevation: true,
                                      showGraphic: true,
                                    )
                                  : Container(),
                  Row(
                    children: [
                      IconButton(
                          splashRadius: 20,
                          color: Provider.of<PostState>(context)
                                  .getPosts(widget.type)![widget.postIndex]
                                  .isUpvoted
                              ? Theme.of(context).accentColor
                              : Colors.white,
                          onPressed: () => {
                                Provider.of<PostState>(context, listen: false)
                                        .getPosts(
                                            widget.type)![widget.postIndex]
                                        .isUpvoted
                                    ? onVote(false, clearVote: true)
                                    : onVote(true)
                              },
                          icon: Icon(Icons.arrow_upward_outlined)),
                      Text(Provider.of<PostState>(context)
                          .getPosts(widget.type)![widget.postIndex]
                          .votes
                          .toString()),
                      IconButton(
                          splashRadius: 20,
                          color: Provider.of<PostState>(context, listen: false)
                                  .getPosts(widget.type)![widget.postIndex]
                                  .isDownvoted
                              ? Theme.of(context).accentColor
                              : Colors.white,
                          onPressed: () =>
                              Provider.of<PostState>(context, listen: false)
                                      .getPosts(widget.type)![widget.postIndex]
                                      .isDownvoted
                                  ? onVote(false, clearVote: true)
                                  : onVote(false),
                          icon: Icon(Icons.arrow_downward_outlined)),
                      IconButton(
                          splashRadius: 20,
                          onPressed: () => {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommentsScreen(
                                        Provider.of<PostState>(context,
                                                listen: false)
                                            .getPosts(widget.type)!
                                            .indexOf(
                                              Provider.of<PostState>(context,
                                                          listen: false)
                                                      .getPosts(widget.type)![
                                                  widget.postIndex],
                                            ),
                                        type: widget.type,
                                      ),
                                    ))
                              },
                          icon: Icon(Icons.message_outlined)),
                      Text(Provider.of<PostState>(context)
                          .getPosts(widget.type)![widget.postIndex]
                          .numComments
                          .toString()),
                      Expanded(
                        child: Align(
                          child: IconButton(
                            splashRadius: 20,
                            onPressed: () => {
                              Share.share(
                                  Provider.of<PostState>(context, listen: false)
                                      .getPosts(widget.type)![widget.postIndex]
                                      .submission
                                      .shortlink
                                      .toString())
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
