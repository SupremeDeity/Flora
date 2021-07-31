import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:draw/draw.dart';
import 'package:flora/globalState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:photo_view/photo_view.dart';

import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PostCard extends StatefulWidget {
  PostCard(this.post, {Key? key}) : super(key: key);
  Submission post;

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
  String video_link = "";
  bool overflow = false;

  // Video Player
  late VideoPlayerController? videoPlayerController;
  late ChewieController? chewieController;

  setRedditorAvatar() async {
    await Provider.of<RedditInstanceState>(context, listen: false)
        .getInstance
        .redditor(widget.post.author)
        .populate()
        .then((value) => {
              if (mounted)
                {
                  setState(() {
                    redditorAvatar = value.data!['icon_img'];
                  })
                }
            });
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        isUpvoted = widget.post.vote == VoteState.upvoted;
        isDownvoted = widget.post.vote == VoteState.downvoted;
        votes = widget.post.score;
      });
      setRedditorAvatar();
      if (widget.post.isVideo) {
        setState(() {
          video_link = widget.post.data!['media']['reddit_video']['hls_url'];
          print(video_link);
          videoPlayerController = VideoPlayerController.network(
            widget.post.data!['media']['reddit_video']['hls_url'],
          );
        });
        videoPlayerController!.initialize();
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          allowPlaybackSpeedChanging: false,
          looping: false,
        );
      }
    }
  }

  @override
  void dispose() {
    if (widget.post.isVideo) {
      videoPlayerController!.dispose();
      chewieController!.dispose();
    }
    super.dispose();
  }

  galleryURLGenerator(int index) {
    var imageID =
        widget.post.data!['gallery_data'].values.first[index]['media_id'];

    var galleryMetadata = widget.post.data!['media_metadata'][imageID]['m'];
    var imageType = galleryMetadata == 'image/png' ? 'png' : 'jpg';

    return 'https://i.redd.it/$imageID.$imageType';
  }

  refreshPost() async {
    await widget.post.refresh().then((value) => setState(() {
          widget.post = value.first;
          votes = widget.post.score;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                foregroundImage: redditorAvatar != ""
                    ? CachedNetworkImageProvider(redditorAvatar)
                    : null,
              ),
              title: Text(widget.post.author),
              subtitle: Text(widget.post.data!['subreddit_name_prefixed']),
              trailing: IconButton(
                  onPressed: () => {}, icon: Icon(Icons.star_border)),
            ),
            ListTile(
              title: Text(widget.post.title),
              subtitle: widget.post.isSelf
                  ? MarkdownBody(
                      data: (widget.post.selftext!.length > 200 && !overflow)
                          ? widget.post.selftext!.substring(0, 200) + "...."
                          : widget.post.selftext!,
                    )
                  : null,
            ),
            (widget.post.data!['is_gallery'] != null)
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
                          itemCount: widget.post.data!['media_metadata'].length,
                          builder: (ctx, index) {
                            return PhotoViewGalleryPageOptions(
                              minScale: PhotoViewComputedScale.contained * .8,
                              maxScale: PhotoViewComputedScale.contained * 1.2,
                              imageProvider: CachedNetworkImageProvider(
                                galleryURLGenerator(index),
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
                              "$currentImageIndex/${widget.post.data!['media_metadata'].length}",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : (widget.post.data!['url'].toString() != "" &&
                        widget.post.data!['post_hint'] == 'image')
                    ? CachedNetworkImage(
                        imageUrl: widget.post.data!['url'].toString(),
                        progressIndicatorBuilder: (context, url, progress) =>
                            Center(
                              child: Container(
                                width: 30.0,
                                height: 30.0,
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.orange,
                                  value: progress.progress,
                                ),
                              ),
                            ))
                    : (widget.post.isVideo)
                        ? Chewie(controller: chewieController!)
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
                                  widget.post.clearVote(),
                                  setState(() {
                                    isUpvoted = false;
                                    votes = votes--;
                                  })
                                }
                              : {
                                  widget.post.upvote(),
                                  setState(() {
                                    isUpvoted = true;
                                    isDownvoted = false;
                                    votes = votes++;
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
                            widget.post.clearVote(),
                            setState(() {
                              isDownvoted = false;
                              votes = votes++;
                            })
                          }
                        : {
                            widget.post.downvote(),
                            setState(() {
                              isUpvoted = false;
                              isDownvoted = true;
                              votes = votes--;
                            })
                          },
                    icon: Icon(Icons.arrow_downward_outlined)),
                IconButton(
                    splashRadius: 20,
                    onPressed: () => {},
                    icon: Icon(Icons.message_outlined)),
                Text(widget.post.numComments.toString()),
                Expanded(
                  child: Align(
                    child: IconButton(
                      splashRadius: 20,
                      onPressed: () => {},
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
    );
  }
}
