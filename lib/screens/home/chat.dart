import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:social_hobby_app/services/auth.dart';
import 'package:social_hobby_app/shared/logging.dart';
import 'package:social_hobby_app/wrappers/chat_wrapper.dart';

class Chat extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore db;

  const Chat({this.db, this.auth});
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final log = logger(Chat);
  static String _userID;
  // ignore: missing_return
  String getID(dynamic _uids, String _cid) {
    for (final _uid in _uids) {
      if (_uid != _cid) {
        return _uid.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _uid = AuthService(auth: widget.auth).userInfo.uid.toString();

    return Scaffold(
        backgroundColor: Colors.blue[200],
        body: StreamBuilder(
          stream: widget.db
              .collection('chats')
              .where("user_ids", arrayContains: _uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> chats) {
            return StreamBuilder(
                stream: widget.db
                    .collection('user')
                    .where('user_id',
                        isNotEqualTo:
                            AuthService(auth: widget.auth).userInfo.uid)
                    .snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> users) {
                  if (!chats.hasData || !users.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final chatItems = chats.data.docs;
                  final userItems = users.data.docs;

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: chatItems.length,
                            itemBuilder: (context, index) {
                              String username;
                              if (_uid != chatItems[index]['user_ids'][0]) {
                                username =
                                    chatItems[index]['username'][0].toString();
                              } else {
                                username =
                                    chatItems[index]['username'][1].toString();
                              }

                              return Card(
                                  color: Colors.white,
                                  child: ListTile(
                                    tileColor: Colors.green[300],
                                    title: Text(username),
                                    trailing: const Icon(
                                      Icons.keyboard_arrow_right,
                                      size: 30,
                                      color: Colors.black,
                                    ),
                                    onTap: () {
                                      setState(() => _userID = getID(
                                          chatItems[index]['user_ids'], _uid));
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatWrapper(
                                                    id: _userID,
                                                    db: widget.db,
                                                    auth: widget.auth,
                                                  )));
                                    },
                                  ));
                            }),
                      ),
                      const Divider(color: Colors.black38),
                      Container(
                        child: const Text(
                          'Connect to Other Users',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      const Divider(color: Colors.black38),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: userItems.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 2,
                                ),
                                width: 80,
                                child: GestureDetector(
                                    onTap: () {
                                      setState(() => _userID =
                                          userItems[index]['user_id']);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatWrapper(
                                                    id: _userID,
                                                    db: widget.db,
                                                    auth: widget.auth,
                                                  )));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                          Center(
                                              child: Text(userItems[index]
                                                      ['username']
                                                  .toString())),
                                        ],
                                      ),
                                    )),
                              );
                            }),
                      )
                    ],
                  );
                });
          },
        ));
  }
}
