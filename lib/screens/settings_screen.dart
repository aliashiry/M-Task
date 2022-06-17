// ignore_for_file: constant_identifier_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/onboarding_screens.dart';
import 'package:project/screens/reset_password.dart';

import '../services/middleware.dart';

enum Languages { English, Arabic }

class SettingsScreen extends StatefulWidget {
  final User user;
  const SettingsScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _api = ApiService();

  @override
  Widget build(BuildContext context) {
    final User user = widget.user;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff076792),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 30.0,
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Color(0xa6A2B6D4),
                offset: Offset(7, 5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                icon: Icon(
                  Icons.lock,
                  size: 30,
                  color: Color(0xff076792),
                ),
                label: Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xff076792),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResetPassword(),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 50,
              ),
              TextButton.icon(
                icon: Icon(
                  Icons.language,
                  size: 30,
                  color: Color(0xff076792),
                ),
                label: const Text(
                  'Change Language',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xff076792),
                  ),
                ),
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text(
                        'Change Language',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff076792),
                          fontSize: 24,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const <Widget>[
                          MyStatefulWidget(),
                        ],
                      ),
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                          color: Color(0xff076792),
                          width: 1,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Change'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 50,
              ),
              // TextButton.icon(
              //   icon: Icon(
              //     Icons.delete,
              //     size: 30,
              //     color: Color(0xff076792),
              //   ),
              //   label: Text(
              //     'Clear Your Projects',
              //     style: TextStyle(
              //       fontSize: 20,
              //       color: Color(0xff076792),
              //     ),
              //   ),
              //   onPressed: () {
              // ignore: todo
              //     // TODO: Make `DeleteProjects Function`
              //   },
              // ),
              // const SizedBox(
              //   height: 50,
              // ),
              TextButton.icon(
                icon: Icon(
                  Icons.warning,
                  size: 30,
                  color: Color(0xff076792),
                ),
                label: Text(
                  'Delete Your Accont',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xff076792),
                  ),
                ),
                onPressed: () async {
                  await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          "Delete Account",
                        ),
                        content: Text(
                          "Are you sure about deleting your account?\n"
                          "These changes can't be undone once you click on \"Yes\" button..",
                        ),
                        actions: [
                          TextButton.icon(
                            onPressed: () async {
                              bool res = await _api.deleteUser(user);
                              if (res) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OnboardingScreen(),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.delete),
                            label: Text("Yes"),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            icon: Icon(Icons.arrow_back),
                            label: Text("No"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(
                height: 70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  Languages? _lang = Languages.English;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('English'),
          leading: Radio<Languages>(
            value: Languages.English,
            groupValue: _lang,
            onChanged: (Languages? value) {
              setState(() {
                _lang = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Arabic'),
          leading: Radio<Languages>(
            value: Languages.Arabic,
            groupValue: _lang,
            onChanged: (Languages? value) {
              setState(() {
                _lang = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
