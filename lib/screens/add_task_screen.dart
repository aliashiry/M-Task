// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:intl/intl.dart';
import 'package:project/models/project.dart';
import 'package:project/services/middleware.dart';

// import '../models/group.dart';
import '../models/user.dart';
import 'AddMember.dart';
import 'single_project_view.dart';

class AddTask extends StatefulWidget {
  final Project project;
  const AddTask({
    required this.project,
  });
  @override
  State<StatefulWidget> createState() {
    return _AddTask();
  }
}

class _AddTask extends State<AddTask> {
  final ApiService _api = ApiService();
  TextEditingController taskNameCon = TextEditingController();
  TextEditingController noteCon = TextEditingController();
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  final _chipKey = GlobalKey<ChipsInputState>();

  List<AppProfile> newMems = [];

  @override
  Widget build(BuildContext context) {
    final Project _project = widget.project;
    var startDate = (DateFormat.yMMMMEEEEd().format(
              selectedStartDate,
            ) ==
            DateFormat.yMMMMEEEEd().format(
              DateTime.now(),
            ))
        ? "today"
        : DateFormat.yMMMMEEEEd().format(
            selectedStartDate,
          );
    var endDate = (DateFormat.yMMMMEEEEd().format(
              selectedEndDate,
            ) ==
            DateFormat.yMMMMEEEEd().format(
              DateTime.now(),
            ))
        ? "today"
        : DateFormat.yMMMMEEEEd().format(
            selectedEndDate,
          );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff076792),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 30.0,
        ),
        title: Center(
          child: Text(
            _project.title,
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
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Add Task',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff076792),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 0,
                ),
                child: TextFormField(
                  controller: taskNameCon,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 22.0,
                      horizontal: 10.0,
                    ),
                    hintText: "",
                    labelText: 'Task Name',
                    labelStyle: TextStyle(
                      fontSize: 15,
                      color: Color(0xffc9c9c9),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xff076792),
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30),
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 10,
                controller: noteCon,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 50.0,
                    horizontal: 10.0,
                  ),
                  labelText: 'Task Note',
                  hintText: "",
                  labelStyle: TextStyle(
                    fontSize: 15,
                    color: Color(0xffc9c9c9),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        15,
                      ),
                    ),
                    borderSide: BorderSide(
                      width: 2,
                      color: Color(0xff076792),
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 50),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(
                          right: 20.0,
                        ),
                        width: 150,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Start time"),
                            ),
                            ElevatedButton(
                              child: Text(
                                "Selected date is\n" + startDate,
                              ),
                              onPressed: () async {
                                DateTime _selected = (await showDatePicker(
                                  context: context,
                                  initialDate: selectedStartDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2050),
                                ))!;
                                setState(() {
                                  selectedStartDate = _selected;
                                });
                                print(selectedStartDate);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                        ),
                        width: 150,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("End time"),
                            ),
                            ElevatedButton(
                              child: Text(
                                "Selected date is\n" + endDate,
                              ),
                              onPressed: () async {
                                DateTime _selected = (await showDatePicker(
                                  context: context,
                                  initialDate: selectedEndDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2050),
                                ))!;
                                setState(() {
                                  selectedEndDate = _selected;
                                });
                                print(selectedEndDate);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<User>>(
                      future: _api.getUsers(),
                      builder: (context, snapshot2) {
                        if (snapshot2.hasData) {
                          final List<User> users = snapshot2.data!;
                          final List<AppProfile> usersProfiles = List.generate(
                            users.length,
                            (i) => AppProfile(
                              users[i].firstName + " " + users[i].lastName,
                              users[i].username,
                              users[i].url,
                            ),
                          );
                          return Padding(
                            padding: EdgeInsets.all(20),
                            child: SingleChildScrollView(
                              child: ChipsInput<AppProfile>(
                                key: _chipKey,
                                autofocus: true,
                                keyboardAppearance: Brightness.dark,
                                textCapitalization: TextCapitalization.words,
                                textStyle: const TextStyle(
                                  height: 1.5,
                                  fontFamily: 'Roboto',
                                  fontSize: 16,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Select People',
                                ),
                                findSuggestions: (String query) {
                                  if (query.isNotEmpty) {
                                    var lowercaseQuery = query.toLowerCase();
                                    return usersProfiles.where(
                                      (profile) {
                                        return profile.name
                                                .toLowerCase()
                                                .contains(
                                                  query.toLowerCase(),
                                                ) ||
                                            profile.email
                                                .toLowerCase()
                                                .contains(
                                                  query.toLowerCase(),
                                                );
                                      },
                                    ).toList(
                                      growable: false,
                                    )..sort(
                                        (a, b) => a.name
                                            .toLowerCase()
                                            .indexOf(
                                              lowercaseQuery,
                                            )
                                            .compareTo(
                                              b.name.toLowerCase().indexOf(
                                                    lowercaseQuery,
                                                  ),
                                            ),
                                      );
                                  }
                                  return usersProfiles;
                                },
                                onChanged: (data) {
                                  // print(data);
                                },
                                chipBuilder: (context, state, profile) {
                                  return InputChip(
                                    key: ObjectKey(profile),
                                    label: Text(profile.name),
                                    avatar:
                                        const Icon(Icons.account_box_rounded),
                                    onDeleted: () {
                                      state.deleteChip(
                                        profile,
                                      );
                                      newMems.remove(profile);
                                    },
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  );
                                },
                                suggestionBuilder: (context, state, profile) {
                                  return ListTile(
                                    key: ObjectKey(profile),
                                    leading: Icon(
                                      Icons.account_box_rounded,
                                    ),
                                    title: Text(profile.name),
                                    subtitle: Text(profile.email),
                                    onTap: () {
                                      state.selectSuggestion(
                                        profile,
                                      );
                                      newMems.add(profile);
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        } else if (snapshot2.hasError) {
                          return Text("Error Happened");
                        }

                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
              SizedBox(
                height: 200,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      String _taskName = taskNameCon.text;
                      String _taskNote = noteCon.text;
                      if (_taskName.isNotEmpty && _taskNote.isNotEmpty) {
                        bool res = await _api.addTask(
                          _project.url,
                          _taskName,
                          _taskNote,
                          selectedStartDate,
                          selectedEndDate,
                          newMems
                              .map(
                                (e) => e.url,
                              )
                              .toList(),
                        );
                        if (res) {
                          taskNameCon.clear();
                          noteCon.clear();
                          newMems = [];
                          setState(() {
                            selectedStartDate = DateTime.now();
                            selectedEndDate = DateTime.now();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              dismissDirection: DismissDirection.none,
                              backgroundColor: Colors.green,
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Added task successfully\n"
                                    "Redirecting to tasks Page",
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: CircularProgressIndicator(),
                                  ),
                                ],
                              ),
                            ),
                          );
                          await Future.delayed(
                            Duration(seconds: 4),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SingleProjectView(
                                project: _project,
                              ),
                            ),
                          );
                        }
                      } else if (_taskName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Enter the name of task"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text("Enter the note of task"),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Add task',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xff076792),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
