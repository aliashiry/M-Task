// ignore_for_file: prefer_const_constructors, avoid_print

// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/about_screen.dart';
import '../screens/contact_us_screen.dart';
import '../screens/onboarding_screens.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../services/middleware.dart';
import '../services/sharedPrefs.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final ApiService _api = ApiService();
  final SharedPrefsUtils _prefs = SharedPrefsUtils.getInstance();

  @override
  Widget build(BuildContext context) {
    var raw = _prefs.getData("profile_pic");
    Map<String, dynamic>? data = raw == null ? null : jsonDecode(raw);

    ImageProvider image() {
      if (data != null) {
        return NetworkImage(
          data["pic"],
        );
      } else {
        return AssetImage(
          "assets/images/image.png",
        );
      }
    }

    return StreamBuilder<User>(
      stream: _api.fetchUserData().asStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final User _user = snapshot.data!;
          return Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              ///* Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Color(0xff076792),
                  ),
                  onDetailsPressed: null,
                  otherAccountsPicturesSize: Size.zero,
                  accountName: Text(
                    _user.username,
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  accountEmail: _user.email.isEmpty
                      ? null
                      : Text(
                          _user.email,
                        ),
                  currentAccountPictureSize:
                      _user.email.isEmpty ? Size.square(90) : Size.square(70),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: image(),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person_sharp,
                    size: 30,
                    color: Color(0xff076792),
                  ),
                  title: const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xff076792),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(user: _user),
                      ),
                    );
                  },
                ),
                const Divider(
                  color: Color(0xff076792),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.settings,
                    size: 30,
                    color: Color(0xff076792),
                  ),
                  title: const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xff076792),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          user: _user,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(
                  color: Color(0xff076792),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.phone,
                    size: 30,
                    color: Color(0xff076792),
                  ),
                  title: const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xff076792),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactUsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(
                  color: Color(0xff076792),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.help,
                    size: 30,
                    color: Color(0xff076792),
                  ),
                  title: const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xff076792),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutScreen(),
                      ),
                    );
                  },
                ),
                const Divider(
                  color: Color(0xff076792),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    size: 30,
                    color: Color(0xff076792),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xff076792),
                    ),
                  ),
                  onTap: () async {
                    bool result = await _api.logoutUser();
                    result
                        ? Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OnboardingScreen(),
                            ),
                          )
                        : print("Logout failed");
                  },
                ),
                const Divider(
                  color: Color(0xff076792),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error Happened"),
          );
        }

        return Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
