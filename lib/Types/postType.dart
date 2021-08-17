import 'package:draw/draw.dart';
import 'package:flutter/foundation.dart';

enum PostType { LINK, IMAGE, GIF, VIDEO, SELF, GALLERY }

class Post {
  Post(this._post);

  Submission _post;
  String _fullname = "";
  String _subredditName = "";
  String _authorName = "";
  String _authorAvatar = "";
  String _title = "";
  String _selfText = "";
  int _votes = 0;
  int _numComments = 0;
  PostType _type = PostType.SELF;
  bool _isUpvoted = false;
  bool _isDownvoted = false;
  bool _isSaved = false;
  String _link = "";
  List<String> _galleryLink = [];
  double _height = 0;

  _getPostType() {
    if (_post.data!['url'].toString() != "" &&
        _post.data!['post_hint'] == 'image') {
      this._setType = PostType.IMAGE;
    }
    if (_post.isSelf) {
      this._setType = PostType.SELF;
    }
    if (_post.isVideo) {
      // Determine whether its a GIF or MP4
      if (_post.data!['media']['reddit_video']['is_gif']) {
        this._setType = PostType.GIF;
      } else {
        this._setType = PostType.VIDEO;
      }
    }
    if (_post.data!['post_hint'] != null) {
      if (_post.data!['post_hint'] == 'link' ||
          _post.data!['post_hint'] == 'rich:video') {
        this._setType = PostType.LINK;
      }
    }
    // is_gallery is non-null when true
    if (_post.data!['is_gallery'] != null) {
      this._setType = PostType.GALLERY;
    }
  }

  /// Populates the fields by parsing [Submission]
  Future parse() async {
    this._setFullName = _post.fullname!;
    this._setAuthorName = _post.author;
    this._setSubredditName = _post.data!['subreddit_name_prefixed'];
    this._setTitle = _post.title;
    this._setSelfText = _post.selftext;
    this.setVotes = _post.score;
    this.setNumComents = _post.numComments;
    this.setVoted = _post.vote;
    this._isSaved = _post.saved;
    _getPostType();

    await _post.reddit
        .redditor(_post.author)
        .populate()
        .then((value) => {this._setAvatar = value.data!['icon_img']});

    if (_type == PostType.VIDEO) {
      this._setLink = _post.data!['media']['reddit_video']['hls_url'];
      this._setHeight =
          (_post.data!['media']['reddit_video']['height']).toDouble();
    }

    if (_type == PostType.GIF) {
      this._setLink = _post.data!['media']['reddit_video']['fallback_url'];
      this._setHeight =
          (_post.data!['media']['reddit_video']['height']).toDouble();
    }

    if (_type == PostType.GALLERY) {
      var _galleryLength = _post.data!['media_metadata'].length;

      for (int index = 0; index < _galleryLength; index++) {
        var _imageID =
            _post.data!['gallery_data'].values.first[index]['media_id'];

        var _galleryMetadata = _post.data!['media_metadata'][_imageID]['m'];
        var _imageType = _galleryMetadata == 'image/png' ? 'png' : 'jpg';
        this._setGalleryLink = 'https://i.redd.it/$_imageID.$_imageType';
      }
    }

    if (_type == PostType.IMAGE || _type == PostType.LINK) {
      var link = _post.data!['url'].toString();
      if (link.startsWith('/r/')) {
        this._setLink = "https://reddit.com" + link;
      } else {
        this._setLink = link;
      }
    }

    return;
  }

  String get fullname {
    return _fullname;
  }

  set _setFullName(String name) {
    _fullname = name;
  }

  double get height {
    return _height;
  }

  set _setHeight(double height) {
    _height = height;
  }

  String get authorName {
    return _authorName;
  }

  set _setAuthorName(String name) {
    _authorName = name;
  }

  String get subredditName {
    return _subredditName;
  }

  set _setSubredditName(String name) {
    _subredditName = name;
  }

  String? get avatar {
    return _authorAvatar;
  }

  set _setAvatar(String? avatar) {
    _authorAvatar = avatar!;
  }

  String get title {
    return _title;
  }

  set _setTitle(String title) {
    _title = title;
  }

  String get selfText {
    return _selfText;
  }

  set _setSelfText(String? selfText) {
    _selfText = selfText!;
  }

  int get votes {
    return _votes;
  }

  set setVotes(int votes) {
    _votes = votes;
  }

  int get numComments {
    return _numComments;
  }

  set setNumComents(int numComments) {
    _numComments = numComments;
  }

  PostType get type {
    return _type;
  }

  set _setType(PostType type) {
    _type = type;
  }

  bool get isUpvoted {
    return _isUpvoted;
  }

  set setVoted(VoteState state) {
    switch (state) {
      case VoteState.none:
        _isUpvoted = false;
        _isDownvoted = false;
        break;
      case VoteState.upvoted:
        _isUpvoted = true;
        _isDownvoted = false;
        break;
      case VoteState.downvoted:
        _isUpvoted = false;
        _isDownvoted = true;
        break;
    }
  }

  bool get isDownvoted {
    return _isDownvoted;
  }

  set _setGalleryLink(String link) {
    _galleryLink.add(link);
  }

  List<String> get galleryLink {
    return _galleryLink;
  }

  String get link {
    return _link;
  }

  set _setLink(String link) {
    _link = link;
  }

  bool get saved {
    return _isSaved;
  }

  set setSaved(bool saved) {
    _isSaved = saved;
  }

  Submission get submission {
    return _post;
  }

  Map<String, String> get object {
    return {
      "fullname": this.fullname,
      "subredditName": this.subredditName,
      "authorName": this.authorName,
      "authorAvatar": this.avatar ?? "",
      "title": this.title,
      "selfText": this.selfText,
      "votes": this.votes.toString(),
      "numComments": this.numComments.toString(),
      "type": this.type.toString(),
      "isUpvoted": this.isUpvoted.toString(),
      "isDownvoted": this.isDownvoted.toString(),
      "link": this.link,
      "_galleryLink": this.galleryLink.toString(),
    };
  }
}
