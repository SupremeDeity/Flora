import 'package:flora/bestPosts.dart';
import 'package:flora/drawer.dart';
import 'package:flora/postCard.dart';
import 'package:flutter/material.dart';

class FloraHomePage extends StatefulWidget {
  FloraHomePage({Key? key}) : super(key: key);

  @override
  _FloraHomePageState createState() => _FloraHomePageState();
}

List<Widget> _navs = [BestPostsRoute()];

class _FloraHomePageState extends State<FloraHomePage> {
  int _currentIndex = 0;

  onTap(index) => {
        setState(() => {_currentIndex = index})
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flora'),
        actions: [IconButton(onPressed: () => {}, icon: Icon(Icons.search))],
      ),
      body: _navs.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Best'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_fire_department), label: "Hot"),
          BottomNavigationBarItem(
              icon: Icon(Icons.flare_rounded), label: "New"),
        ],
        currentIndex: _currentIndex,
        onTap: onTap,
      ),
      drawer: FloraDrawer(),
    );
  }
}
