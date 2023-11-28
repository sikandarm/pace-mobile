import 'package:com_a3_pace/api/firebase_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/Dashboard.dart';
import 'screens/login_screen.dart';
import 'screens/midway_screen.dart';
import 'screens/notification.dart';
import 'screens/reset_password.dart';
import 'screens/signup_screen.dart';
import 'screens/splash.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      FirebaseApi().flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              FirebaseApi().channel.id,
              FirebaseApi().channel.name,
              'This channel is used for notifications',
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ));
    }
  });

// Required for handling messages in the background
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KEFC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/resetpassword': (context) => const ResetPassword(),
        '/midwayscreen': (context) => const MidwayScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/notification': (context) => const NotificationsScreen(),
        '/welcomeScreen': (context) => const WelcomeScreen(),
        // '/testScreen': (context) => const TestScreen(),
      },
    );
  }
}
