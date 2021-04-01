// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:social_hobby_app/screens/authenticate/authenticate.dart';
import 'package:social_hobby_app/screens/home/dashboad.dart';
import 'package:social_hobby_app/shared/logging.dart';

class Wrapper extends StatelessWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  const Wrapper({Key key, this.auth, this.db}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final log = logger(Wrapper);
    final user = Provider.of<User>(context);
    //Return either home or authenticate wiget
    if (user == null) {
      log.i('User Requires Authentication');
      return Authenticate(auth: auth, db: db);
    } else {
      log.i('Re-Signing in user');
      return Dashboard(auth: auth, db: db);
    }
  }
}
