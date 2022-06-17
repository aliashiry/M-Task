// ignore_for_file: file_names, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/project.dart';
import 'package:project/models/task.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/single_task_view.dart';

import '../services/middleware.dart';

class TasksView extends StatefulWidget {
  final Project project;
  TasksView({required this.project});
  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
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
    final Project _project = widget.project;

    return Scaffold(
      key: _key,
      body: FutureBuilder<List<Task>>(
        future: _api.getTasks(_project.tasks),
        builder: (context_, snapshot) {
          if (snapshot.hasError) Text("Error happened ${snapshot.error}");
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Task> tasks = snapshot.data!;
            return Scaffold(
              body: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 10, 10, 8),
                        child: Text(
                          _project.title,
                          style: const TextStyle(
                            color: Color(0xff076792),
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: tasks.length,
                      itemBuilder: (BuildContext context, int index) {
                        Task _task = tasks[index];
                        return FutureBuilder<List<User>>(
                          future: _api.getTaskMembers(_task.members),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) Text("Error Happened");
                            if (snapshot.hasData) {
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
                                          project: widget.project,
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
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.3,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(19.0),
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
                                                    DateFormat.yMMMMEEEEd()
                                                        .format(
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
                                                  fontSize: 34,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Ending ' +
                                                    DateFormat.yMMMMEEEEd()
                                                        .format(
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
                                          _task.complete
                                              ? Center(
                                                  child: Text(
                                                    "COMPLETED",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color.fromARGB(
                                                        255,
                                                        181,
                                                        209,
                                                        218,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(),
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
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(
              child: Text("No tasks"),
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
