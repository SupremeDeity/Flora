import 'package:cached_network_image/cached_network_image.dart';
import 'package:draw/draw.dart';
import 'package:flora/State/RedditState.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloraDrawer extends StatefulWidget {
  FloraDrawer({Key? key}) : super(key: key);

  @override
  _FloraDrawerState createState() => _FloraDrawerState();
}

class _FloraDrawerState extends State<FloraDrawer> {
  var _username = "";
  var _karma = 0;
  var _img = "";
  var _loading = true;
  var _coins = 0;
  Map<String, String> _subreddits = {};

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<RedditInstanceState>(context, listen: false).getUser;

    var _listReddit = user['subreddits'] as List<Subreddit>;
    _listReddit.forEach((element) {
      var imgPath;
      if (!element.iconImage!.hasEmptyPath) {
        imgPath = element.iconImage.toString();
      } else if (element.data!['community_icon'] != null) {
        imgPath = element.data!['community_icon'];
      } else {
        imgPath = "";
      }

      _subreddits[element.displayName] = imgPath;
    });

    if (mounted) {
      setState(() {
        _username = user['displayName'];
        _karma = (user['commentKarma']! +
            user['linkKarma']! +
            user['awarderKarma']! +
            user['awardeeKarma']!);
        _img = user['icon_img'];
        _coins = user['coins'];
        _loading = false;
      });
    }

    return _loading
        ? Text("loading")
        : Drawer(
            child: Column(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: _img,
                          height: 64,
                          width: 64,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  ),
                                  Text("$_username",
                                      style: GoogleFonts.raleway(
                                          color: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .color,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.angleUp,
                                    color: Colors.orange,
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                  ),
                                  Text("$_karma",
                                      style: GoogleFonts.openSans(
                                          color: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .color,
                                          fontWeight: FontWeight.w400)),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                  ),
                                  FaIcon(
                                    FontAwesomeIcons.coins,
                                    color: Colors.yellow,
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                  ),
                                  Text("$_coins",
                                      style: GoogleFonts.openSans(
                                          color: Theme.of(context)
                                              .textTheme
                                              .subtitle2!
                                              .color,
                                          fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Account",
                      ),
                      leading: Icon(Icons.account_circle),
                      onTap: () => {print("Pressed")},
                    ),
                    ListTile(
                      leading: Icon(Icons.message_outlined),
                      title: Text("Messages"),
                      onTap: () => {print("Pressed")},
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text("Settings"),
                      onTap: () => {print("Pressed")},
                    ),
                    Divider(),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Icon(Icons.subscriptions),
                        title: Text("Subscriptions"),
                        initiallyExpanded: true,
                        children: [
                          Container(
                            margin: EdgeInsets.zero,
                            height: 300,
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: _subreddits.values
                                              .elementAt(index) !=
                                          ""
                                      ? CachedNetworkImage(
                                          imageUrl: _subreddits.values
                                              .elementAt(index),
                                          errorWidget: (ctx, url, error) =>
                                              FaIcon(
                                                  FontAwesomeIcons.redditAlien),
                                          height: 30,
                                          width: 30,
                                        )
                                      : FaIcon(FontAwesomeIcons.redditAlien),
                                  title:
                                      Text(_subreddits.keys.elementAt(index)),
                                );
                              },
                              itemCount: _subreddits.length - 1,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
  }
}
