## [0.3.1] - 25 January 2019
* Bumped `flutter_webview_plugin` dependency for Flutter 1.0 compatibility

## [0.3.0] - 18 January 2019
* Updated with new Slack icon
* Refactored widgets to Stateless where possible

## [0.2.1] - 18 October 2018
* **BREAKING - Required for Flutter 0.9.4 beta**
* Updated deprecated dependencies.

## [0.2.0] - 28 September 2018
* Updated deprecated dependencies.

## [0.0.4] - 28 May 2018
* Bugfix in tokenReceived function, thanks to [js1972](https://github.com/js1972) for pointing it out.

## [0.0.3] - 18 May 2018
* Clear the cache and cookies on webview access.

## [0.0.2] - 10 April 2018
* Updated `flutter_slack_oauth` dependency to support Flutter Beta 2 (and Dart 2).

## [0.0.1] - 30 March 2018
* Initial release
* The resulting access token is stored in Firebase Firestore in the `slackAccessToken` collection.
* User info returned from the Slack login is stored in Firebase Firestore in the `users` collection.
* Both collections contain documents with the Slack UID as the document name.
