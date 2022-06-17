import 'package:flutter/material.dart';
import 'package:project/models/project.dart';

import '../screens/AddMember.dart';

class NoGroupsWidget extends StatefulWidget {
  final Project project;
  const NoGroupsWidget({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<NoGroupsWidget> createState() => _NoGroupsWidgetState();
}

class _NoGroupsWidgetState extends State<NoGroupsWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: const Center(
            child: Text(
              "You Don't Have\n Any Members",
              style: TextStyle(
                color: Colors.black,
                fontSize: 25.0,
                shadows: [
                  Shadow(
                    color: Colors.grey,
                    offset: Offset(0.1, 0.1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 54,
          margin: const EdgeInsets.fromLTRB(75, 40, 75, 0),
          child: ElevatedButton(
            onPressed: () async {
              bool res = (await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddMember(
                    project: widget.project,
                    
                  ),
                ),
              ))!;
              res ? setState(() {}) : setState(() {});
            },
            child: const Text(
              'Add Members',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w400,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFF09679a),
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
      ],
    );
  }
}
