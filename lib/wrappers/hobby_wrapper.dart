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

class HobbyWrapper extends StatefulWidget {
  final String id;
  final FirebaseFirestore db;
  final FirebaseAuth auth;

  const HobbyWrapper({this.id, this.db, this.auth});
  @override
  _HobbyWrapperState createState() => _HobbyWrapperState();
}

class _HobbyWrapperState extends State<HobbyWrapper> {
  final log = logger(HobbyWrapper);
  static String _title;
  static String _description;
  static String _img;
  bool _loading = false;
  bool _isSignedUp = false;

  @override
  void initState() {
    isUserSignedUp();
    super.initState();
  }

  // ignore: avoid_void_async
  void isUserSignedUp() async {
    try {
      log.d('Trying To Retrieving Hobbies');
      await widget.db
          .collection('hobby')
          .where('userIDs',
              arrayContains: AuthService(auth: widget.auth).userInfo.uid)
          .get()
          .then((value) {
        for (final hob in value.docs) {
          if (_isSignedUp == false && hob.id == widget.id) {
            setState(() {
              _isSignedUp = true;
            });
          }
        }
      });
      log.d('Successful: Hobbies Acquired');
    } catch (e) {
      log.e('Unsuccessful: $e');
      setState(() {
        _isSignedUp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference collection =
        Database(db: widget.db).getCollection('hobby');
    final DocumentReference document = collection.doc(widget.id);
    document.get().then((value) {
      if (mounted) {
        setState(() {
          _title = value['title'].toString();
          _description = value['description'].toString();
          _img = value['imgurl'].toString();
        });
      }
    });

    final topAppBar = AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 40.0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: Colors.black,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      elevation: 0.0,
      actions: <Widget>[
        TextButton.icon(
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
            label: const Text('Logout', style: TextStyle(color: Colors.black)),
            onPressed: () async {
              setState(() => _loading = true);
              final result = await AuthService(auth: widget.auth).signOut();
              Navigator.pop(context);

              if (result == false) {
                _loading = false;
              }
            })
      ],
    );

    final bottomAppBar = Container(
      alignment: Alignment.bottomCenter,
      height: 55,
      color: Colors.white,
      child: InkWell(
        onTap: () => {log.i('Loading Forums')},
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            children: const <Widget>[
              Icon(
                Icons.forum,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );

    Widget _signedUpScreen() {
      return Scaffold(
        backgroundColor: Colors.blue[200],
        appBar: topAppBar,
        bottomNavigationBar: bottomAppBar,
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
                          Text(
                            _title ?? 'Loading Title',
                            style: const TextStyle(
                              fontFamily: 'Avenir',
                              fontSize: 56,
                              color: Colors.blue,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const Text(
                            'My Hobby',
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontSize: 31,
                              color: Colors.blue,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const Divider(color: Colors.black38),
                          const SizedBox(height: 32),
                          Card(
                            elevation: 6,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.network(
                              _img,
                              fit: BoxFit.contain,
                              width: 150,
                              height: 150,
                            ),
                          ),
                          const Divider(color: Colors.black38),
                          const SizedBox(height: 32),
                          Text(
                            _description ?? 'Loading Description...',
                            maxLines: _description.length,
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
                              onPressed: () {
                                setState(() {
                                  _isSignedUp = false;
                                });
                                Database(db: widget.db).hobbyUnlist(
                                    widget.id,
                                    AuthService(auth: widget.auth)
                                        .userInfo
                                        .uid);
                              },
                              child: const Text(
                                'Unlist',
                                style: TextStyle(),
                              )),
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

    Widget _registerScreen() {
      return Scaffold(
        backgroundColor: Colors.blue[200],
        appBar: topAppBar,
        bottomNavigationBar: Container(
          alignment: Alignment.bottomLeft,
          height: 55,
          color: Colors.white,
        ),
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
                          Text(
                            _title ?? 'Loading...',
                            style: const TextStyle(
                              fontFamily: 'Avenir',
                              fontSize: 56,
                              color: Colors.blue,
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontSize: 31,
                              color: Colors.blue,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          const Divider(color: Colors.black38),
                          const SizedBox(height: 32),
                          Card(
                            elevation: 6,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.network(
                              _img ?? 'Loading Hobby Image...',
                              fit: BoxFit.contain,
                              width: 150,
                              height: 150,
                            ),
                          ),
                          const Divider(color: Colors.black38),
                          const SizedBox(height: 32),
                          Text(
                            _description,
                            maxLines: _description.length ?? 50,
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
                              onPressed: () {
                                setState(() {
                                  _isSignedUp = true;
                                  Database(db: widget.db).hobbySignUp(
                                      widget.id,
                                      AuthService(auth: widget.auth)
                                          .userInfo
                                          .uid);
                                });
                              },
                              child: const Text(
                                'Enlist',
                                style: TextStyle(),
                              ))
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

    return _loading
        ? Loading()
        : (_isSignedUp ? _signedUpScreen() : _registerScreen());
  }
}
