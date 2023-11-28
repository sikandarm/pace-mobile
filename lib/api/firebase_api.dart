import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/constants.dart';

class FirebaseApi {
  final _firebaseMessasing = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final channel = const AndroidNotificationChannel('high_importance_channel',
      'High Importance Notifications', 'This channel is used for notifications',
      importance: Importance.high, playSound: true);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await _firebaseMessasing
        .requestPermission(); // requesting permission from the user
    final fcmToken = await _firebaseMessasing.getToken();
    print("FCM Token: $fcmToken");

    saveStringToSP(fcmToken!, BL_FCM_TOKEN);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Title: ${message.notification!.title}");
    print("Body: ${message.notification!.body}");
    print("Data: ${message.data}");
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;
        return user;
      }
    } catch (error) {
      print("Error during Google Sign-In: $error");
    }
    return null;
  }

  // Future<void> signInWithFacebook() async {
  //   try {
  //     final result = await FacebookAuth.instance.login();
  //     if (result.status == LoginStatus.success) {
  //       print('Facebook Sign-In SUCCESS');
  //       final AccessToken accessToken = result.accessToken!;
  //       // Use accessToken.token to get the access token.
  //       print('Access Token: ${accessToken.token}');
  //       // Use accessToken.userId to get the Facebook user ID.
  //       print('User ID: ${accessToken.userId}');
  //       // You can now use this access token and user ID to authenticate your users in your backend.
  //     } else {
  //       // Handle Facebook sign-in failure.
  //       print('Facebook Sign-In Failed');
  //     }
  //   } catch (e) {
  //     print('Error during Facebook Sign-In: $e');
  //   }
  // }
}
