// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:project/services/middleware.dart';

import 'edit_task.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../models/user.dart';

class SingleTaskView extends StatefulWidget {
  final Task task;
  final Project project;
  final List<User> editors;
  const SingleTaskView({
    Key? key,
    required this.task,
    required this.project,
    required this.editors,
  }) : super(key: key);

  @override
  State<SingleTaskView> createState() => _SingleTaskViewState();
}

class _SingleTaskViewState extends State<SingleTaskView> {
  final ApiService _api = ApiService();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _status = TextEditingController();
  final TextEditingController _endTime = TextEditingController();
  final TextEditingController _startTime = TextEditingController();
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
    final List<User> editors = widget.editors;
    // double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _key,
      body: StreamBuilder<Task>(
        stream: _api.fetchTask(widget.task.url).asStream(),
        builder: (context_, snapshot) {
          if (snapshot.hasError) Text("Error Happened");
          if (snapshot.hasData) {
            final Task task = snapshot.data!;
            return StreamBuilder<User>(
              stream: _api.fetchUserData().asStream(),
              builder: (context, snapshot) {
                onSelected(BuildContext context, int item) async {
                  switch (item) {
                    case 0:
                      await _api.leaveTask(context, project, task);
                      setState(() {});
                      Navigator.pop(context, true);
                      setState(() {});
                      break;
                    case 1:
                      bool res = (await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "Update task",
                            ),
                            content: Text(
                              "You're updating ${task.title} status",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  Task _task = task.copyWith(
                                    url: task.url,
                                    projectId: task.projectId,
                                    id: task.id,
                                    owner: task.owner,
                                    project: task.project,
                                    title: task.title,
                                    start: task.start,
                                    end: task.end,
                                    desc: task.desc,
                                    status: "in progress",
                                    members: task.members,
                                    complete: task.complete,
                                  );
                                  bool res = await _api.updateTask(_task);
                                  res
                                      ? Navigator.pop(context, res)
                                      : setState(() {});
                                  res ? setState(() {}) : setState(() {});
                                },
                                child: Text("Start task"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Task _task = task.copyWith(
                                    complete: task.complete,
                                    url: task.url,
                                    projectId: task.projectId,
                                    id: task.id,
                                    owner: task.owner,
                                    project: task.project,
                                    title: task.title,
                                    start: task.start,
                                    end: task.end,
                                    desc: task.desc,
                                    status: "done",
                                    members: task.members.cast<String>(),
                                  );
                                  bool res = await _api.updateTask(_task);
                                  res
                                      ? Navigator.pop(context, res)
                                      : setState(() {});
                                  res ? setState(() {}) : setState(() {});
                                },
                                child: Text("Finish task"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: Text("Cancel"),
                              ),
                            ],
                          );
                        },
                      ))!;
                      ScaffoldMessenger.of(context_).showSnackBar(
                        SnackBar(
                          backgroundColor: res ? Colors.green : Colors.red,
                          content: Text(res ? "Updated" : "Canceled"),
                        ),
                      );
                      ScaffoldMessenger.of(context_).setState(() {});
                      break;
                    case 2:
                      bool res =
                          (await Navigator.of(_key.currentState!.context).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => EditTask(
                            project: widget.project,
                            task: task,
                          ),
                        ),
                      ))!;
                      await Future.delayed(
                        Duration(
                          milliseconds: 1500,
                        ),
                      );
                      ScaffoldMessenger.of(context_).showSnackBar(
                        SnackBar(
                          backgroundColor: res ? Colors.green : Colors.red,
                          content: Text(res ? "Edited" : "Canceled"),
                        ),
                      );
                      ScaffoldMessenger.of(context_).setState(() {});
                      break;
                    case 3:
                      rebuildAllChildren(_key.currentState!.context);
                      break;
                    case 4:
                      bool res = (await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "Delete project",
                            ),
                            content: Text(
                              "Are you sure about deleting ${task.title}?\n"
                              "These changes can't be undone once you click on \"Yes\" button..",
                            ),
                            actions: [
                              TextButton.icon(
                                onPressed: () async {
                                  bool res = await _api.deleteTask(task);
                                  res
                                      ? Navigator.pop(context, true)
                                      : setState(() {});
                                  res ? setState(() {}) : setState(() {});
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
                    case 5:
                      Task _task = task.copyWith(
                        url: task.url,
                        projectId: task.projectId,
                        id: task.id,
                        owner: task.owner,
                        project: task.project,
                        title: task.title,
                        start: task.start,
                        end: task.end,
                        desc: task.desc,
                        status: task.status,
                        members: task.members,
                        complete: true,
                      );
                      bool res = await _api.updateTask(_task);
                      res ? Navigator.pop(context, res) : setState(() {});
                      res ? setState(() {}) : setState(() {});
                      break;
                  }
                }

                if (snapshot.hasError) Text("Error Happened");
                if (snapshot.hasData) {
                  User user = snapshot.data!;
                  _startTime.text = Jiffy(task.start).fromNow();
                  _endTime.text = Jiffy(task.end).fromNow();
                  _title.text = task.title;
                  _desc.text = task.desc;
                  _status.text = task.status;
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(task.title),
                      actions: [
                        PopupMenuButton<int>(
                          onSelected: (int item) => onSelected(context, item),
                          itemBuilder: (context) =>
                              project.owner == user.username &&
                                      editors
                                          .map((e) => e.username)
                                          .contains(user.username)
                                  ? [
                                      const PopupMenuItem<int>(
                                        value: 0,
                                        child: Text("Leave task"),
                                      ),
                                      const PopupMenuDivider(
                                        height: 1,
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 1,
                                        child: Text("Update task status"),
                                      ),
                                      const PopupMenuDivider(
                                        height: 1,
                                      ),
                                      PopupMenuItem<int>(
                                        value: 2,
                                        child: Text("Edit task"),
                                      ),
                                      const PopupMenuDivider(
                                        height: 1,
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 4,
                                        child: Text('Delete task'),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 5,
                                        child: Text('Mark as complete'),
                                      ),
                                      const PopupMenuDivider(
                                        height: 1,
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 3,
                                        child: Text("Refresh"),
                                      ),
                                    ]
                                  : !editors
                                          .map((e) => e.username)
                                          .contains(user.username)
                                      ? [
                                          PopupMenuItem<int>(
                                            value: 2,
                                            child: Text("Edit task"),
                                          ),
                                          const PopupMenuDivider(
                                            height: 1,
                                          ),
                                          const PopupMenuItem<int>(
                                            value: 4,
                                            child: Text('Delete task'),
                                          ),
                                          const PopupMenuDivider(
                                            height: 1,
                                          ),
                                          const PopupMenuItem<int>(
                                            value: 5,
                                            child: Text('Mark as complete'),
                                          ),
                                          const PopupMenuDivider(
                                            height: 1,
                                          ),
                                          const PopupMenuItem<int>(
                                            value: 3,
                                            child: Text("Refresh"),
                                          ),
                                        ]
                                      : [
                                          const PopupMenuItem<int>(
                                            value: 0,
                                            child: Text("Leave task"),
                                          ),
                                          const PopupMenuDivider(
                                            height: 1,
                                          ),
                                          const PopupMenuItem<int>(
                                            value: 1,
                                            child: Text("Update task status"),
                                          ),
                                          const PopupMenuDivider(
                                            height: 1,
                                          ),
                                          const PopupMenuItem<int>(
                                            value: 3,
                                            child: Text("Refresh"),
                                          ),
                                        ],
                        ),
                      ],
                    ),
                    body: SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   mainAxisSize: MainAxisSize.max,
                              //   children: [
                              //     // Card(
                              //     //   color: Colors.blue,
                              //     //   child: Padding(
                              //     //     padding: const EdgeInsets.all(8.0),
                              //     //     child:
                              //     //         Text("Task status: " + task.status),
                              //     //   ),
                              //     // ),
                              //   ],
                              // ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0,
                                  vertical: 16,
                                ),
                                child: TextField(
                                  controller: _title,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    label: Text("Task Title"),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0,
                                  vertical: 16,
                                ),
                                child: TextField(
                                  controller: _status,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    label: Text("Task Status"),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: width - 50,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: width * 0.3,
                                        child: TextField(
                                          controller: _startTime,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            label: Text("Starts"),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: width * 0.3,
                                        child: TextField(
                                          controller: _endTime,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            label: Text("Ends"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional.center,
                                child: SizedBox(
                                  width: width * 0.82,
                                  child: TextField(
                                    maxLines: null,
                                    controller: _desc,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      label: Text("Task Description"),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: ListTile(
                                    title: Text(
                                      "Assigned to:",
                                      style: Theme.of(context)
                                          .inputDecorationTheme
                                          .floatingLabelStyle,
                                    ),
                                    isThreeLine: true,
                                    subtitle: Wrap(
                                      direction: Axis.horizontal,
                                      children: editors
                                          .map(
                                            (e) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 2.0,
                                              ),
                                              child: Chip(
                                                label: Text(e.username),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                color: Colors.blue,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: editors
                                          .map((e) => e.username)
                                          .contains(user.username)
                                      ? Text(
                                          "You're allowed to edit status",
                                        )
                                      : Text(
                                          "You aren't allowed to edit status",
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
