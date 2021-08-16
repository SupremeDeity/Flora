import 'package:flora/Api/login.dart';
import 'package:flora/State/globalState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_vintage_outlined,
              size: 60,
            ),
            Text(
              "Flora",
              style: TextStyle(fontSize: 30),
            ),
            ElevatedButton.icon(
                onPressed: () => {
                      authenticate(Provider.of<RedditInstanceState>(context,
                              listen: false)
                          .getInstance)
                    },
                icon: Icon(Icons.lock),
                label: Text("Login with Reddit"))
          ],
        ),
      ),
    );
  }
}
