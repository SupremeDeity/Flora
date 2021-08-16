import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flora/Api/login.dart';
import 'package:flora/State/globalState.dart';
import 'package:flora/demo/demo.dart';
import 'package:flora/loadingScreen.dart';
import 'package:flora/loginScreen.dart';
import 'package:flora/State/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';
import 'package:provider/provider.dart';

import 'flora.dart';

final userAgent = 'flora_agent';
final configUri = Uri.parse('draw/draw.ini');
final redirectUri = Uri.parse('floraclient://auth');

void main() => runApp(MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (_) => RedditInstanceState(
          Reddit.createInstalledFlowInstance(
            userAgent: userAgent,
            configUri: configUri,
            clientId: "v3VoDgsElkXfn1epCYYhag",
            redirectUri: redirectUri,
          ),
        ),
      ),
    ], child: Flora()));

class Flora extends StatefulWidget {
  Flora({Key? key}) : super(key: key);

  @override
  _FloraState createState() => _FloraState();
}

class _FloraState extends State<Flora> with SingleTickerProviderStateMixin {
  StreamSubscription? _sub;
  bool loaded = false;
  bool isAuth = false;

  @override
  void dispose() {
    _sub!.cancel();
    super.dispose();
  }

  void _handleIncomingLinks() async {
    if (!kIsWeb) {
      _sub = uriLinkStream.listen((Uri? uri) async {
        if (!mounted) return;
        var entries = uri?.queryParametersAll.entries.toList();
        if (entries?.first.value.first == 'flora_agent_auth') {
          var codeEntry = entries?.elementAt(1);

          if (codeEntry?.key == 'code') {
            var redditInstance =
                Provider.of<RedditInstanceState>(context, listen: false)
                    .getInstance;

            completeAuth(
                redditInstance,
                codeEntry!.value.first,
                () => {
                      populateUserMap(context)
                          .then((value) => setState(() => {loaded = true}))
                    });
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((value) => {
          if (value.containsKey('credentials'))
            {
              print(value.getString('credentials')),
              Provider.of<RedditInstanceState>(context, listen: false)
                  .setInstance(Reddit.restoreInstalledAuthenticatedInstance(
                value.getString('credentials')!,
                userAgent: userAgent,
                configUri: configUri,
                clientId: "v3VoDgsElkXfn1epCYYhag",
                redirectUri: redirectUri,
              )),
              populateUserMap(context)
                  .then((value) => setState(() => {loaded = value}))
            }
        });

    _handleIncomingLinks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      setState(() {
        isAuth = Provider.of<RedditInstanceState>(context).getIsAuthenticated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // TODO: Make a theme system
      //themeMode: ThemeMode.system,
      theme: DefaultThemes().defaultDark,
      title: 'Flora',
      home:
          isAuth ? (loaded ? FloraHomePage() : LoadingScreen()) : LoginScreen(),
      // home: DemoScreen(),
      debugShowCheckedModeBanner: true,
    );
  }
}
