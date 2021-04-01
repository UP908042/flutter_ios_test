// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:social_hobby_app/shared/logging.dart';
import 'package:social_hobby_app/wrappers/hobby_wrapper.dart';

class Hobby extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore db;

  const Hobby({this.db, this.auth});
  @override
  _HobbyState createState() => _HobbyState();
}

class _HobbyState extends State<Hobby> {
  final log = logger(Hobby);
  String _hobbyID;

  @override
  Widget build(BuildContext context) {
    final streamBuilder = StreamBuilder(
        stream: widget.db.collection('hobby').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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
        });
    return Container(
        color: Colors.blue[200],
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: streamBuilder,
        ));
  }
}
