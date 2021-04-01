// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:social_hobby_app/services/auth.dart';
import 'package:social_hobby_app/shared/loading.dart';
import 'package:social_hobby_app/shared/logging.dart';

class PasswordChanger extends StatefulWidget {
  final FirebaseAuth auth;

  const PasswordChanger({this.auth});
  // Assign Form A Key for Identification
  @override
  _PasswordChangerState createState() => _PasswordChangerState();
}

abstract class PChanger {
  void togglePass();
}

class _PasswordChangerState extends State<PasswordChanger> {
  final log = logger(PasswordChanger);
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  bool obsecureText = true;

  String error = '';

  String success = '';

  String _oldPass = '';

  String _newPass = '';

  @override
  Widget build(BuildContext context) {
    void togglePass() {
      setState(() {
        obsecureText = !obsecureText;
      });
    }

    final topAppBar = AppBar(
      title: const Text('Change Password'),
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
    );
    final bottomAppBar = Container(
      alignment: Alignment.bottomLeft,
      height: 55,
      color: Colors.white,
    );
    Widget _resetPassword() {
      return Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: Column(children: <Widget>[
              const SizedBox(height: 20.0),
              TextFormField(
                key: const Key('curPass'),
                decoration: InputDecoration(
                  hintText: 'Enter Current Password',
                  suffixIcon: IconButton(
                      key: Key('CPIcon'),
                      icon: const Icon(Icons.visibility),
                      onPressed: togglePass),
                ),
                obscureText: obsecureText,
                autocorrect: false,
                validator: (val) {
                  log.d('User Entered No Password');
                  return val.isEmpty ? 'Enter Your Current Password' : null;
                },
                onChanged: (val) {
                  setState(() => _oldPass = val);
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                key: const Key('newPass'),
                decoration: const InputDecoration(
                  hintText: 'Enter a new Password',
                ),
                obscureText: obsecureText,
                autocorrect: false,
                validator: (val) {
                  log.d('User Entered Password Too Short');
                  return val.length < 6
                      ? 'Enter a password 6+ characters long'
                      : null;
                },
                onChanged: (val) {
                  setState(() => _newPass = val);
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                key: const Key('changePass'),
                onPressed: () async {
                  // Validate Form
                  if (_formKey.currentState.validate()) {
                    setState(() {
                      _loading = true;
                      error = '';
                      success = '';
                    });

                    final bool result = await AuthService(auth: widget.auth)
                        .changePassword(_oldPass, _newPass);

                    if (result == false) {
                      setState(() {
                        error =
                            'Your Current Password, You Entered, Was Invalid';
                      });
                    } else {
                      success = 'Your Password Has Been Successfully Updated';
                    }

                    setState(() {
                      _loading = false;
                    });
                  }
                },
                child: const Text('Change Password',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20.0),
              Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 14.0),
              ),
              const SizedBox(height: 20.0),
              Text(
                success,
                style: const TextStyle(color: Colors.green, fontSize: 14.0),
              )
            ]),
          ));
    }

    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.blue[200],
            appBar: topAppBar,
            bottomNavigationBar: bottomAppBar,
            body: _resetPassword(),
          );
  }
}
