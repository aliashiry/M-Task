// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_constructors_in_immutables

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/models/user.dart';

import '../services/middleware.dart';
import '../services/sharedPrefs.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  ProfileScreen({
    required this.user,
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SharedPrefsUtils _prefs = SharedPrefsUtils.getInstance();
  final ApiService _api = ApiService();
  final TextEditingController _usernameCon = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String _uploading = "false";
  XFile? pickedFile;
  @override
  Widget build(BuildContext context) {
    var raw = _prefs.getData("profile_pic");
    Map<String, dynamic>? _url = raw == null ? null : jsonDecode(raw);

    ImageProvider returnImage() {
      if (_url != null) {
        return NetworkImage(
          _url["pic"],
        );
      } else {
        return AssetImage(
          "assets/images/image.png",
        );
      }
    }

    User user = widget.user;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff076792),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 30.0,
        ),
        title: const Text(
          'Profile',
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
      body: StreamBuilder<User>(
        stream: _api.fetchUserData().asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final User _user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(00.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40.0,
                        horizontal: 105.0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () async {
                                File? _image;
                                pickedFile = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                );

                                if (pickedFile != null) {
                                  _image = File(pickedFile!.path);
                                  var path = _image.path;
                                  var lastSeparator = path.lastIndexOf(
                                    Platform.pathSeparator,
                                  );
                                  var newPath = path.substring(
                                        0,
                                        lastSeparator + 1,
                                      ) +
                                      "${user.username}.png";
                                  _image = await _image.rename(newPath);
                                  setState(() {
                                    _uploading = "true";
                                  });
                                  if (_url != null) {
                                    await _api.updatePic(_image);
                                  } else {
                                    await _api.uploadPic(_image);
                                  }
                                  setState(
                                    () {
                                      _uploading = "done";
                                    },
                                  );
                                }
                              },
                              child: Container(
                                height: 150,
                                width: 150,
                                child: CircleAvatar(
                                  radius: 75,
                                  backgroundColor: Colors.black.withOpacity(
                                    0.35,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: returnImage(),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _uploading == "true"
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : _uploading == "done"
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Uploaded Successfully",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : Container(),
                    Center(
                      child: const Text(
                        'Change User Name',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xff076792),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: TextFormField(
                        controller: _usernameCon,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: _user.username,
                          hintStyle: TextStyle(
                            fontSize: 20,
                            color: Color(0xffc9c9c9),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Color(0xff076792),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Center(
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () async {
                              String newUsername = _usernameCon.text;
                              if (newUsername.isNotEmpty) {
                                bool res = await _api.updateUser(
                                  user.copyWith(
                                    url: user.url,
                                    id: user.id,
                                    firstName: user.firstName,
                                    lastName: user.lastName,
                                    username: newUsername,
                                    email: user.email,
                                    projects: user.projects,
                                    tasks: user.tasks,
                                  ),
                                );
                                if (res) {
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text("Updated successfully"),
                                    ),
                                  );
                                  setState(() {});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        "There're another user with this username\n"
                                        "Choose another one",
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text("Enter new username"),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(200, 100),
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(200, 100),
                              primary: const Color(0xff076792),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  30,
                                ),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error Happened"),
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
