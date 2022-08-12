import 'dart:ui';

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import 'package:fluttertoast/fluttertoast.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    Key key,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _pass = TextEditingController();
  var _email = "";
  var _password = "";
  bool _isLoginPage = true;
  bool _showPassword = false;
  /* the only purpose of this is to make sure that pressing next on the password 
  field focuses on the reenter password field instead of the password visibility option */
  FocusNode reenterFocus = new FocusNode();

  String _errorMessage = 'default error message';

  startAuth() async {
    final validity = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (validity) {
      _formKey.currentState.save();
      submitForm(_email, _password);
    }
  }

  submitForm(String email, String password) async {
    final auth = FirebaseAuth.instance;
    UserCredential userCredential;
    try {
      if (_isLoginPage) {
        userCredential = await auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        // for auth
        userCredential = await auth.createUserWithEmailAndPassword(
            email: email, password: password);

        // for Firestore
        String uid = userCredential.user.uid;
        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          "email": email,
          "password": password,
        });
      }
    } on FirebaseAuthException catch (err) {
      switch (err.code) {
        case 'email-already-in-use':
          _errorMessage = 'E-mail already in use';
          break;
        case 'user-not-found':
          _errorMessage = 'User not found';
          break;
        case 'invalid-email':
          _errorMessage = 'Invalid email address';
          break;
        case 'wrong-password':
          _errorMessage = 'Password does not match the e-mail';
          break;
        case 'weak-password':
          _errorMessage = 'Password is too weak';
          break;
        case 'unknown':
          _errorMessage = 'Please enter your credentials';
          break;
      }

      showErrorToast(context, _errorMessage);
    }
  }

  Widget errorToast(String msg) => Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).primaryColorLight,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.close,
              size: 20,
            ),
            SizedBox(
              width: 10,
            ),
            Text(msg),
          ],
        ),
      );
  void showErrorToast(BuildContext context, String msg) {
    FToast().init(context);
    FToast().showToast(child: errorToast(msg), gravity: ToastGravity.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.white.withOpacity(0.85),
                    elevation: 5,
                    shadowColor: Theme.of(context).primaryColor,
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      key: const ValueKey("email"),
                      validator: (val) {
                        return null;
                      },
                      onSaved: (val) {
                        _email = val;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(15),
                        border: InputBorder.none,
                        hintText: "Enter e-Mail",
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.white.withOpacity(0.85),
                    elevation: 5,
                    shadowColor: Theme.of(context).primaryColor,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            obscureText: !_showPassword,
                            autocorrect: false,
                            textInputAction: _isLoginPage
                                ? TextInputAction.done
                                : TextInputAction.next,
                            keyboardType: TextInputType.visiblePassword,
                            onFieldSubmitted: _isLoginPage
                                ? (_) {
                                    startAuth();
                                  }
                                : (_) => reenterFocus
                                    .requestFocus(), // to prevent focusing on the password visibility button
                            key: const ValueKey("password"),
                            controller: _pass,
                            validator: (val) {
                              return null;
                            },
                            onSaved: (val) {
                              _password = val;
                            },
                            decoration: InputDecoration(
                              errorStyle: TextStyle(height: 0),
                              contentPadding: EdgeInsets.all(15),
                              border: InputBorder.none,
                              hintText: "Enter Password",
                            ),
                          ),
                        ),
                        IconButton(
                            splashRadius: 20,
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            icon: Icon(_showPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: _showPassword
                                ? Theme.of(context).primaryColor
                                : Colors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (!_isLoginPage)
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.white.withOpacity(0.85),
                      elevation: 5,
                      shadowColor: Theme.of(context).primaryColor,
                      child: TextFormField(
                        focusNode: reenterFocus,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        onFieldSubmitted: (_) {
                          startAuth();
                        },
                        key: const ValueKey("rePassword"),
                        validator: (val) {
                          if (val != _pass.text) {
                            showErrorToast(context, 'Passwords do not match');
                            return "";
                          } else
                            return null;
                        },
                        onSaved: (val) {
                          _password = val;
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(height: 0),
                          contentPadding: EdgeInsets.all(15),
                          border: InputBorder.none,
                          hintText: "Reenter Password",
                        ),
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.all(6),
                    height: 35,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 0,
                            color: Theme.of(context).primaryColor,
                            offset: Offset(0, 2),
                          )
                        ]),
                    width: MediaQuery.of(context).size.width - 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 2,
                          sigmaY: 2,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            primary: Colors.white.withOpacity(0.8),
                            onPrimary: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            startAuth();
                          },
                          child: _isLoginPage
                              ? const Text("Log in")
                              : const Text("Sign up"),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_isLoginPage
                          ? 'Not a member?'
                          : 'Already have an account?'),
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            _isLoginPage = !_isLoginPage;
                          });
                        },
                        child: _isLoginPage
                            ? const Text("Sign up")
                            : const Text("Sign in"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
