library flutter_slack_oauth_firebase;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slack_oauth/flutter_slack_oauth.dart';
import 'package:flutter_slack_oauth/oauth/generic_slack_button.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class FirebaseSlackButton extends StatefulWidget {
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
  _FirebaseSlackButtonState createState() => new _FirebaseSlackButtonState();
}

class _FirebaseSlackButtonState extends State<FirebaseSlackButton>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return new GenericSlackButton(
        clientId: widget.clientId,
        clientSecret: widget.clientSecret,
        onSuccess: widget.onSuccess,
        onCancelledByUser: widget.onCancelledByUser,
        onFailure: widget.onFailure,
        onTap: onTap);
  }

  onTap() async {
    bool success;

    if (widget.firebaseUrl != null && widget.firebaseUrl.isNotEmpty) {
      success = await Navigator.of(context).push(new MaterialPageRoute<bool>(
            builder: (BuildContext context) =>
                new FirebaseSlackLoginWebViewPage(
                  clientId: widget.clientId,
                  clientSecret: widget.clientSecret,
                  redirectUrl: widget.redirectUrl == null
                      ? "https://kunstmaan.github.io/flutter_slack_oauth/success.html"
                      : widget.redirectUrl,
                  firebaseUrl: widget.firebaseUrl,
                ),
          ));
    } else {
      success = await Navigator.of(context).push(new MaterialPageRoute<bool>(
            builder: (BuildContext context) => new SlackLoginWebViewPage(
                  clientId: widget.clientId,
                  clientSecret: widget.clientSecret,
                  redirectUrl: widget.redirectUrl == null
                      ? "https://kunstmaan.github.io/flutter_slack_oauth/success.html"
                      : widget.redirectUrl,
                ),
          ));

      // if success == null, user just closed the webview
    }
    if (success == null) {
      widget.onCancelledByUser();
    } else if (!success) {
      widget.onFailure();
    } else {
      widget.onSuccess();
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
