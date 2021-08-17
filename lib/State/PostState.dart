import 'package:flora/PostScreen.dart';
import 'package:flora/Types/postType.dart';
import 'package:flutter/material.dart';

class PostState with ChangeNotifier {
  late Map<FilterType, List<Post>> _post;

  PostState(Map<FilterType, List<Post>> post) {
    _post = post;
  }

  List<Post>? getPosts(FilterType type) => _post[type];

  void updatePost(int index, FilterType type, Post post) {
    _post.update(type, (value) {
      List<Post> p = value;
      p[index] = post;
      return p;
    });
    notifyListeners();
  }

  void addPost(FilterType type, Post post) {
    _post.update(type, (value) {
      List<Post> p = value;
      p.add(post);
      return p;
    });
    notifyListeners();
  }

  void clearPost(FilterType type) {
    _post.update(type, (value) {
      return [];
    });
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}
