import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pace_application_fb/screens/facebook_email_screen.dart';
import 'package:pace_application_fb/theme/darkTheme.dart';

import 'api/firebase_api.dart';
import 'firebase_options.dart';
import 'screens/Dashboard.dart';
import 'screens/login_screen.dart';
import 'screens/midway_screen.dart';
import 'screens/notification.dart';
import 'screens/reset_password.dart';
import 'screens/signup_screen.dart';
import 'screens/splash.dart';
import 'screens/welcome_screen.dart';
import 'utils/constants.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

HttpOverrides global = MyHttpOverrides();

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//  await FirebaseApi().initNotifications();
  // SecurityContext.defaultContext.setAlpnProtocols(['h2'], true);
  await Hive.initFlutter();
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // FirebaseMessaging.instance.getToken();

  // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
  //   RemoteNotification? notification = message.notification;
  //   AndroidNotification? android = message.notification?.android;
  //   if (notification != null && android != null) {
  //     FirebaseApi().flutterLocalNotificationsPlugin.show(
  //         notification.hashCode,
  //         notification.title,
  //         notification.body,
  //         NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             FirebaseApi().channel.id,
  //             FirebaseApi().channel.name,
  //             'This channel is used for notifications',
  //             color: Colors.blue,
  //             playSound: true,
  //             icon: '@mipmap/ic_launcher',
  //           ),
  //         ));
  //   }
  // });

  ////////////////////////////////////

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
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
              //   'This channel is used for notifications',
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ));
    }
  });

  /////////////////////////////////////

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    hasNewNotifiaction = true;
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
              //  'This channel is used for notifications',
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ));
    }
  });

// Required for handling messages in the background
  runApp(
    EasyDynamicThemeWidget(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light(useMaterial3: true),
      dark: DarkTheme.themeData(context),
      //  debugShowFloatingThemeButton: true,
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'KEFC',
        debugShowCheckedModeBanner: false,
        //  themeMode: EasyDynamicTheme.of(context).themeMode,
        darkTheme: darkTheme,

        theme: theme,
        // ThemeData(
        //   primarySwatch: Colors.blue,
        //   useMaterial3: true,
        //   // fontFamily: 'Manrope',
        //   //  fontFamily: 'Montserrat',
        //   //  textTheme: GoogleFonts.nunitoSansTextTheme(),
        //   // textTheme: GoogleFonts.nunitoTextTheme(),
        //   //  textTheme: GoogleFonts.montserratTextTheme(),
        //   //    textTheme: GoogleFonts.instrumentSansTextTheme(),  looks somewhat better
        //   // textTheme: GoogleFonts.merriweatherTextTheme(),     looks somewhat better
        //   //  textTheme: GoogleFonts.robotoSlabTextTheme(),  looks somewhata better and close to professional
        //   // textTheme: GoogleFonts.ptSansTextTheme(),  looks somewhata better and close to professional
        //   // textTheme: GoogleFonts.kanitTextTheme(), looks somewhata better and close to professional
        //   // textTheme: GoogleFonts.firaSansTextTheme(),
        //   //  looks MOST better and close to professional
        //   fontFamily: 'FiraSans',
        // ),

        //     home: SplashScreen(),
        initialRoute: '/',
        //  home: FacebookEmailScreen(fbID: ''),
        // home: LoginScreen(),

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
      ),
    );
  }
  // );
  // return MaterialApp(
  //   title: 'KEFC',
  //   debugShowCheckedModeBanner: false,
  //   themeMode: EasyDynamicTheme.of(context).themeMode,
  //   darkTheme: DarkTheme.themeData(context),
  //   theme: ThemeData(
  //     primarySwatch: Colors.blue,
  //     useMaterial3: true,
  //     // fontFamily: 'Manrope',
  //     //  fontFamily: 'Montserrat',
  //     //  textTheme: GoogleFonts.nunitoSansTextTheme(),
  //     // textTheme: GoogleFonts.nunitoTextTheme(),
  //     //  textTheme: GoogleFonts.montserratTextTheme(),
  //     //    textTheme: GoogleFonts.instrumentSansTextTheme(),  looks somewhat better
  //     // textTheme: GoogleFonts.merriweatherTextTheme(),     looks somewhat better
  //     //  textTheme: GoogleFonts.robotoSlabTextTheme(),  looks somewhata better and close to professional
  //     // textTheme: GoogleFonts.ptSansTextTheme(),  looks somewhata better and close to professional
  //     // textTheme: GoogleFonts.kanitTextTheme(), looks somewhata better and close to professional
  //     // textTheme: GoogleFonts.firaSansTextTheme(),
  //     //  looks MOST better and close to professional
  //     fontFamily: 'FiraSans',
  //   ),

  //   //     home: SplashScreen(),
  //   initialRoute: '/',
  //   //  home: FacebookEmailScreen(fbID: ''),
  //   // home: LoginScreen(),

  //   routes: {
  //     '/': (context) => const SplashScreen(),
  //     '/login': (context) => const LoginScreen(),
  //     '/resetpassword': (context) => const ResetPassword(),
  //     '/midwayscreen': (context) => const MidwayScreen(),
  //     '/signup': (context) => const SignUpScreen(),
  //     '/dashboard': (context) => const DashboardScreen(),
  //     '/notification': (context) => const NotificationsScreen(),
  //     '/welcomeScreen': (context) => const WelcomeScreen(),

  //     // '/testScreen': (context) => const TestScreen(),
  //   },
  // );
}
