import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_firebase/widgets/task_options.dart';

import '../screens/home.dart';

class TaskList extends StatefulWidget {
  final String uid;
  var myStream;
  TaskList(this.myStream, this.uid, {Key key}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  void initState() {
    widget.myStream = FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.uid)
        .collection('mytasks')
        .orderBy('dueDate')
        .orderBy('dueTime')
        .snapshots();

    super.initState();
  }

// TODO: Update this to actually add an image too
  void _updateHasImage(currTask) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.uid)
        .collection('mytasks')
        .doc(currTask['id'])
        .update({
      'hasImage': !currTask['hasImage'],
    });
  }

  String timeOfDayAsHhMm(TimeOfDay tod) {
    try {
      String timeAsString = tod.format(context);
      int hour = int.parse(timeAsString.split(':')[0]);
      String minute = timeAsString.split(':')[1].split(' ')[0];

      bool isPM = timeAsString.substring(
              timeAsString.length - 2, timeAsString.length) ==
          'PM';
      if (!isPM && hour == 12) {
        return '00:' + minute;
      }
      if (isPM && hour != 12) {
        hour += 12;
      }
      return (hour < 10 ? '0' : '') + '${hour}:' + minute;
    } catch (e) {
      return '';
    }
  }

  void _updateTaskDesc(
      dynamic currTask, String newDesc, DateTime newDate, TimeOfDay newTime) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.uid)
        .collection('mytasks')
        .doc(currTask['id'])
        .update(
      {
        'desc': newDesc,
        'dueDate': newDate.toString(),
        'dueTime': timeOfDayAsHhMm(newTime),
      },
    );
  }

  bool isFuture(String date) {
    return date == "2200-01-01 00:00:00.000Z";
  }

  Widget dismissedToast(String msg, dynamic currTask) {
    if (msg.length > 20) {
      msg = msg.substring(0, 18) + "...";
    }
    msg += ' dismissed';
    return Padding(
      padding: const EdgeInsets.only(bottom: 75.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).primaryColorLight.withAlpha(200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection("tasks")
                    .doc(widget.uid)
                    .collection("mytasks")
                    .doc(currTask['id'])
                    .set(
                  {
                    "desc": currTask['desc'],
                    "id": currTask['id'],
                    "isDone": currTask['isDone'],
                    "hasImage": currTask['hasImage'],
                    "dueDate": currTask['dueDate'],
                    "dueTime": currTask['dueTime'],
                  },
                );
              },
              child: Text(
                "Undo",
              ),
            ),
            Text(msg),
          ],
        ),
      ),
    );
  }

  void showDismissedToast(String msg, dynamic currTask) {
    FToast().init(context);
    FToast().removeQueuedCustomToasts();
    FToast().showToast(
        toastDuration: Duration(seconds: 2, milliseconds: 500),
        child: dismissedToast(msg, currTask),
        gravity: ToastGravity.SNACKBAR);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.myStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
                height: 100, width: 100, child: CircularProgressIndicator()),
          );
        } else if (snapshot.data.size == 0) {
          return LayoutBuilder(
            builder: ((context, raints) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: raints.maxHeight * 0.4,
                      child: Image.asset(
                        'assets/images/empty-list.png',
                        colorBlendMode: BlendMode.modulate,
                        color: Theme.of(context).primaryColorLight,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      'No tasks!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: raints.maxHeight * 0.07),
                    ),
                    SizedBox(
                      width: 300,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'You have no tasks at this moment. Type below and press ',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            WidgetSpan(
                              child: Icon(
                                Icons.add,
                                size: 17,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                            TextSpan(
                                text: ' to add your first task.',
                                style: TextStyle(color: Colors.black))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        } else {
          final docs = snapshot.data.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              final currTask = docs[index];
              //similar to GestureDetector, has splash effects
              return InkWell(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                highlightColor: Theme.of(context).secondaryHeaderColor,
                splashColor: Theme.of(context).secondaryHeaderColor,
                onLongPress: () {
                  showModalBottomSheet<dynamic>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                    ),
                    isScrollControlled: true,
                    context: context,
                    builder: (bCtx) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      return TaskOptions(
                          _updateTaskDesc, _updateHasImage, currTask);
                    },
                  );
                },
                child: Dismissible(
                  direction: DismissDirection.startToEnd,
                  key: UniqueKey(),
                  onDismissed: (_) async {
                    FirebaseFirestore.instance
                        .collection('tasks')
                        .doc(widget.uid)
                        .collection('mytasks')
                        .doc(currTask['id'])
                        .delete();

                    showDismissedToast(currTask['desc'], currTask);
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: VisualDensity(vertical: -4),
                    leading: IconButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('tasks')
                            .doc(widget.uid)
                            .collection('mytasks')
                            .doc(currTask['id'])
                            .update({
                          'isDone': !currTask['isDone'],
                        });
                      },
                      icon: !currTask['isDone']
                          ? Icon(Icons.circle_outlined)
                          : Icon(Icons.check_circle),
                      color: !currTask['isDone']
                          ? Colors.grey
                          : Theme.of(context).primaryColorDark,
                    ),
                    title: Text(
                      currTask['desc'],
                      style: !currTask['isDone']
                          ? null
                          : TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey),
                    ),
                    subtitle: !isFuture(currTask['dueDate'])
                        ? Row(
                            children: [
                              Text(
                                  'Due ${DateFormat('dd/MM').format(DateTime.parse(currTask['dueDate']))} - '),
                              Text('${currTask['dueTime']}')
                            ],
                          )
                        : null,
                    trailing: currTask['hasImage']
                        ? IconButton(
                            onPressed: () =>
                                null, //* Will be used for displayImage
                            icon: Icon(Icons.image_outlined),
                            color: Theme.of(context).primaryColorDark,
                            splashRadius: 20,
                          )
                        : IconButton(
                            onPressed: null,
                            icon: Icon(null),
                          ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
