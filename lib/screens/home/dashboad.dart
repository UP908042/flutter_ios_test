// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:social_hobby_app/screens/home/account.dart';
import 'package:social_hobby_app/screens/home/chat.dart';
import 'package:social_hobby_app/screens/home/hobby_home.dart';
import 'package:social_hobby_app/screens/home/hobby_search.dart';
import 'package:social_hobby_app/services/auth.dart';
import 'package:social_hobby_app/shared/loading.dart';
import 'package:social_hobby_app/shared/logging.dart';

class Dashboard extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore db;

  const Dashboard({Key key, this.auth, this.db}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final log = logger(Dashboard);
  bool _loading = false;
  int _currentIndex = 0;
  String _title;
  Color _color;
  PageController _pageController;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabPages = [
      Home(
        db: widget.db,
        auth: widget.auth,
      ),
      Hobby(
        db: widget.db,
        auth: widget.auth,
      ),
      Chat(
        db: widget.db,
        auth: widget.auth,
      ),
      Account(db: widget.db, auth: widget.auth),
    ];
    return _loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              toolbarHeight: 40.0,
              elevation: 0.0,
              title: Text(
                _title,
                style: const TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                TextButton.icon(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.black,
                  ),
                  label: const Text('Logout',
                      style: TextStyle(color: Colors.black)),
                  onPressed: () async {
                    setState(() => _loading = true);
                    final result =
                        await AuthService(auth: widget.auth).signOut();

                    if (result == false) {
                      _loading = false;
                    }
                  },
                )
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: onTabTapped,
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: _color,
              showUnselectedLabels: false,
              unselectedItemColor: Colors.black,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search), label: 'Find Hobbies'),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Settings')
              ],
            ),
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: onPageChanged,
              controller: _pageController,
              children: tabPages,
            ),
          );
  }

  @override
  void initState() {
    _title = 'My Hobbies';
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  void onTabTapped(int index) {
    switch (index) {
      case 0:
        {
          _title = 'My Hobbies';
          _color = Colors.blue[400];
        }
        break;
      case 1:
        {
          _title = 'Find Hobbies';
          _color = Colors.purple[400];
        }
        break;
      case 2:
        {
          _title = 'My Chats';
          _color = Colors.red[400];
        }
        break;
      case 3:
        {
          _title = 'Settings';
          _color = Colors.pink[400];
        }
        break;
    }
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }
}
