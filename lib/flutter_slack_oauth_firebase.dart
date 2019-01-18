library flutter_slack_oauth_firebase;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slack_oauth/flutter_slack_oauth.dart';
import 'package:flutter_slack_oauth/oauth/generic_slack_button.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class FirebaseSlackButton extends StatelessWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancelledByUser;
  final VoidCallback onFailure;

  final String clientId;
  final String clientSecret;
  final String redirectUrl;

  final String firebaseUrl;

  const FirebaseSlackButton(
      {@required this.clientId,
      @required this.clientSecret,
      @required this.onSuccess,
      @required this.onCancelledByUser,
      @required this.onFailure,
      this.redirectUrl,
      this.firebaseUrl});

  bool get enabled => onSuccess != null;

  @override
  Widget build(BuildContext context) {
    return new GenericSlackButton(
        clientId: clientId,
        clientSecret: clientSecret,
        onSuccess: onSuccess,
        onCancelledByUser: onCancelledByUser,
        onFailure: onFailure,
        onTap: () { onTap(context); });
  }

  onTap(BuildContext context) async {
    bool success;

    if (firebaseUrl != null && firebaseUrl.isNotEmpty) {
      success = await Navigator.of(context).push(new MaterialPageRoute<bool>(
        builder: (BuildContext context) =>
        new FirebaseSlackLoginWebViewPage(
          clientId: clientId,
          clientSecret: clientSecret,
          redirectUrl: redirectUrl == null
              ? "https://kunstmaan.github.io/flutter_slack_oauth/success.html"
              : redirectUrl,
          firebaseUrl: firebaseUrl,
        ),
      ));
    } else {
      success = await Navigator.of(context).push(new MaterialPageRoute<bool>(
        builder: (BuildContext context) => new SlackLoginWebViewPage(
          clientId: clientId,
          clientSecret: clientSecret,
          redirectUrl: redirectUrl == null
              ? "https://kunstmaan.github.io/flutter_slack_oauth/success.html"
              : redirectUrl,
        ),
      ));

      // if success == null, user just closed the webview
    }
    if (success == null) {
      onCancelledByUser();
    } else if (!success) {
      onFailure();
    } else {
      onSuccess();
    }
  }
}



class FirebaseSlackLoginWebViewPage extends StatefulWidget {
  const FirebaseSlackLoginWebViewPage({
    this.clientId,
    this.clientSecret,
    this.redirectUrl,
    this.firebaseUrl,
  });

  final String clientId;
  final String clientSecret;
  final String redirectUrl;
  final String firebaseUrl;

  @override
  _FirebaseSlackLoginWebViewPageState createState() =>
      new _FirebaseSlackLoginWebViewPageState();
}

class _FirebaseSlackLoginWebViewPageState
    extends State<FirebaseSlackLoginWebViewPage> {
  bool setupUrlChangedListener = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final flutterWebviewPlugin = new FlutterWebviewPlugin();

    if (!setupUrlChangedListener) {
      flutterWebviewPlugin.onUrlChanged.listen((String changedUrl) async {
        if (changedUrl.startsWith(widget.redirectUrl)) {
          Uri uri = new Uri().resolve(changedUrl);
          String customToken = uri.queryParameters["customToken"];

          FirebaseUser user =
              await _auth.signInWithCustomToken(token: customToken);

          if (user != null) {
            Navigator.of(context).pop(true);
          } else {
            Navigator.of(context).pop(false);
          }
        }
      });
      setupUrlChangedListener = true;
    }

    return new WebviewScaffold(
      appBar: new AppBar(
        title: new Text("Log in with Slack"),
      ),
      url: widget.firebaseUrl,
      clearCookies: true,
      clearCache: true,
    );
  }
}
