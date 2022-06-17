// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:project/screens/home.dart';

import '../services/middleware.dart';

class ResetPassword extends StatefulWidget {
  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final ApiService _api = ApiService();
  final TextEditingController passCon = TextEditingController();
  final TextEditingController passConfirmCon = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff076792),
          title: const Text(
            'Reset Password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontFamily: 'flu',
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  color: Color(0xa6A2B6D4),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 25,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(43, 33, 43, 0),
                child: SizedBox(
                  height: 45,
                  child: TextFormField(
                    controller: passCon,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Enter New Password",
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
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(43, 33, 43, 0),
                child: SizedBox(
                  height: 45,
                  child: TextFormField(
                    controller: passConfirmCon,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Confirm New Password",
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
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                width: double.infinity,
                height: 60,
                margin: const EdgeInsets.fromLTRB(75, 0, 75, 20),
                child: ElevatedButton(
                  onPressed: () async {
                    String pass = passCon.text;
                    String passConfirm = passConfirmCon.text;
                    if (pass == passConfirm) {
                      bool res = await _api.resetPass(pass, passConfirm);
                      if (res) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              "Changed successfully",
                            ),
                          ),
                        );
                      }
                    } else if (pass != passConfirm &&
                        pass.isNotEmpty &&
                        passConfirm.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            "Password and its confirm don't match",
                          ),
                        ),
                      );
                    } else if (pass.isNotEmpty || passConfirm.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            "There're empty fields",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: const Color(0xff076792),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // f... flutter buttons!
                        side: const BorderSide(color: Colors.black, width: 1),
                      )),
                ),
              ),
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.fromLTRB(75, 0, 75, 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: const Color(0xff076792),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // f... flutter buttons!
                        side: const BorderSide(color: Colors.black, width: 1),
                      )),
                ),
              ),
            ],
          ),
        ));
  }
}
