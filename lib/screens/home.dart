// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:project/screens/other_tasks.dart';
import 'package:project/widgets/drawer.dart';

import '../models/user.dart';
import '../services/middleware.dart';
import 'create_project.dart';
import 'projects_view.dart';

class HomePage extends StatefulWidget {
  ///* Homescreen
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: FutureBuilder<bool>(
        future: Future.delayed(Duration(seconds: 5), () {
          return true;
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return FutureBuilder<User>(
              future: _api.fetchUserData(),
              builder: (context_, snapshot) {
                if (snapshot.hasData) {
                  final User _user = snapshot.data!;
                  return Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      elevation: 0,
                      bottom: PreferredSize(
                        child: Container(
                          color: const Color(0xff94adb4),
                          height: 2,
                          width: 320,
                        ),
                        preferredSize: const Size.fromHeight(4.0),
                      ),
                      centerTitle: true,
                      iconTheme: const IconThemeData(
                        color: Colors.white,
                        size: 40,
                      ),
                      backgroundColor: const Color(0xff076792),
                      title: const Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(color: Color(0xa6A2B6D4), blurRadius: 20),
                          ],
                        ),
                      ),
                      actions: [
                        PopupMenuButton<int>(
                          onSelected: (int item) {
                            switch (item) {
                              case 0:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OtherTasks(user: _user),
                                  ),
                                );
                                break;
                              case 1:
                                rebuildAllChildren(_key.currentState!.context);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 0,
                              child: Text("Other Tasks"),
                            ),
                            const PopupMenuDivider(
                              height: 1,
                            ),
                            const PopupMenuItem<int>(
                              value: 1,
                              child: Text("Refresh"),
                            ),
                          ],
                        ),
                      ],
                    ),
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(7),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(24, 20, 10, 8),
                                  child: Text(
                                    'My Projects:',
                                    style: TextStyle(
                                      color: Color(0xff076792),
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(28, 12, 0, 0),
                                child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: FloatingActionButton(
                                    backgroundColor: const Color(0xff076792),
                                    onPressed: () async {
                                      bool res = (await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute<bool>(
                                          builder: (context) => NewProject(),
                                        ),
                                      ))!;
                                      res ? setState(() {}) : setState(() {});
                                    },
                                    child: const Icon(Icons.add),
                                    shape: const StadiumBorder(
                                      side: BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          (_user.projects.isNotEmpty)
                              ? ProjectsView(
                                  projects: _user.projects,
                                  user: _user,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(60.0),
                                  child: const Text(
                                    "You Don't Have Any Projects Yet.",
                                    style: TextStyle(
                                      fontSize: 27,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    drawer: DrawerWidget(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error Happened"),
                  );
                }

                return Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
