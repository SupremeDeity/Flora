import 'package:draw/draw.dart';
import 'package:flora/globalState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void authenticate(Reddit reddit) async {
  final authUrl = reddit.auth.url(['*'], 'flora_agent_auth');

  await canLaunch(authUrl.toString())
      ? await launch(
          authUrl.toString(),
        )
      : throw 'Could not launch $authUrl';
}

void completeAuth(Reddit reddit, String authCode, void Function() then) async {
  await reddit.auth
      .authorize(authCode)
      .whenComplete(() async => {setPrefs(reddit)})
      .then((value) => then());
}

void setPrefs(Reddit reddit) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('credentials', reddit.auth.credentials.toJson());
}

Future<bool> populateUserMap(BuildContext context) async {
  Provider.of<RedditInstanceState>(context, listen: false).setIsAuth(true);
  Map user = Map();

  await Provider.of<RedditInstanceState>(context, listen: false)
      .getInstance
      .user
      .me()
      .then((value) async => {
            user['displayName'] =
                value?.data!['subreddit']['display_name_prefixed'],
            user['awardeeKarma'] = value?.data!['awardee_karma'],
            user['awarderKarma'] = value?.data!['awarder_karma'],
            user['linkKarma'] = value?.linkKarma,
            user['commentKarma'] = value?.commentKarma,
            user['icon_img'] = value?.data!['subreddit']['icon_img']
                .toString()
                .replaceAll("&amp;", "&"),
            user['coins'] = value?.goldCreddits,
            await Provider.of<RedditInstanceState>(context, listen: false)
                .getInstance
                .user
                .subreddits()
                .toList()
                .then((value) => user['subreddits'] = value)
                .then((value) => {
                      Provider.of<RedditInstanceState>(context, listen: false)
                          .setUser(user),
                    })
          });

  return true;
}
