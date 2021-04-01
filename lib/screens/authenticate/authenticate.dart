// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:social_hobby_app/screens/authenticate/register.dart';
import 'package:social_hobby_app/screens/authenticate/sign_in.dart';
import 'package:social_hobby_app/shared/logging.dart';

class Authenticate extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  const Authenticate({this.auth, this.db});

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  final log = logger(Authenticate);
  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      log.i('Displaying Sign In Page');
      return SignIn(auth: widget.auth, toggleView: toggleView);
    } else {
      log.i('Displaying Register Page');
      return Register(auth: widget.auth, toggleView: toggleView, db: widget.db);
    }
  }
}
