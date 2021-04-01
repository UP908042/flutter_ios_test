// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:social_hobby_app/services/auth.dart';
import 'package:social_hobby_app/services/db.dart';
import 'package:social_hobby_app/shared/loading.dart';
import 'package:social_hobby_app/shared/logging.dart';

class UsernameChanger extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore db;

  const UsernameChanger({this.auth, this.db});
  @override
  _UsernameChangerState createState() => _UsernameChangerState();
}

class _UsernameChangerState extends State<UsernameChanger> {
  final log = logger(UsernameChanger);
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  String error = '';

  String success = '';

  String _newUsername = '';

  static String _curUsername;

  @override
  Widget build(BuildContext context) {
    widget.db
        .collection('user')
        .doc(AuthService(auth: widget.auth).userInfo.uid)
        .get()
        .then((value) => {_curUsername = value.get('username').toString()});
    final topAppBar = AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 40.0,
      backgroundColor: Colors.white,
      leading: IconButton(
        key: Key('back'),
        icon: const Icon(Icons.arrow_back_ios),
        color: Colors.black,
        onPressed: () {
          Navigator.pop(context, _curUsername);
        },
      ),
    );
    final bottomAppBar = Container(
      alignment: Alignment.bottomLeft,
      height: 55,
      color: Colors.white,
    );

    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.blue[200],
            appBar: topAppBar,
            bottomNavigationBar: bottomAppBar,
            body: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 50.0),
                child: Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    const SizedBox(height: 20.0),
                    TextFormField(
                      key: const Key('newUsername'),
                      decoration: const InputDecoration(
                        hintText: 'Enter a Username',
                      ),
                      autocorrect: false,
                      validator: (val) {
                        if (val.length > 10) {
                          return 'Enter a Username less than 10 chars';
                        } else if (val.isEmpty) {
                          return 'Enter a New Username';
                        } else if (val.length < 4) {
                          return 'Enter a Username greater than 4 chars';
                        } else {
                          return null;
                        }
                      },
                      onChanged: (val) {
                        setState(() => _newUsername = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      key: const Key('changeUsername'),
                      onPressed: () async {
                        // Validate Form
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _loading = true;
                          });

                          final _userID =
                              AuthService(auth: widget.auth).userInfo.uid;

                          final dynamic result = await Database(db: widget.db)
                              .updateUsername(_userID, _newUsername);

                          if (result == false) {
                            setState(() {
                              error =
                                  'Your Current Username, You Entered, Was Invalid';
                            });
                          } else {
                            success =
                                'Your Username Has Been Successfully Updated';
                          }

                          setState(() {
                            _loading = false;
                          });
                        }
                      },
                      child: const Text('Change Username',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      success,
                      style:
                          const TextStyle(color: Colors.green, fontSize: 14.0),
                    )
                  ]),
                )),
          );
  }
}
