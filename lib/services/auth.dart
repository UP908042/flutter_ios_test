// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:social_hobby_app/shared/logging.dart';

class AuthService {
  final log = logger(AuthService);
  final FirebaseAuth auth;

  AuthService({this.auth});

  // Auth Change user Stream

  Stream<User> get userState {
    return auth.authStateChanges();
  }

  User get userInfo {
    return auth.currentUser;
  }
  // Sign In

  Future<bool> signIn({String email, String password}) async {
    try {
      log.i('Trying to Sign In...');
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      log.i('Successful: User Signed In');
      return true;
    } on FirebaseAuthException catch (e) {
      log.e('Unsuccessful: ${e.message}');
      return false;
    }
  }

  // Sign Up
  Future<bool> createAccount(
      {String email, String password, FirebaseFirestore db}) async {
    try {
      log.i('Trying to create User...');
      await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      log.i('Successful: Created User');
      return true;
    } on FirebaseAuthException catch (e) {
      log.e('Unsuccessful: ${e.message}');
      return false;
    }
  }

  // Sign Out
  Future<bool> signOut() async {
    try {
      log.i('Trying to Sign User Out...');
      await auth.signOut();
      log.i('Successful: Signed Out');
      return true;
    } catch (e) {
      log.e('Unsuccessful: $e');
      return false;
    }
  }

  // Change Password
  Future<bool> changePassword(String _oldPass, String _newPass) async {
    try {
      final _cred = EmailAuthProvider.credential(
          email: auth.currentUser.email, password: _oldPass);
      log.i('Trying to Change Password');
      await auth.currentUser.reauthenticateWithCredential(_cred);
      await auth.currentUser.updatePassword(_newPass);
      log.i('Successful: Password Updated');
      return true;
    } catch (e) {
      log.e('Unsuccessful: $e');
      return false;
    }
  }
}
