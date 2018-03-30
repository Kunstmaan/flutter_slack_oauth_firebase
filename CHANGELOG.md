## [0.0.1] - 30 March 2018
* Initial release
* The resulting access token is stored in Firebase Firestore in the `slackAccessToken` collection.
* User info returned from the Slack login is stored in Firebase Firestore in the `users` collection.
* Both collections contain documents with the Slack UID as the document name.