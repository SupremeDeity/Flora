import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class RedditInstanceState with ChangeNotifier {
  late Reddit _instance;
  bool _isAuthenticated = false;
  Map _user = Map();

  RedditInstanceState(instance) {
    _instance = instance;
  }

  Reddit get getInstance {
    // if (_isAuthenticated) {
    //   refresh();
    // }

    return _instance;
  }

  bool get getIsAuthenticated {
    return _isAuthenticated;
  }

  Map get getUser => _user;

  void refresh() async {
    if (!_instance.auth.isValid) {
      _isAuthenticated = false;
      if (_instance.auth.credentials.canRefresh) {
        await _instance.auth.credentials.refresh();
      }
    }
  }

  void setInstance(Reddit instance) {
    _instance = instance;
    notifyListeners();
  }

  void setIsAuth(bool isAuth) {
    _isAuthenticated = isAuth;
    notifyListeners();
  }

  void setUser(Map user) {
    _user = user;
    notifyListeners();
  }
}
