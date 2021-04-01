// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:social_hobby_app/services/auth.dart';
import 'package:social_hobby_app/shared/logging.dart';
import 'package:social_hobby_app/wrappers/hobby_wrapper.dart';

class Home extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore db;

  const Home({this.db, this.auth});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final log = logger(Home);
  String _hobbyID;

  @override
  Widget build(BuildContext context) {
    final _userID = AuthService(auth: widget.auth).userInfo.uid;
    final streamBuilder = StreamBuilder(
        stream: widget.db
            .collection('hobby')
            .where('userIDs', arrayContains: _userID)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data.docs.isNotEmpty) {
            final items = snapshot.data.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(2.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 6.0,
                  color: Colors.white,
                  child: ListTile(
                    title: Text(items[index]['title'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text(' '),
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(items[index]['imgurl'].toString()),
                      maxRadius: 40.0,
                    ),
                    trailing: const Icon(
                      Icons.keyboard_arrow_right,
                      size: 30,
                      color: Colors.black,
                    ),
                    onTap: () {
                      setState(() => {_hobbyID = items[index].id});
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HobbyWrapper(
                                    id: _hobbyID,
                                    db: widget.db,
                                    auth: widget.auth,
                                  )));
                    },
                  ),
                );
              },
            );
          } else {
            return Scaffold(
              backgroundColor: Colors.blue[200],
              body: Center(
                  // ignore: leading_newlines_in_multiline_strings
                  child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                        // ignore: leading_newlines_in_multiline_strings
                        text: '''No Hobbies :(
Use The Search Icon Below
To Sign Up To Some Hobbies
          ''', style: TextStyle(color: Colors.black)),
                    WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                        child: Icon(Icons.arrow_downward),
                      ),
                    ),
                  ],
                ),
              )),
            );
          }
        });

    return Container(
        color: Colors.blue[200],
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: streamBuilder,
        ));
  }
}
