import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slack_oauth_firebase/flutter_slack_oauth_firebase.dart';

void main() {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  runApp(new MaterialApp(
    home: new Scaffold(
      appBar: new AppBar(
        title: new Text("Slack OAuth Example"),
      ),
      body: new Builder(
        builder: (BuildContext context) {
          return new Center(
            child: new FirebaseSlackButton(
              clientId: "XXX_CLIENT_ID_XXX",
              clientSecret: "XXX_CLIENT_SECRET_XXX",
              redirectUrl:
                  "https://XXX-FIREBASE-PROJECT-XXX.firebaseapp.com/completed.html",
              firebaseUrl:
                  "https://XXX-FIREBASE-PROJECT-XXX.firebaseapp.com/index.html",
              onSuccess: () async {
                // get Firebase User:
                FirebaseUser user = await _auth.currentUser();

                Scaffold.of(context).showSnackBar(new SnackBar(
                      content: new Text('Logged in with Slack ID ' + user.uid),
                    ));
              },
              onFailure: () {
                Scaffold.of(context).showSnackBar(new SnackBar(
                      content: new Text('Slack Login Failed'),
                    ));
              },
              onCancelledByUser: () {
                Scaffold.of(context).showSnackBar(new SnackBar(
                      content: new Text('Slack Login Cancelled by user'),
                    ));
              },
            ),
          );
        },
      ),
    ),
  ));
}
