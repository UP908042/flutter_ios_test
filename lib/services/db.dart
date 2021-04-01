import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'package:social_hobby_app/shared/logging.dart';

class Database {
  final log = logger(Database);
  final FirebaseFirestore db;

  Database({this.db});

  bool addUser(String uid, String username) {
    final userAdd = db.collection('user').doc(uid);
    try {
      log.i('Trying to Add user to database');
      userAdd.set({
        'user_id': uid,
        'username': username,
      });
      log.i("Successful: Added User");
      return true;
    } catch (error) {
      log.e('Unsuccessfull: $error');
      return false;
    }
  }

  CollectionReference getCollection(String colllectionName) {
    final CollectionReference col = db.collection(colllectionName);
    return col;
  }

  DocumentReference getDocument(String col, String docRef) {
    final DocumentReference doc = db.collection(col).doc(docRef);
    return doc;
  }

  Future<bool> hobbySignUp(String id, String uid) async {
    try {
      log.i('Signer User Up to Hobby...');
      await db.collection('hobby').doc(id).update({
        "userIDs": FieldValue.arrayUnion([uid])
      });
      log.i('Successful: Signed User Up...');
      return true;
    } catch (e) {
      log.e('Unsuccessful: $e');
      return false;
    }
  }

  Future<bool> hobbyUnlist(String id, String uid) async {
    try {
      log.i('Unlisting User From Hobby...');
      await db.collection('hobby').doc(id).update({
        "userIDs": FieldValue.arrayRemove([uid])
      });
      log.i('Successful: Unlisted');
      return true;
    } catch (e) {
      log.i('Unsuccessful: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String _uid) async {
    try {
      log.i('Trying to delete user...');
      await db.collection('user').doc(_uid).delete();
      log.i('Successful: Removed User');
      return true;
    } catch (e) {
      log.e('Error: $e');
      return false;
    }
  }

  Future<bool> deleteChats(String _chatID) async {
    try {
      log.i('Trying to delete Users Chats...');
      await db.collection('chats').doc(_chatID).delete();
      log.i('Successful: Removed All Chats');
      return true;
    } catch (e) {
      log.e('Error: $e');
      return false;
    }
  }

  Future<bool> updateUsername(String _uid, String _username) async {
    try {
      log.i('Trying to update username...');
      await db.collection('user').doc(_uid).update({"username": _username});
      log.i('Succesful: Username Updated');
      return true;
    } catch (e) {
      log.e('Unsuccessful: $e');
      return false;
    }
  }

  Future<bool> addMessage(String chatRoomId,
      Map<String, dynamic> chatMessageData, String uid, String oid) async {
    try {
      log.i('Trying to Send Message');
      final _currentUsername = await db
          .collection('user')
          .doc(uid)
          .get()
          .then((value) => value['username'].toString());
      final _otherUsername = await db
          .collection('user')
          .doc(oid)
          .get()
          .then((value) => value['username'].toString());

      await db.collection('chats').doc(chatRoomId).set({
        "user_ids": [uid, oid],
        "username": [_currentUsername, _otherUsername]
      });
      await db
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(chatMessageData);
      log.i('Successful: Sent Message');
      return true;
    } catch (e) {
      log.e('Unsuccessful: $e');
      return false;
    }
  }

  Future<String> getUsername(String uid) async {
    try {
      final data = await db.collection('user').doc(uid).get();
      log.i(data.get('username'));
      return data.get('username').toString();
    } catch (e) {
      return null;
    }
  }

  String getChatRoomID(String a, String b) {
    log.i('Generating Chatroom ID');
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      // ignore_for_file: unnecessary_string_escapes
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }
}
