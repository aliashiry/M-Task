// ignore_for_file: dead_null_aware_expression

import 'dart:convert';
import 'dart:core';

class Task {
  Task({
    required this.url,
    required this.projectId,
    required this.id,
    required this.owner,
    required this.project,
    required this.title,
    required this.start,
    required this.end,
    required this.desc,
    required this.status,
    required this.members,
    required this.complete,
  });

  final String url;
  final int projectId;
  final int id;
  final String owner;
  final String project;
  final String title;
  final DateTime start;
  final DateTime end;
  final String desc;
  final String status;
  final List members;
  final bool complete;

  Task copyWith({
    required String url,
    required int projectId,
    required int id,
    required String owner,
    required String project,
    required String title,
    required DateTime start,
    required DateTime end,
    required String desc,
    required String status,
    required List members,
    required bool complete,
  }) =>
      Task(
        url: url ?? this.url,
        projectId: projectId ?? this.projectId,
        id: id ?? this.id,
        owner: owner ?? this.owner,
        project: project ?? this.project,
        title: title ?? this.title,
        start: start ?? this.start,
        end: end ?? this.end,
        desc: desc ?? this.desc,
        status: status ?? this.status,
        members: members ?? this.members,
        complete: complete ?? this.complete,
      );

  factory Task.fromRawJson(String str) => Task.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        url: json["url"],
        projectId: json["project_id"],
        id: json["id"],
        owner: json["owner"],
        project: json["project"],
        title: json["title"],
        start: DateTime.parse(
          json["start"],
        ),
        end: DateTime.parse(
          json["end"],
        ),
        desc: json["desc"],
        status: json["status"],
        members: json["members"],
        complete: json["complete"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "project_id": projectId.toString(),
        "id": id.toString(),
        "owner": owner,
        "project": project,
        "title": title,
        "start": start.toIso8601String(),
        "end": end.toIso8601String(),
        "desc": desc,
        "members": members,
        "status": status,
        "complete": complete,
      };
}

List<Task> decodeTasksFromJSON(String data) => List<Task>.from(
      json.decode(data)["results"].map(
            (task) => Task.fromJson(
              task,
            ),
          ),
    );
