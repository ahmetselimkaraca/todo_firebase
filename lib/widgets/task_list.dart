import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_firebase/widgets/task_options.dart';

import '../screens/home.dart';

class TaskList extends StatefulWidget {
  final String uid;
  TaskList(this.uid, {Key key}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  var myStream;
  @override
  void initState() {
    myStream = FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.uid)
        .collection('mytasks')
        .snapshots();

    super.initState();
  }

// ignore: todo
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

  bool isEpoch(String date) {
    return date == "1970-01-01 00:00:00.000Z";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
                height: 100, width: 100, child: CircularProgressIndicator()),
          );
        } else if (snapshot.data.size == 0) {
          return LayoutBuilder(
            builder: ((context, constraints) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * 0.4,
                      child: Image.asset(
                        'assets/images/empty-list.png',
                        colorBlendMode: BlendMode.overlay,
                        color: Theme.of(context).primaryColor,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      'No tasks!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: constraints.maxHeight * 0.07),
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
                                Icons.post_add,
                                size: 17,
                                color: Theme.of(context).primaryColor,
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

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${currTask['desc']} dismissed"),
                        action: SnackBarAction(
                          label: 'Undo',
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
                        ),
                      ),
                    );
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
                          ? const Icon(Icons.circle_outlined)
                          : const Icon(Icons.check_circle),
                      color: !currTask['isDone']
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      currTask['desc'],
                      style: !currTask['isDone']
                          ? null
                          : const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey),
                    ),
                    subtitle: !isEpoch(currTask['dueDate'])
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
                            icon: const Icon(Icons.image_outlined),
                            color: Theme.of(context).colorScheme.secondary,
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
