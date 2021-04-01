// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:social_hobby_app/services/auth.dart';
import 'package:social_hobby_app/shared/loading.dart' show Loading;
import 'package:social_hobby_app/shared/logging.dart';

class SignIn extends StatefulWidget {
  final FirebaseAuth auth;
  final Function toggleView;
  const SignIn({Key key, @required this.auth, this.toggleView})
      : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final log = logger(SignIn);
  // Assign Form A Key for Identification
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String error = '';

  bool obsecureText = true;
  // Fields
  String email = '';
  String password = '';

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
                    const SizedBox(height: 30),
                    TextFormField(
                      key: const Key('signInEmail'),
                      decoration: const InputDecoration(
                        hintText: 'Enter an Email',
                      ),
                      validator: (val) {
                        return val.isEmpty ? 'Enter an email' : null;
                      },
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      key: const Key('signInPass'),
                      obscureText: obsecureText,
                      decoration: InputDecoration(
                        hintText: 'Enter a Password',
                        suffixIcon: IconButton(
                            key: Key('showPass'),
                            icon: const Icon(Icons.visibility),
                            onPressed: _togglePass),
                      ),
                      validator: (val) {
                        return val.length < 6
                            ? 'Enter a password 6+ Characters Long'
                            : null;
                      },
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                        ),
                        key: const Key('signInBtn'),
                        // ignore: sort_child_properties_last
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              loading = true;
                            });
                            final dynamic result =
                                await AuthService(auth: widget.auth)
                                    .signIn(email: email, password: password);
                            if (result == false) {
                              setState(() {
                                loading = false;
                                error =
                                    'Could not sign in with those credentials';
                              });
                            }
                          }
                        }),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                      key: Key('toggleSign'),
                      onPressed: () {
                        widget.toggleView();
                      },
                      child: const Text("Don't have an account? Sign Up",
                          style: TextStyle(color: Colors.blue)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      error,
                      key: const Key('errorMSG'),
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    const Expanded(
                        child: SizedBox(
                      height: 0,
                    )),
                  ],
                ),
              ),
            ));
  }
}
