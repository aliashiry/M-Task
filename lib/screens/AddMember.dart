// ignore_for_file: file_names, prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:project/models/project.dart';
import 'package:project/models/user.dart';
import 'package:project/screens/members_view.dart';
import 'package:project/services/middleware.dart';

import '../models/group.dart';

class AddMember extends StatefulWidget {
  final Project project;
  final List<User>? members;
  final Group? group;
  final User? current;
  AddMember({
    Key? key,
    required this.project,
    this.members,
    this.group,
    this.current,
  }) : super(key: key);

  @override
  _AddMemberState createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final _chipKey = GlobalKey<ChipsInputState>();
  final ApiService _api = ApiService();
  final TextEditingController nameCon = TextEditingController();
  List<AppProfile> newMems = [];
  @override
  Widget build(BuildContext context) {
    final Project project = widget.project;
    final Group? group = widget.group;
    final User? current = widget.current;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff076792),
        title: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            group != null ? "Edit members" : 'Add Members',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25.0,
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
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: FutureBuilder<List<User>>(
        future: _api.getUsers(),
        builder: (context, snapshot) {
          final List<User>? members = widget.members;
          if (group != null) nameCon.text = group.title;
          if (snapshot.hasData) {
            final List<User> users = snapshot.data!;
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
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: height * 0.2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: nameCon,
                          decoration: const InputDecoration(
                            hintText: "Enter group Name",
                            hintStyle: TextStyle(
                              fontSize: 20,
                              color: Color(0xffc9c9c9),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: Color(0xFF09679a),
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.name,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      child: ChipsInput<AppProfile>(
                        initialValue: members != null
                            ? members
                                .map(
                                  (e) => AppProfile(
                                    e.firstName + " " + e.lastName,
                                    e.username,
                                    e.url,
                                  ),
                                )
                                .toList()
                            : [],
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
                                return profile.name.toLowerCase().contains(
                                          query.toLowerCase(),
                                        ) ||
                                    profile.email.toLowerCase().contains(
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
                          newMems = data;
                        },
                        chipBuilder: (context, state, profile) {
                          return InputChip(
                            key: ObjectKey(profile),
                            label: Text(profile.name),
                            avatar: const Icon(Icons.account_box_rounded),
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
                    ElevatedButton(
                      onPressed: () async {
                        String title = nameCon.text;

                        if (title.isNotEmpty && group == null) {
                          Group group = await _api.createGroup(
                            title,
                            newMems
                                .map(
                                  (e) => e.url,
                                )
                                .toList(),
                            project,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              dismissDirection: DismissDirection.none,
                              backgroundColor: Colors.green,
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Added successfully\n"
                                    "Redirecting to Members Page",
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MembersView(
                                project: project.copyWith(
                                  end: project.end,
                                  url: project.url,
                                  id: project.id,
                                  owner: project.owner,
                                  title: project.title,
                                  created: project.created,
                                  tasks: project.tasks,
                                  group: group.url,
                                ),
                                group: group,
                                current: current,
                              ),
                            ),
                          );
                        } else if (group != null) {
                          Group updated = group.copyWith(
                            url: group.url,
                            title: title,
                            owner: group.owner,
                            members: newMems
                                .map(
                                  (e) => e.url,
                                )
                                .toList(),
                            created: group.created,
                            active: group.active,
                          );
                          bool res = await _api.updateGroup(updated);
                          if (res) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                dismissDirection: DismissDirection.none,
                                backgroundColor: Colors.green,
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "Updated successfully\n"
                                      "Redirecting to Members Page",
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
                                builder: (_) => MembersView(
                                  project: project.copyWith(
                                    end:project.end,
                                    url: project.url,
                                    id: project.id,
                                    owner: project.owner,
                                    title: project.title,
                                    created: project.created,
                                    tasks: project.tasks,
                                    group: group.url,
                                  ),
                                  group: updated,
                                  current: current,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text("Error Happened"),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text("Enter Group name"),
                            ),
                          );
                        }
                      },
                      child: Text(group != null ? "Update" : "Add"),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("Error Happened");
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class AppProfile {
  final String name;
  final String email;
  final String url;
  //final String imageUrl;

  const AppProfile(
    this.name,
    this.email,
    this.url,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppProfile &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }
}
