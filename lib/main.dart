import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo_firebase/auth/auth_screen.dart';
import 'package:todo_firebase/screens/home.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String themeColor = prefs.getString('themeColor');
  await Firebase.initializeApp();
  runApp(MyApp(themeColor));
}

class MyApp extends StatefulWidget {
  final String themeColor;
  MyApp(this.themeColor, {Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MaterialColor mainColor;

  @override
  void initState() {
    mainColor = strToColor(widget.themeColor);
    if (mainColor == null) {
      mainColor = Colors.indigo;
    }
    super.initState();
  }

  MaterialColor strToColor(String colorString) {
    MaterialColor materialColor;

    switch (colorString) {
      case 'Yellow':
        materialColor = Colors.yellow;
        break;
      case 'Orange':
        materialColor = Colors.orange;
        break;
      case 'Red':
        materialColor = Colors.red;
        break;
      case 'Pink':
        materialColor = Colors.pink;
        break;
      case 'Purple':
        materialColor = Colors.deepPurple;
        break;
      case 'Indigo':
        materialColor = Colors.indigo;
        break;
      case 'Blue':
        materialColor = Colors.blue;
        break;
      case 'Cyan':
        materialColor = Colors.cyan;
        break;
      case 'Green':
        materialColor = Colors.green;
        break;
      case 'Grey':
        materialColor = Colors.grey;
        break;
    }
    return materialColor;
  }

  void changeThemeColor(String newColorString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        prefs.setString('themeColor', newColorString);
        mainColor = strToColor(prefs.getString('themeColor'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        primarySwatch: mainColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: mainColor,
          secondary: mainColor.shade200,
        ),
        textTheme: GoogleFonts.nunitoSansTextTheme(
          Theme.of(context).textTheme,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: mainColor.shade700,
          ),
        ),
        iconTheme: IconThemeData(color: mainColor.shade700),
        appBarTheme: const AppBarTheme(),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Home(changeThemeColor);
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
