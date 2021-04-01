import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:social_hobby_app/screens/authenticate/change_password.dart';
import 'package:social_hobby_app/screens/authenticate/change_username.dart';
import 'package:social_hobby_app/screens/authenticate/register.dart';
import 'package:social_hobby_app/screens/authenticate/sign_in.dart';
import 'package:social_hobby_app/services/auth.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseStore extends Mock implements FirebaseFirestore {}

class FirebaseUser extends Mock implements User {}

class MockStore extends Mock implements FirebaseFirestore {}

class MockDocumentReference extends Mock implements DocumentReference {}

// ignore: must_be_immutable
class MockCollectionReference extends Mock implements CollectionReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  group('Test Auth Screens', () {
    final MockFirebaseAuth _firebaseAuth = MockFirebaseAuth();
    final MockFirebaseStore _store = MockFirebaseStore();
    final AuthService _authService = AuthService(auth: _firebaseAuth);
    final FirebaseUser user = FirebaseUser();
    final MockDocumentReference mockDocumentReference = MockDocumentReference();
    final MockCollectionReference mockCollectionReference =
        MockCollectionReference();
    final MockDocumentSnapshot mockDocumentSnapshot = MockDocumentSnapshot();

    when(mockDocumentReference.get())
        .thenAnswer((_) async => mockDocumentSnapshot);
    when(_firebaseAuth.currentUser).thenAnswer((realInvocation) => user);
    when(_store.collection(any)).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    when(mockDocumentReference.collection(any))
        .thenReturn(mockCollectionReference);

    testWidgets('Sign In: Correct Data', (WidgetTester tester) async {
      // find widgets
      final email = find.byKey(ValueKey('signInEmail'));
      final pass = find.byKey(ValueKey('signInPass'));
      final signIn = find.byKey(ValueKey('signInBtn'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: SignIn(
        auth: _firebaseAuth,
        toggleView: () {},
      )));
      await tester.enterText(email, 'test@test.com');
      await tester.enterText(pass, 'password');
      await tester.tap(signIn);
      await tester.pump();

      expect(email, findsNothing);
      expect(pass, findsNothing);
      expect(signIn, findsNothing);
      verify(_authService.signIn(email: 'test@test.com', password: 'password'))
          .called(1);
    });
    testWidgets('Sign In: No Email', (WidgetTester tester) async {
      // find widgets
      final email = find.byKey(ValueKey('signInEmail'));
      final pass = find.byKey(ValueKey('signInPass'));
      final signIn = find.byKey(ValueKey('signInBtn'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: SignIn(
        auth: _firebaseAuth,
        toggleView: () {},
      )));
      await tester.enterText(email, '');
      await tester.enterText(pass, 'pass');
      await tester.tap(signIn);
      await tester.pump();

      expect(find.text('Enter an email'), findsOneWidget);
      expect(email, findsOneWidget);
      expect(pass, findsOneWidget);
      expect(signIn, findsOneWidget);
    });
    testWidgets('Sign In: No Password', (WidgetTester tester) async {
      // find widgets
      final email = find.byKey(ValueKey('signInEmail'));
      final pass = find.byKey(ValueKey('signInPass'));
      final signIn = find.byKey(ValueKey('signInBtn'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: SignIn(
        auth: _firebaseAuth,
        toggleView: () {},
      )));
      await tester.enterText(email, 'email@email.com');
      await tester.enterText(pass, '');
      await tester.tap(signIn);
      await tester.pump();

      expect(find.text('Enter a password 6+ Characters Long'), findsOneWidget);
      expect(email, findsOneWidget);
      expect(pass, findsOneWidget);
      expect(signIn, findsOneWidget);
    });

    testWidgets('Sign In: No Password No Email', (WidgetTester tester) async {
      // find widgets
      final email = find.byKey(ValueKey('signInEmail'));
      final pass = find.byKey(ValueKey('signInPass'));
      final signIn = find.byKey(ValueKey('signInBtn'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: SignIn(
        auth: _firebaseAuth,
        toggleView: () {},
      )));
      await tester.enterText(email, '');
      await tester.enterText(pass, '');
      await tester.tap(signIn);
      await tester.pump();

      expect(find.text('Enter a password 6+ Characters Long'), findsOneWidget);
      expect(find.text('Enter an email'), findsOneWidget);
      expect(email, findsOneWidget);
      expect(pass, findsOneWidget);
      expect(signIn, findsOneWidget);
    });

    testWidgets('Register: Correct Data', (WidgetTester tester) async {
      // find widgets
      final username = find.byKey(ValueKey('regUsername'));
      final email = find.byKey(ValueKey('regEmail'));
      final pass = find.byKey(ValueKey('regPass'));
      final reg = find.byKey(ValueKey('regBtn'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: Register(
        auth: _firebaseAuth,
        db: _store,
        toggleView: () {},
      )));
      await tester.enterText(username, 'test');
      await tester.enterText(email, 'test@test.com');
      await tester.enterText(pass, 'password');
      await tester.tap(reg);
      await tester.pump();

      expect(email, findsNothing);
      expect(pass, findsNothing);
      expect(reg, findsNothing);
      verify(_authService.createAccount(
              email: 'test@test.com', password: 'password'))
          .called(1);
    });

    testWidgets('Register: No Data', (WidgetTester tester) async {
      // find widgets
      final username = find.byKey(ValueKey('regUsername'));
      final email = find.byKey(ValueKey('regEmail'));
      final pass = find.byKey(ValueKey('regPass'));
      final reg = find.byKey(ValueKey('regBtn'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: Register(
        auth: _firebaseAuth,
        db: _store,
        toggleView: () {},
      )));
      await tester.enterText(username, '');
      await tester.enterText(email, '');
      await tester.enterText(pass, '');
      await tester.tap(reg);
      await tester.pump();

      expect(
          find.text('Enter a Username greater than 4 chars'), findsOneWidget);
      expect(find.text('Enter a password 6+ characters long'), findsOneWidget);
      expect(find.text('Do No Leave Email Empty'), findsOneWidget);
      expect(username, findsOneWidget);
      expect(email, findsOneWidget);
      expect(pass, findsOneWidget);
      expect(reg, findsOneWidget);
    });
    testWidgets('Register: No Email', (WidgetTester tester) async {
      // find widgets
      final username = find.byKey(ValueKey('regUsername'));
      final email = find.byKey(ValueKey('regEmail'));
      final pass = find.byKey(ValueKey('regPass'));
      final reg = find.byKey(ValueKey('regBtn'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: Register(
        auth: _firebaseAuth,
        db: _store,
        toggleView: () {},
      )));
      await tester.enterText(username, 'testUsername');
      await tester.enterText(email, '');
      await tester.enterText(pass, 'testPass');
      await tester.tap(reg);
      await tester.pump();

      expect(find.text('Do No Leave Email Empty'), findsOneWidget);
      expect(username, findsOneWidget);
      expect(email, findsOneWidget);
      expect(pass, findsOneWidget);
      expect(reg, findsOneWidget);
    });

    testWidgets('Register: No Username', (WidgetTester tester) async {
      // find widgets
      final username = find.byKey(ValueKey('regUsername'));
      final email = find.byKey(ValueKey('regEmail'));
      final pass = find.byKey(ValueKey('regPass'));
      final reg = find.byKey(ValueKey('regBtn'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: Register(
        auth: _firebaseAuth,
        db: _store,
        toggleView: () {},
      )));
      await tester.enterText(username, '');
      await tester.enterText(email, 'testEmail@test.com');
      await tester.enterText(pass, 'testPass');
      await tester.tap(reg);
      await tester.pump();

      expect(
          find.text('Enter a Username greater than 4 chars'), findsOneWidget);
      expect(username, findsOneWidget);
      expect(email, findsOneWidget);
      expect(pass, findsOneWidget);
      expect(reg, findsOneWidget);
    });
    testWidgets('Register: No Password', (WidgetTester tester) async {
      // find widgets
      final username = find.byKey(ValueKey('regUsername'));
      final email = find.byKey(ValueKey('regEmail'));
      final pass = find.byKey(ValueKey('regPass'));
      final reg = find.byKey(ValueKey('regBtn'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: Register(
        auth: _firebaseAuth,
        db: _store,
        toggleView: () {},
      )));
      await tester.enterText(username, 'testUsername');
      await tester.enterText(email, 'testEmail@test.com');
      await tester.enterText(pass, '');
      await tester.tap(reg);
      await tester.pump();

      expect(find.text('Enter a password 6+ characters long'), findsOneWidget);
      expect(username, findsOneWidget);
      expect(email, findsOneWidget);
      expect(pass, findsOneWidget);
      expect(reg, findsOneWidget);
    });
    testWidgets('Change_Username: No Username', (WidgetTester tester) async {
      // find widgets
      final username = find.byKey(ValueKey('newUsername'));
      final change = find.byKey(ValueKey('changeUsername'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: UsernameChanger(
        auth: _firebaseAuth,
        db: _store,
      )));
      await tester.enterText(username, '');
      await tester.tap(change);
      await tester.pump();

      expect(find.text('Enter a New Username'), findsOneWidget);
      expect(username, findsOneWidget);
      expect(change, findsOneWidget);
    });

    testWidgets('Change_Username: Username', (WidgetTester tester) async {
      // find widgets
      final username = find.byKey(ValueKey('newUsername'));
      final change = find.byKey(ValueKey('changeUsername'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: UsernameChanger(
        auth: _firebaseAuth,
        db: _store,
      )));
      await tester.enterText(username, 'TESTER');
      await tester.tap(change);
      await tester.pump();

      expect(username, findsOneWidget);
      expect(change, findsOneWidget);
    });

    testWidgets('Change_Username: Username Too Short',
        (WidgetTester tester) async {
      // find widgets
      final username = find.byKey(ValueKey('newUsername'));
      final change = find.byKey(ValueKey('changeUsername'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: UsernameChanger(
        auth: _firebaseAuth,
        db: _store,
      )));
      await tester.enterText(username, 'tes');
      await tester.tap(change);
      await tester.pump();

      expect(
          find.text('Enter a Username greater than 4 chars'), findsOneWidget);
      expect(username, findsOneWidget);
      expect(change, findsOneWidget);
    });

    testWidgets('Change_Username: Username Too Long',
        (WidgetTester tester) async {
      // find widgets
      final username = find.byKey(ValueKey('newUsername'));
      final change = find.byKey(ValueKey('changeUsername'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: UsernameChanger(
        auth: _firebaseAuth,
        db: _store,
      )));
      await tester.enterText(username, '12345678910');
      await tester.tap(change);
      await tester.pump();

      expect(find.text('Enter a Username less than 10 chars'), findsOneWidget);
      expect(username, findsOneWidget);
      expect(change, findsOneWidget);
    });

    testWidgets('Change_Username: Back Button', (WidgetTester tester) async {
      // find widgets
      final back = find.byKey(ValueKey('back'));

      //executre test
      await tester.pumpWidget(makeTestableWidget(
          child: UsernameChanger(
        auth: _firebaseAuth,
        db: _store,
      )));
      await tester.tap(back);
      await tester.pump();

      expect(back, findsOneWidget);
    });
    testWidgets('Change_Password: Data', (WidgetTester tester) async {
      // find widgets
      final oldPass = find.byKey(ValueKey('curPass'));
      final newPass = find.byKey(ValueKey('newPass'));
      final update = find.byKey(ValueKey('changePass'));

      //executre test
      await tester.pumpWidget(
          makeTestableWidget(child: PasswordChanger(auth: _firebaseAuth)));
      await tester.enterText(oldPass, 'oldPass');
      await tester.enterText(newPass, 'newPass');
      await tester.tap(update);
      await tester.pump();

      expect(oldPass, findsOneWidget);
      expect(newPass, findsOneWidget);
      expect(update, findsOneWidget);
    });

    testWidgets('Change_Password: No Current Pass',
        (WidgetTester tester) async {
      // find widgets
      final oldPass = find.byKey(ValueKey('curPass'));
      final newPass = find.byKey(ValueKey('newPass'));
      final update = find.byKey(ValueKey('changePass'));

      //executre test
      await tester.pumpWidget(
          makeTestableWidget(child: PasswordChanger(auth: _firebaseAuth)));
      await tester.enterText(oldPass, '');
      await tester.enterText(newPass, 'pass');
      await tester.tap(update);
      await tester.pump();

      expect(find.text('Enter Current Password'), findsOneWidget);
      expect(oldPass, findsOneWidget);
      expect(newPass, findsOneWidget);
      expect(update, findsOneWidget);
    });
    testWidgets('Change_Password: No New Pass', (WidgetTester tester) async {
      // find widgets
      final oldPass = find.byKey(ValueKey('curPass'));
      final newPass = find.byKey(ValueKey('newPass'));
      final update = find.byKey(ValueKey('changePass'));

      //executre test
      await tester.pumpWidget(
          makeTestableWidget(child: PasswordChanger(auth: _firebaseAuth)));
      await tester.enterText(oldPass, 'oldPass');
      await tester.enterText(newPass, '');
      await tester.tap(update);
      await tester.pump();

      expect(find.text('Enter a new Password'), findsOneWidget);

      expect(oldPass, findsOneWidget);
      expect(newPass, findsOneWidget);
      expect(update, findsOneWidget);
    });

    testWidgets('Change_Password: Toggle Pass', (WidgetTester tester) async {
      // find widgets
      final vis = find.byKey(ValueKey('CPIcon'));
      //executre test
      await tester.pumpWidget(
          makeTestableWidget(child: PasswordChanger(auth: _firebaseAuth)));
      await tester.tap(vis);
      //executre test
      await tester.pump();

      expect(vis, findsOneWidget);
    });
    testWidgets('Sign In: Toggle Pass', (WidgetTester tester) async {
      // find widgets
      final vis = find.byKey(ValueKey('showPass'));
      //executre test
      await tester
          .pumpWidget(makeTestableWidget(child: SignIn(auth: _firebaseAuth)));
      await tester.tap(vis);
      //executre test
      await tester.pump();

      expect(vis, findsOneWidget);
    });

    testWidgets('Register: Toggle Pass', (WidgetTester tester) async {
      // find widgets
      final vis = find.byKey(ValueKey('VisIcon'));
      //executre test
      await tester
          .pumpWidget(makeTestableWidget(child: Register(auth: _firebaseAuth)));
      await tester.tap(vis);
      //executre test
      await tester.pump();

      expect(vis, findsOneWidget);
    });
  });
}
