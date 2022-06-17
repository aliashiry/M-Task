// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:project/models/group.dart';
import 'package:project/models/project.dart';
import 'package:project/screens/AddMember.dart';
import 'package:project/services/middleware.dart';

import '../models/user.dart';

class MembersView extends StatefulWidget {
  final Project project;
  final User? current;
  final Group? group;
  MembersView({
    Key? key,
    required this.project,
    this.current,
    this.group,
  }) : super(key: key);

  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
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
    final Project project = widget.project;
    final User? current = widget.current;
    final Group? group = widget.group;
    return Scaffold(
      key: _key,
      body: StreamBuilder<Group>(
        stream: _api.fetchGroup(
          group == null ? project.group : group.url,
        ).asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) Text("Error happened ${snapshot.error}");
          if (snapshot.hasData) {
            final Group group = snapshot.data!;
            return StreamBuilder<List<User>>(
              stream: _api.getGroupMembers(group.members).asStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  Text("Error happened ${snapshot.error}");
                }
                if (snapshot.hasData) {
                  List<User> users = snapshot.data!;
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(
                        group.title + " group",
                      ),
                      actions: [
                        PopupMenuButton<int>(
                          onSelected: (int item) async {
                            switch (item) {
                              case 0:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddMember(
                                      project: project,
                                      members: users,
                                      group: group,
                                      current: current,
                                    ),
                                  ),
                                );
                                break;
                              case 1:
                                rebuildAllChildren(_key.currentState!.context);
                                break;
                              case 2:
                                bool res = (await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        "Delete group",
                                      ),
                                      content: Text(
                                        "Are you sure about deleting ${group.title}?\n"
                                        "These changes can't be undone once you click on \"Yes\" button..",
                                      ),
                                      actions: [
                                        TextButton.icon(
                                          onPressed: () async {
                                            bool res =
                                                await _api.deleteGroup(group);
                                            res
                                                ? Navigator.pop(context, true)
                                                : setState(() {});
                                            res
                                                ? setState(() {})
                                                : setState(() {});
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
                                ))!;
                                res ? Navigator.pop(context) : setState(() {});
                                res ? setState(() {}) : setState(() {});
                                setState(() {});

                                break;
                            }
                          },
                          itemBuilder: (context) => current != null &&
                                  project.owner == current.username
                              ? [
                                  const PopupMenuItem<int>(
                                    value: 0,
                                    child: Text("Edit Members"),
                                  ),
                                  const PopupMenuDivider(
                                    height: 1,
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 2,
                                    child: Text("Delete group"),
                                  ),
                                  const PopupMenuItem<int>(
                                    value: 1,
                                    child: Text("Refresh"),
                                  ),
                                ]
                              : [
                                  const PopupMenuItem<int>(
                                    value: 1,
                                    child: Text("Refresh"),
                                  ),
                                ],
                        ),
                      ],
                    ),
                    body: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        int count = 0;
                        User user = users[index];
                        for (String task in project.tasks.cast<String>()) {
                          if (user.tasks.cast<String>().contains(task)) {
                            count++;
                          }
                        }
                        return ListTile(
                          leading: Icon(
                            project.owner == user.username
                                ? Icons.admin_panel_settings
                                : Icons.person,
                          ),
                          title: Text(user.username),
                          subtitle: Text("Tasks number: $count"),
                          trailing: project.owner == user.username
                              ? Text("Owner")
                              : Text("Member"),
                        );
                      },
                    ),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
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
