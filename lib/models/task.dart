import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Task {
  final String taskText;
  final String id;
  String dueDate = DateTime.utc(1970, 1, 1).toString();
  String dueTime = '';
  bool isDone;
  bool hasImage;

  Task(
      {@required this.taskText,
      @required this.id,
      this.isDone = false,
      this.hasImage = false,
      this.dueDate,
      this.dueTime});
}
