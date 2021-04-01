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

class Register extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore db;
  final Function toggleView;

  const Register({this.auth, this.toggleView, this.db});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final log = logger(Register);
  // Assign Form A Key for Identification
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String error = '';

  bool obsecureText = true;
  // Fields
  String email = '';
  String password = '';
  String username = '';

  @override
  Widget build(BuildContext context) {
    void _togglePass() {
      setState(() {
        obsecureText = !obsecureText;
      });
    }

    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.blue[200],
            body: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    const SizedBox(
                      height: 150.0,
                      child: Center(
                          child: Icon(Icons.category_outlined,
                              color: Colors.white, size: 150)),
                    ),
                    TextFormField(
                      key: const Key('regUsername'),
                      decoration: const InputDecoration(
                        hintText: 'Enter a Username',
                      ),
                      autocorrect: false,
                      validator: (val) {
                        return val.length < 4
                            ? 'Enter a Username greater than 4 chars'
                            : null;
                      },
                      onChanged: (val) {
                        setState(() => username = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      key: const Key('regEmail'),
                      decoration: const InputDecoration(
                        hintText: 'Enter an Email',
                      ),
                      validator: (val) {
                        return val.isEmpty ? 'Do No Leave Email Empty' : null;
                      },
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      key: const Key('regPass'),
                      decoration: InputDecoration(
                        hintText: 'Enter a Password',
                        suffixIcon: IconButton(
                            key: Key('VisIcon'),
                            icon: const Icon(Icons.visibility),
                            onPressed: _togglePass),
                      ),
                      obscureText: obsecureText,
                      autocorrect: false,
                      validator: (val) {
                        return val.length < 6
                            ? 'Enter a password 6+ characters long'
                            : null;
                      },
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    const SizedBox(height: 60.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                      key: const Key('regBtn'),
                      onPressed: () async {
                        // Validate Form
                        if (_formKey.currentState.validate()) {
                          setState(() => loading = true);
                          // ignore: prefer_final_locals
                          dynamic result = await AuthService(auth: widget.auth)
                              .createAccount(
                                  email: email,
                                  password: password,
                                  db: widget.db);
                          if (result == false) {
                            setState(() {
                              error = 'Please Supply Valid Credentials';
                              loading = false;
                            });
                          } else {
                            try {
                              Database(db: widget.db).addUser(
                                  AuthService(auth: widget.auth).userInfo.uid,
                                  username);
                            } catch (e) {
                              log.e(e);
                              setState(() {
                                error = 'Database Error';
                                loading = false;
                              });
                            }
                          }
                        }
                      },
                      child: const Text('Register',
                          style: TextStyle(color: Colors.blue)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                      key: Key('ToggleReg'),
                      onPressed: () {
                        widget.toggleView();
                      },
                      child: const Text('Already have an account? Sign In',
                          style: TextStyle(color: Colors.blue)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    const Expanded(
                        child: SizedBox(
                      height: 0,
                    )),
                  ],
                ),
              ),
            ),
          );
  }
}
