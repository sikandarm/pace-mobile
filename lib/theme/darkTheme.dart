import 'package:adaptive_theme/adaptive_theme.dart';
//import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData themeData(BuildContext context) {
    return ThemeData(
      // hintColor: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
      //     ? Colors.white
      //     : Colors.black,

      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.blueGrey,
        ),

        // Adjust color as needed
      ),
      brightness: Brightness.dark,

      // snackBarTheme: SnackBarThemeData(
      //   contentTextStyle: TextStyle(
      //     color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light
      //         ? Colors.black
      //         : Colors.white,
      //   ),

      //   backgroundColor:
      //       AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light
      //           ? Colors.white
      //           : Color.fromARGB(
      //               255, 7, 21, 32), // Change color as per your preference
      // ),

      iconTheme: IconThemeData(color: Colors.white),
      //   primaryColor: Colors.black.withOpacity(0.5),
//      accentColor: Color(0xFF2196F3),
      //   scaffoldBackgroundColor: Colors.black.withOpacity(0.5),

      cardTheme: CardTheme(
        color: Colors.grey.withOpacity(0.50),
        //   color: Colors.red,  // not working this option
      ),

      appBarTheme: const AppBarTheme(
        //   color: Color.fromARGB(43, 30, 30, 30),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        color: Colors.white,

        // textTheme: TextTheme(
        //   headline6: TextStyle(
        //     color: Colors.white,
        //     fontSize: 18.0,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
      ),
      textTheme: const TextTheme(
          // ... (your text styles)
          ),
      colorScheme: const ColorScheme.dark(
        //  primary: Color(0xFF1E1E1E),
        onPrimary: Colors.white,
        //  surface: Color(0xFF121212),
        onSurface: Colors.white,
        //  background: Color(0xFF121212),
        background: Color.fromARGB(255, 7, 21, 32),

        onBackground: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        secondary: Color(0xFF2196F3),
        onSecondary: Colors.white,
      ),
      buttonTheme: const ButtonThemeData(
          // ... (your button theme)
          ),

      // inputDecorationTheme: InputDecorationTheme(
      //     // ... (your input decoration theme)
      //     ),
    );
  }
}
