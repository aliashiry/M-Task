// ignore_for_file: file_names, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/project.dart';
import 'package:project/models/task.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/single_task_view.dart';

import '../services/middleware.dart';

class OtherTasks extends StatefulWidget {
  final User user;
  OtherTasks({required this.user});
  @override
  State<OtherTasks> createState() => _OtherTasksState();
}

class _OtherTasksState extends State<OtherTasks> {
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
    final User user = widget.user;

    return Scaffold(
      key: _key,
      body: StreamBuilder<Map<int, List<Object>>>(
        stream: _api.getOtherTasks(user.id).asStream(),
        builder: (context_, snapshot) {
          if (snapshot.hasError) Text("Error happened ${snapshot.error}");
          if (snapshot.hasData &&
              snapshot.data![0]!.isNotEmpty &&
              snapshot.data![1]!.isNotEmpty) {
            Map<int, List<Object>> data = snapshot.data!;
            List<Task> tasks = data[0] as List<Task>;
            List<Project> projects = data[1] as List<Project>;

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
                backgroundColor: const Color(0xff076792),
                title: Text(
                  "Other Tasks",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(color: Color(0xa6A2B6D4), blurRadius: 20),
                    ],
                  ),
                ),
                leading: BackButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      rebuildAllChildren(_key.currentState!.context);
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ],
              ),
              body: ListView.builder(
                shrinkWrap: true,
                itemCount: tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  Task _task = tasks[index];
                  return StreamBuilder<List<User>>(
                    stream: _api.getTaskMembers(_task.members).asStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) Text("Error Happened");
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        List<User> members = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                            28,
                            12,
                            28,
                            0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SingleTaskView(
                                    task: _task,
                                    project: projects[index],
                                    editors: members,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  8,
                                  9,
                                  4,
                                ),
                                width: MediaQuery.of(context).size.width * 0.8,
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(19.0),
                                  color: const Color(0xff076792),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: Color(0xa6A2B6D4),
                                      offset: Offset(7, 5),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Starting ' +
                                              DateFormat.yMMMMEEEEd().format(
                                                _task.start,
                                              ),
                                          style: const TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              133,
                                              186,
                                              202,
                                            ),
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _task.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Ending ' +
                                              DateFormat.yMMMMEEEEd().format(
                                                _task.end,
                                              ),
                                          style: const TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              133,
                                              186,
                                              202,
                                            ),
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Status: ${_task.status}",
                                      style: const TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          133,
                                          186,
                                          202,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Assigned to:",
                                        style: const TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            133,
                                            186,
                                            202,
                                          ),
                                        ),
                                      ),
                                      isThreeLine: true,
                                      subtitle: Text(
                                        members
                                            .map((e) => e.username)
                                            .toList()
                                            .join(" - "),
                                        style: const TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            133,
                                            186,
                                            202,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return Center(
                          child: Text("You have no other tasks"),
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                },
              ),
            );
          } else if (snapshot.hasData &&
              snapshot.data![0]!.isEmpty &&
              snapshot.data![1]!.isEmpty) {
            return Center(
              child: Text("You have no tasks"),
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
