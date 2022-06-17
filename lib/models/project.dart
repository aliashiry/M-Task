// ignore_for_file: dead_null_aware_expression

import 'dart:convert';
import 'dart:core';

class Project {
  Project({
    required this.url,
    required this.id,
    required this.owner,
    required this.title,
    required this.created,
    required this.end,
    required this.tasks,
    required this.group,
  });

  final String url;
  final int id;
  final String owner;
  final String title;
  final DateTime created;
  final DateTime end;
  final List tasks;
  final String group;

  Project copyWith({
    required String url,
    required int id,
    required String owner,
    required String title,
    required DateTime created,
    required DateTime end,
    required List tasks,
    required String group,
  }) =>
      Project(
        url: url ?? this.url,
        id: id ?? this.id,
        owner: owner ?? this.owner,
        title: title ?? this.title,
        created: created ?? this.created,
        end: end ?? this.end,
        tasks: tasks ?? this.tasks,
        group: group ?? this.group,
      );

  factory Project.fromRawJson(String str) => Project.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        url: json["url"],
        id: json["id"],
        owner: json["owner"],
        title: json["title"],
        created: DateTime.parse(
          json["created"],
        ),
        end: DateTime.parse(
          json["end"],
        ),
        tasks: json["tasks"] ?? [],
        group: json["group"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "id": id,
        "owner": owner,
        "title": title,
        "created": created.toIso8601String(),
        "end": end.toIso8601String(),
        "tasks": tasks,
        "group": group,
      };
}
