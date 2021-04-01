// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:social_hobby_app/services/auth.dart';
import 'package:social_hobby_app/services/db.dart';

// ignore_for_file: avoid_implementing_value_types
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements User {}

class MockAuthResult extends Mock implements UserCredential {}

class MockFirebaseStore extends Mock implements FirebaseFirestore {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

// ignore: must_be_immutable
class MockCollectionReference extends Mock implements CollectionReference {}

void main() {
  final MockDocumentSnapshot mockDocumentSnapshot = MockDocumentSnapshot();
  final MockFirebaseAuth _firebaseAuth = MockFirebaseAuth();
  final AuthService authService = AuthService(auth: _firebaseAuth);
  final MockFirebaseStore _firebaseStore = MockFirebaseStore();
  final Database dbService = Database(db: _firebaseStore);
  final MockDocumentReference mockDocumentReference = MockDocumentReference();
  final MockCollectionReference mockCollectionReference =
      MockCollectionReference();
  final MockFirebaseUser user = MockFirebaseUser();
  group('Authentication test', () {
    when(
      _firebaseAuth.createUserWithEmailAndPassword(
          email: "test@gmail.com", password: "123456"),
    ).thenAnswer((realInvocation) => null);
    when(
      _firebaseAuth.signInWithEmailAndPassword(
          email: "correct@correct.com", password: "123456"),
    ).thenAnswer((realInvocation) => null);
    when(
      _firebaseAuth.signInWithEmailAndPassword(
          email: "incorrect@test.com", password: "123456"),
    ).thenAnswer((realInvocation) =>
        throw FirebaseAuthException(code: 'auth/invalid-argument'));

    when(
      _firebaseAuth.signInWithEmailAndPassword(
          email: "correct@test.com", password: "incorrect"),
    ).thenAnswer((realInvocation) =>
        throw FirebaseAuthException(code: 'auth/invalid-argument'));

    when(
      _firebaseAuth.signInWithEmailAndPassword(
          email: "incorrect@test.com", password: "incorrect"),
    ).thenAnswer((realInvocation) =>
        throw FirebaseAuthException(code: 'auth/invalid-argument'));

    when(
      _firebaseAuth.createUserWithEmailAndPassword(
          email: "test@test.com", password: "123456"),
    ).thenAnswer((realInvocation) =>
        throw FirebaseAuthException(code: 'auth/email-already-exists'));

    when(_firebaseAuth.currentUser).thenAnswer((realInvocation) => user);

    when(
      _firebaseAuth.signOut(),
    ).thenAnswer((realInvocation) => null);

    test('Get Current User Data', () async {
      final result = authService.userInfo;
      final matcher = user;
      expect(result, matcher);
    });

    test('Get User State', () async {
      final Stream result = authService.userState;
      final Stream matcher = _firebaseAuth.authStateChanges();
      expect(result, matcher);
    });

    test("Sign In: Correct Email & Password", () async {
      final result = await authService.signIn(
          email: "correct@correct.com", password: "123456");
      const bool matcher = true;
      expect(result, matcher);
    });

    test("Sign In: Incorrect Email", () async {
      final result = await authService.signIn(
          email: "incorrect@test.com", password: "123456");
      const bool matcher = false;
      expect(result, matcher);
    });
    test("Sign In: Incorrect Password", () async {
      final result = await authService.signIn(
          email: "correct@test.com", password: "incorrect");
      const bool matcher = false;
      expect(result, matcher);
    });
    test("Sign In: Incorrect Email & Password", () async {
      final result = await authService.signIn(
          email: "incorrect@test.com", password: "incorrect");
      const bool matcher = false;
      expect(result, matcher);
    });

    test("Create Account: Correct Credentials", () async {
      final result = await authService.createAccount(
          email: "test@gmail.com", password: "123456");

      const bool matcher = true;
      expect(result, matcher);
    });

    test("Create Account: Existing Email", () async {
      final result = await authService.createAccount(
          email: "test@test.com", password: "123456");
      const bool matcher = false;
      expect(result, matcher);
    });

    test('Change Password', () async {
      final result = await authService.changePassword('123456', 'newPass');
      const bool matcher = true;
      expect(result, matcher);
    });
    test('Sign Out', () async {
      final result = await authService.signOut();
      const bool matcher = true;
      expect(result, matcher);
    });
  });
  group('Database Method Checks', () {
    when(_firebaseStore.collection(any)).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    when(mockDocumentReference.collection(any))
        .thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc('InvalidDocument'))
        .thenAnswer((realInvocation) => null);
    when(mockDocumentReference.get())
        .thenAnswer((_) async => mockDocumentSnapshot);
    when(mockDocumentSnapshot.get(any))
        .thenAnswer((realInvocation) => 'testUsername');

    const testUID = 'tkxPWHVIRUYscSpNWrYZ7Tk6wqG3';
    const testOID = 'hHiZyDym1nXLVOAgIsifEBV2Uth2';
    const testDID = 'VymuVAMrGSlMbjSeEGea';
    const testDoc = 'vxvqvScEI5RTbyAwmXg3XpgTAC73';
    const testUsername = 'testUsername';
    const testChatroomID = '4M5bms4TBJU4fFMso1W8Yjuqbg43_cZ8zXV8yRBxVHNLtjQaz';
    const testDIDInvalid = 'InvalidDocument';
    const testChatID =
        'JTIw85ekJuMAZDMhLJPcZ0n6GLX2_UIehfnVoTWYpfdIHBQgiG1CcTcf1';
    final Map<String, dynamic> chatMessageMap = {
      "sendBy": testUID,
      "sendTo": 'otherUID',
      "content": 'Test MSG',
      'time': DateTime.now().millisecondsSinceEpoch,
    };
    test('Add User', () {
      final result = dbService.addUser(testUID, testUsername);
      const bool matcher = true;
      expect(result, matcher);
    });

    test('Get Collection Ref', () {
      final result = dbService.getCollection('user');
      final matcher = _firebaseStore.collection('user');
      expect(result, matcher);
    });

    test('Get Document Ref', () {
      final result = dbService.getDocument('user', testDoc);
      final matcher = _firebaseStore.collection('user').doc(testDoc);
      expect(result, matcher);
    });

    test('Hobby Sign Up', () async {
      final result = await dbService.hobbySignUp(testDID, testUID);
      const bool matcher = true;
      expect(result, matcher);
    });

    test('Hobby Sign Up: Invalid Document Reference', () async {
      final result = await dbService.hobbySignUp(testDIDInvalid, testUID);
      const bool matcher = false;
      expect(result, matcher);
    });

    test('Hobby Sign Up: Invalid Document Reference', () async {
      final result = await dbService.hobbySignUp(testDIDInvalid, testUID);
      const bool macther = false;
      expect(result, macther);
    });

    test('Hobby Unlist', () async {
      final result = await dbService.hobbyUnlist(testDID, testUID);
      const bool matcher = true;
      expect(result, matcher);
    });

    test('Hobby Unlist: Invalid Document Reference', () async {
      final result = await dbService.hobbyUnlist(testDIDInvalid, testUID);
      const bool matcher = false;
      expect(result, matcher);
    });

    test('Delete User', () async {
      final result = await dbService.deleteUser(testUID);
      const bool matcher = true;
      expect(result, matcher);
    });

    test('Delete User: Invalid Document Reference', () async {
      final result = await dbService.deleteUser(testDIDInvalid);
      const bool matcher = false;
      expect(result, matcher);
    });

    test('Delete Chats', () async {
      final result = await dbService.deleteChats(testChatID);
      const bool matcher = true;
      expect(result, matcher);
    });

    test('Update Username', () async {
      final result = await dbService.updateUsername(testUID, 'test');
      const bool matcher = true;
      expect(result, matcher);
    });

    test('Update Username: Invalid Document Reference', () async {
      final result = await dbService.updateUsername(testDIDInvalid, 'test');
      const bool matcher = false;
      expect(result, matcher);
    });

    test('Add Message to Database', () async {
      final result = await dbService.addMessage(
          testChatroomID, chatMessageMap, testUID, testOID);
      const bool matcher = true;
      expect(result, matcher);
    });

    test('Get Chatroom ID', () {
      final result = dbService.getChatRoomID('test1', 'test2');
      const String matcher = 'test1_test2';
      expect(result, matcher);
    });
    test('Get Chatroom ID', () {
      final result = dbService.getChatRoomID('ztest1', 'test2');
      const String matcher = 'test2_ztest1';
      expect(result, matcher);
    });

    test('Get Username', () async {
      final result = await dbService.getUsername(testUID);
      final String matcher = 'testUsername';
      expect(result, matcher);
    });
  });
}
