/**
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
'use strict';

const functions = require('firebase-functions');
const cookieParser = require('cookie-parser');
const crypto = require('crypto');

// Firebase Setup
const admin = require('firebase-admin');
const serviceAccount = require('./service-account.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const OAUTH_REDIRECT_URI = `https://${process.env.GCLOUD_PROJECT}.firebaseapp.com/index.html`;
const OAUTH_SCOPES = 'identity.basic,identity.team,identity.email';

/**
 * Creates a configured simple-oauth2 client for Slack.
 */
function slackOAuth2Client() {
  // Slack OAuth 2 setup
  // Configured the `slack.client_id` and `slack.client_secret` Google Cloud environment variables.
  const credentials = {
    client: {
      id: functions.config().slack.client_id,
      secret: functions.config().slack.client_secret,
    },
    auth: {
      tokenHost: 'https://slack.com',
      tokenPath: '/api/oauth.access',
    },
  };
  return require('simple-oauth2').create(credentials);
}

/**
 * Redirects the User to the Slack authentication consent screen. Also the 'state' cookie is set for later state
 * verification.
 */
exports.redirect = functions.https.onRequest((req, res) => {
  const oauth2 = slackOAuth2Client();

    const redirectUri = oauth2.authorizationCode.authorizeURL({
      redirect_uri: OAUTH_REDIRECT_URI,
      scope: OAUTH_SCOPES,
    });
    console.log('Redirecting to:', redirectUri);
    res.redirect(redirectUri);

});

/**
 * Exchanges a given Slack auth code passed in the 'code' URL query parameter for a Firebase auth token.
 * The request also needs to specify a 'state' query parameter which will be checked against the 'state' cookie.
 * The Firebase custom auth token, display name, photo URL and Slack acces token are sent back in a JSONP callback
 * function with function name defined by the 'callback' query parameter.
 */
exports.token = functions.https.onRequest((req, res) => {
  const oauth2 = slackOAuth2Client();

  try {
  
    console.log('Received auth code:', req.query.code);
      
    return oauth2.authorizationCode.getToken({
      code: req.query.code,
      redirect_uri: OAUTH_REDIRECT_URI,
    }).then((results) => {
      console.log('Auth code exchange result received:', results);

      // Create a Firebase account and get the Custom Auth Token.
      return createFirebaseAccount(results);
    }).then((firebaseToken) => {
      // Serve an HTML page that signs the user in and updates the user profile.
      return res.jsonp({
        token: firebaseToken,
      });
    });
  } catch (error) {
    return res.jsonp({
      error: error.toString,
    });
  }
});

/**
 * Creates a Firebase account with the given user profile and returns a custom auth token allowing
 * signing-in this account.
 * Also saves the accessToken to the datastore at /slackAccessToken/$uid
 *
 * @returns {Promise<string>} The Firebase custom auth token in a promise.
 */
function createFirebaseAccount(results) {
  // The UID we'll assign to the user.
  const uid = results.user.id;

  // Save the access token in FireStore
  return admin.firestore().collection('slackAccessTokens').doc(uid).set({accessToken: results.access_token}).then(() => {
    console.log('Stored slack access token in FireStore "', uid, '" Token:', results.access_token)
    return admin.firestore().collection('users').doc(uid).set(results.user).then(() => {
      console.log('Stored user in firestore "', results.user, '" Token:', results.access_token)
      return admin.auth().createCustomToken(uid, results).then((token) => {
        console.log('Created Custom token for UID "', uid, '" Token:', token);
        return token;
      })
    });
  });
}
