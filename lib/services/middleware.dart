// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project/helpers/constants.dart';
import 'package:project/services/sharedPrefs.dart';

import '../models/project.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../models/group.dart';
import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart' as parser;

///* API Service for handling middleware
class ApiService {
  final SharedPrefsUtils _prefs = SharedPrefsUtils.getInstance();

  ///* Function made to login existing users
  Future<bool> loginUser(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse(kLoginUsers),
      body: {
        "username": username,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.

      String _token = jsonDecode(response.body)["key"];
      await _prefs.saveData("token", "Token $_token");
      return true;
    } else if (response.statusCode == 400) {
      return false;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(response.reasonPhrase);
      throw Exception('Failed to login user');
    }
  }

  ///* Function made to logout existing users
  Future<bool> logoutUser() async {
    String _token = _prefs.getData("token");
    final response = await http.post(
      Uri.parse(kLogoutUsers),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      await _prefs.clearData("token");
      return true;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(response.reasonPhrase);
      throw Exception('Failed to logout user');
    }
  }

  ///* Function made to fetch group members
  Future<List<User>> getGroupMembers(List members) async {
    List<String> _urls = members
        .map(
          (e) => e.toString(),
        )
        .toList();
    List<User> _list = [];
    try {
      for (String url in _urls) {
        User _singleUser = await fetchUser(url);
        _list.add(_singleUser);
      }

      print(_list.length);

      /// If the server did return a 200 OK response,
      /// then parse the JSON.

      return _list;
    } catch (e) {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(
        e.toString(),
      );
      throw Exception('Failed to get tasks');
    }
  }

  ///* Function made to fetch other tasks and their projects
  Future<Map<int, List<Object>>> getOtherTasks(int userID) async {
    String _token = _prefs.getData("token");

    final response = await http.get(
      Uri.parse(
        kOtherTasks + userID.toString(),
      ),
      headers: {
        "Authorization": _token,
      },
    );

    List<Project> _projects = [];

    if (response.statusCode == 200) {
      List<Task> _tasks = decodeTasksFromJSON(response.body);
      for (Task i in _tasks) {
        Project x = await fetchProject(i.project);
        _projects.add(x);
      }

      /// If the server did return a 200 OK response,
      /// then parse the JSON.

      return {
        0: _tasks,
        1: _projects,
      };
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(response.reasonPhrase);
      throw Exception('Failed to load other tasks');
    }
  }

  ///* Function made to fetch task members
  Future<List<User>> getTaskMembers(List members) async {
    List<String> _urls = members
        .map(
          (e) => e.toString(),
        )
        .toList();
    List<User> _list = [];
    try {
      for (String url in _urls) {
        User _singleUser = await fetchUser(url);
        _list.add(_singleUser);
      }

      print(_list.length);

      /// If the server did return a 200 OK response,
      /// then parse the JSON.

      return _list;
    } catch (e) {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(
        e.toString(),
      );
      throw Exception('Failed to get tasks');
    }
  }

  // ///* Function made to upload user's p.p
  // Future<String> uploadUserPic(File file, User user) async {
  //   var postUri = Uri.parse(kProfile);
  //   http.MultipartRequest request = http.MultipartRequest("POST", postUri);
  //   request.fields['user'] = 'blah';
  //   request.files.add(
  //     http.MultipartFile.fromBytes(
  //       'file',
  //       await File.fromUri(Uri.parse(file.path)).readAsBytes(),
  //       contentType: parser.MediaType('image', 'jpeg'),
  //     ),
  //   );

  //   request.send().then((response) {
  //     if (response.statusCode == 200) print("Uploaded!");
  //   });
  // }

  // ///* Function made to delete user's p.p
  // Future<bool> deleteUserPic(String url) async {
  //   final cloudinary = Cloudinary.basic(
  //     cloudName: "esoorappdb",
  //   );
  //   final response = await cloudinary.deleteResource(
  //     url: url,
  //     resourceType: CloudinaryResourceType.image,
  //     invalidate: false,
  //   );
  //   if (response.isSuccessful) {
  //     return true;
  //   } else {
  //     throw Exception("We cam't delete the pic");
  //   }
  // }

  ///* Function made to fetch tasks
  Future<List<Task>> getTasks(List tasks) async {
    List<String> _urls = tasks
        .map(
          (e) => e.toString(),
        )
        .toList();
    List<Task> _list = [];
    try {
      for (String url in _urls) {
        Task _singleTask = await fetchTask(url);
        _list.add(_singleTask);
      }

      print(_list.length);

      /// If the server did return a 200 OK response,
      /// then parse the JSON.

      return _list;
    } catch (e) {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(
        e.toString(),
      );
      throw Exception('Failed to get tasks');
    }
  }

  ///* Function made to fetch users
  Future<List<User>> getUsers() async {
    String _token = _prefs.getData("token");

    final response = await http.get(
      Uri.parse(kUsersUrl),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      return decodeUsersFromJSON(response.body);
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load types');
    }
  }

  ///* Function made to create Task
  Future<bool> addTask(
    String project,
    String title,
    String desc,
    DateTime startDate,
    DateTime endDate,
    List<String> members,
  ) async {
    String _token = _prefs.getData("token");
    final response = await http.post(
      Uri.parse(kTasksUrl),
      body: jsonEncode(
        {
          "project": project,
          "title": title,
          "start": startDate.toIso8601String(),
          "end": endDate.toIso8601String(),
          "desc": desc,
          "status": "todo",
          "members": members,
        },
      ),
      headers: {
        "Authorization": _token,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 201) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.

      return true;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(response.reasonPhrase);
      throw Exception('Failed to add task');
    }
  }

  ///* Function made to create projects
  Future<bool> createProject(String name, DateTime endDate) async {
    String _token = _prefs.getData("token");
    final response = await http.post(
      Uri.parse(kProjectsUrl),
      body: {
        "title": name,
        "group": "",
        "end": endDate.toIso8601String(),
      },
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 201) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      await createGroup(
        "title",
        List<String>.empty(),
        Project.fromRawJson(response.body),
      );

      return true;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(response.reasonPhrase);
      throw Exception('Failed to create project');
    }
  }

  ///* Function made to delete projects
  Future<bool> deleteProject(Project project) async {
    String _token = _prefs.getData("token");
    final response = await http.delete(
      Uri.parse(project.url),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 204) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.

      return true;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(response.reasonPhrase);
      throw Exception('Failed to delete project');
    }
  }

  ///* Function made to delete tasks
  Future<bool> deleteTask(Task task) async {
    String _token = _prefs.getData("token");
    final response = await http.delete(
      Uri.parse(task.url),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 204) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.

      return true;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(response.reasonPhrase);
      throw Exception('Failed to delete task');
    }
  }

  ///* Function made to delete groups
  Future<bool> deleteGroup(Group group) async {
    String _token = _prefs.getData("token");
    final response = await http.delete(
      Uri.parse(group.url),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 204) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.

      return true;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(response.reasonPhrase);
      throw Exception('Failed to delete group');
    }
  }

  ///* Function made to delete users
  Future<bool> deleteUser(User user) async {
    String _token = _prefs.getData("token");
    final response = await http.delete(
      Uri.parse(user.url),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 204) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.

      return true;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(response.reasonPhrase);
      throw Exception('Failed to delete user');
    }
  }

  ///* Function made to reset user's password
  Future<bool> resetPass(
    String pass,
    String passConfirm,
  ) async {
    String _token = _prefs.getData("token");

    final response = await http.post(
      Uri.parse(kResetPass),
      headers: {
        "Authorization": _token,
      },
      body: {
        "new_password1": pass,
        "new_password2": passConfirm,
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      return true;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      print(response.reasonPhrase);
      throw Exception('Failed to reset pass');
    }
  }

  ///* Function made to sign new users up
  Future<User> signupUser(
    String username,
    String firstName,
    String lastName,
    String password,
    String email,
  ) async {
    final response = await http.post(
      Uri.parse(kUsersUrl),
      body: {
        "username": username,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
        "email": email
      },
    );

    if (response.statusCode == 201) {
      /// If the server did return a 201 Created response,
      /// then parse the JSON.
      return User.fromRawJson(response.body);
    } else {
      /// If the server did not return a 201 Created response,
      /// then throw an exception.
      throw Exception('Failed to signup user');
    }
  }

  ///* Function made to retrieve logged user's data
  Future<User> fetchUserData() async {
    String _token = _prefs.getData("token");

    final response = await http.get(
      Uri.parse(kUserData),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      final User _user = await fetchUser(
        kUsersUrl + jsonDecode(response.body)["pk"].toString(),
      );
      return _user;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception("Failed to load user's data");
    }
  }

  ///* Function made to leave task
  Future<void> leaveTask(
    BuildContext context,
    Project project,
    Task task,
  ) async {
    User current = await fetchUserData();
    List<String> members = task.members.cast<String>();
    List<String> userTasks = current.tasks.cast<String>();

    if (members.contains(current.url)) {
      members.remove(current.url);
      userTasks.remove(task.url);
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
        status: task.status,
        members: members,
      );
      User user = current.copyWith(
        url: current.url,
        id: current.id,
        firstName: current.firstName,
        lastName: current.lastName,
        username: current.username,
        email: current.email,
        projects: current.projects,
        tasks: userTasks,
      );
      bool res1 = await updateTask(_task);
      bool res2 = await updateUser(user);
      if (res1 && res2) {
        /// If the server did return a 200 OK response,
        /// then parse the JSON.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Left task successfully"),
          ),
        );
      } else {
        /// If the server did not return a 200 OK response,
        /// then throw an exception.
        throw Exception('Failed to leave task');
      }
    }
  }

  ///* Function made to retrieve one task per url
  Future<Task> fetchTask(String url) async {
    String _token = _prefs.getData("token");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      return Task.fromRawJson(response.body);
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load task');
    }
  }

  ///* Function made to retrieve one project per url
  Future<Project> fetchProject(String url) async {
    String _token = _prefs.getData("token");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      return Project.fromRawJson(response.body);
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load project');
    }
  }

  ///* Function made to retrieve one user per url
  Future<User> fetchUser(String url) async {
    String _token = _prefs.getData("token");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      return User.fromRawJson(response.body);
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load types');
    }
  }

  ///* Function made to update user
  Future<bool> updateUser(User user) async {
    String _token = _prefs.getData("token");

    final response = await http.patch(
      Uri.parse(
        user.url,
      ),
      body: user.toJsonMod(),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      return true;
    } else if (response.statusCode == 400) {
      return false;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load types');
    }
  }

  ///* Function made to update project
  Future<bool> updateProject(Project project) async {
    String _token = _prefs.getData("token");

    final response = await http.patch(
      Uri.parse(
        project.url,
      ),
      body: jsonEncode(
        project.toJson(),
      ),
      headers: {
        "Authorization": _token,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      return true;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load types');
    }
  }

  ///* Function made to update group
  Future<bool> updateGroup(Group group) async {
    String _token = _prefs.getData("token");

    final response = await http.patch(
      Uri.parse(
        group.url,
      ),
      body: jsonEncode(
        group.toJson(),
      ),
      headers: {
        "Authorization": _token,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      return true;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load types');
    }
  }

  ///* Function made to update task
  Future<bool> updateTask(Task task) async {
    String _token = _prefs.getData("token");

    final response = await http.patch(
      Uri.parse(
        task.url,
      ),
      body: jsonEncode(task.toJson()),
      headers: {
        "Authorization": _token,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      return true;
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load types');
    }
  }

  ///* Function made to retrieve one group per url
  Future<Group> fetchGroup(String url) async {
    String _token = _prefs.getData("token");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": _token,
      },
    );

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      return Group.fromRawJson(response.body);
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load types');
    }
  }

  ///* Function made to create groups
  Future<Group> createGroup(
    String title,
    List<String> members,
    Project project,
  ) async {
    String _token = _prefs.getData("token");

    final response = await http.post(
      Uri.parse(kGroupsUrl),
      body: jsonEncode(
        {
          "title": title,
          "member": members,
          "active": true.toString(),
        },
      ),
      headers: {
        "Authorization": _token,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 201) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      Group group = Group.fromRawJson(response.body);
      bool updated = await updateProject(
        project.copyWith(
          end: project.end,
          url: project.url,
          id: project.id,
          owner: project.owner,
          title: project.title,
          created: project.created,
          tasks: project.tasks,
          group: group.url,
        ),
      );
      if (updated) {
        return group;
      } else {
        throw Exception("Failed to update");
      }
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load types');
    }
  }

  ///* Function made to upload profile pic
  Future<String> uploadPic(
    File img,
  ) async {
    String _token = _prefs.getData("token");
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(kProfile),
    );

    request.files.add(
      await http.MultipartFile.fromPath('pic', img.path),
    );
    request.headers.addAll(
      {
        "Authorization": _token,
        "Content-Type": "application/json",
      },
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      Map<String, dynamic> data = jsonDecode(
        await response.stream.bytesToString(),
      );
      await _prefs.saveData("profile_pic", jsonEncode(data));
      return data["url"];
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load types');
    }
  }

  ///* Function made to update profile pic
  Future<String> updatePic(
    File img,
  ) async {
    String _token = _prefs.getData("token");
    String _url = jsonDecode(
      _prefs.getData("profile_pic"),
    )["url"];
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse(_url),
    );

    request.files.add(
      await http.MultipartFile.fromPath('pic', img.path),
    );
    request.headers.addAll(
      {
        "Authorization": _token,
        "Content-Type": "application/json",
      },
    );

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      /// If the server did return a 200 OK response,
      /// then parse the JSON.
      Map<String, dynamic> data = jsonDecode(
        await response.stream.bytesToString(),
      );
      await _prefs.saveData("profile_pic", jsonEncode(data));
      return data["url"];
    } else {
      /// If the server did not return a 200 OK response,
      /// then throw an exception.
      throw Exception('Failed to load types');
    }
  }
}
