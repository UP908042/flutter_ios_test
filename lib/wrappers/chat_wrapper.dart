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
import '../services/db.dart';

class ChatWrapper extends StatefulWidget {
  final String id;
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  final bool roomExists;

  const ChatWrapper({this.id, this.db, this.auth, this.roomExists});
  @override
  _ChatWrapperState createState() => _ChatWrapperState();
}

class _ChatWrapperState extends State<ChatWrapper> {
  final log = logger(ChatWrapper);
  static String _username;
  static String chatroomID;
  bool _loading = false;
  TextEditingController messageEditingController = TextEditingController();

  @override
  void initState() {
    final _user = AuthService(auth: widget.auth).userInfo.uid;
    chatroomID = Database(db: widget.db).getChatRoomID(_user, widget.id);
    super.initState();
  }

  void sendMessage(String chatRoomID) {
    if (messageEditingController.text.isNotEmpty) {
      final _uid = AuthService(auth: widget.auth).userInfo.uid.toString();
      final Map<String, dynamic> chatMessageMap = {
        "sendBy": _uid,
        "sendTo": widget.id,
        "content": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      Database(db: widget.db)
          .addMessage(chatRoomID, chatMessageMap, _uid, widget.id);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = widget.db.collection('user').doc(widget.id);
    document.get().then((value) {
      if (mounted) {
        setState(() {
          _username = value['username'].toString() ?? 'Loading...';
        });
      }
    });
    final streamBuilder = StreamBuilder(
      stream: widget.db
          .collection('chats')
          .doc(chatroomID)
          .collection('messages')
          .orderBy('time')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          log.i('No Data In Database');
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final items = snapshot.data.docs;
        return ListView.builder(
            shrinkWrap: true,
            reverse: true,
            padding: const EdgeInsets.all(10.0),
            itemCount: items.length,
            itemBuilder: (context, count) {
              final _index = items.length - 1 - count;
              final _content = items[_index]['content'].toString();
              if (items[_index]['sendBy'] == widget.id) {
                return Align(
                  alignment: Alignment.bottomLeft,
                  child: Card(
                      elevation: 5,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _content,
                          style: const TextStyle(fontSize: 16),
                        ),
                      )),
                );
              } else {
                return Align(
                  alignment: Alignment.bottomRight,
                  child: Card(
                      elevation: 5,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      )),
                      color: Colors.blue[300],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_content,
                            style: const TextStyle(fontSize: 16)),
                      )),
                );
              }
            });
      },
    );

    final appBar = AppBar(
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
      title: Align(
        alignment: Alignment.center,
        child: Text(_username ?? 'Loading Username...',
            style: const TextStyle(color: Colors.black)),
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

    return _loading
        ? Loading()
        : Container(
            color: Colors.blue[200],
            child: Scaffold(
              appBar: appBar,
              backgroundColor: Colors.transparent,
              body: streamBuilder,
              resizeToAvoidBottomInset: true,
              bottomNavigationBar: Container(
                padding: MediaQuery.of(context).viewInsets,
                color: Colors.grey[300],
                child: TextField(
                    controller: messageEditingController,
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      hintText: 'Type a message',
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          sendMessage(chatroomID);
                        },
                      ),
                    )),
              ),
            ));
  }
}
