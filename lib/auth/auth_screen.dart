import 'package:flutter/material.dart';
import 'package:todo_firebase/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key key}) : super(key: key);
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      elevation: 0,
      title: Text(
        'Sign in / Register',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Theme.of(context).primaryColor,
                Theme.of(context).scaffoldBackgroundColor,
              ]),
        ),
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: const AuthForm(),
    );
  }
}
