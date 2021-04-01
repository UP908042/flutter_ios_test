import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:social_hobby_app/screens/authenticate/change_password.dart';
import 'package:social_hobby_app/screens/authenticate/change_username.dart';
import 'package:social_hobby_app/services/auth.dart';
import 'package:social_hobby_app/services/db.dart';
import 'package:social_hobby_app/shared/dialog.dart';
import 'package:social_hobby_app/shared/logging.dart';

class Account extends StatefulWidget {
  final FirebaseFirestore db;
  final FirebaseAuth auth;

  const Account({this.db, this.auth});
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final log = logger(Account);
  static String _username;
  static String _email;

  @override
  void initState() {
    _setUserData();
    super.initState();
  }

  // ignore: avoid_void_async
  void _setUserData() async {
    final User _user = AuthService(auth: widget.auth).userInfo;
    final _query = widget.db.collection('user').doc(_user.uid).get();

    try {
      await _query.then((value) => {
            setState(() {
              _username = value.data()['username'].toString();
            })
          });
      setState(() {
        _email = _user.email;
      });
    } catch (e) {
      log.e('Failed to Retrieve Username from DB');
    }
  }

  Future _delUser() async {
    final User _user = AuthService(auth: widget.auth).userInfo;
    try {
      Database(db: widget.db).deleteUser(_user.uid);
      final _delHobbies = widget.db
          .collection('hobby')
          .where('userIDs', arrayContains: _user.uid)
          .get();
      _delHobbies.then((value) => {
            for (final _hobby in value.docs)
              {Database(db: widget.db).hobbyUnlist(_hobby.id, _user.uid)}
          });
      final _delChats = widget.db
          .collection('chats')
          .where("user_ids", arrayContains: _user.uid)
          .get();
      _delChats.then((value) => {
            for (final chat in value.docs)
              {Database(db: widget.db).deleteChats(chat.id)}
          });

      await _user.delete();
      await AuthService(auth: widget.auth).signOut();
    } catch (e) {
      log.e('$e');
    }
  }

  // ignore: always_declare_return_types
  _showDialog(BuildContext context) {
    // ignore: prefer_function_declarations_over_variables
    final VoidCallback continueCallBack = () async {
      Navigator.of(context).pop();
      _delUser();
    };
    final BlurryDialog alert = BlurryDialog("Delete Account",
        "Are you sure you want to DELETE your Account?", continueCallBack);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'My Profile',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontSize: 56,
                            color: Colors.blue,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          _username ?? 'Loading Username...',
                          style: const TextStyle(
                            fontFamily: 'Avenir',
                            fontSize: 31,
                            color: Colors.blue,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const Divider(color: Colors.black38),
                        const SizedBox(height: 32),
                        Text(
                          _email ?? 'Loading Email...',
                          maxLines: 15,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Avenir',
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Divider(color: Colors.black38),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                          onPressed: () {
                            _showDialog(context);
                          },
                          child: const Text('Delete Account'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PasswordChanger(
                                          auth: widget.auth,
                                        )));
                          },
                          child: const Text('Change Password'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute<String>(
                                    builder: (context) => UsernameChanger(
                                          auth: widget.auth,
                                          db: widget.db,
                                        ))).then((value) => {
                                  setState(() {
                                    _username = value;
                                  })
                                });
                          },
                          child: const Text('Change Username'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
