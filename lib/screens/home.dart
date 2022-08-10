import 'package:flutter/material.dart';

import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import '../widgets/new_task.dart';
import '../widgets/task_list.dart';
import '../models/task.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String uid;

  @override
  void initState() {
    getUid();
    super.initState();
  }

  getUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    setState(() {
      uid = user.uid;
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

  _addTaskToFirebase(
      String taskText, DateTime dueDate, TimeOfDay dueTime) async {
    final newTask = Task(
      taskText: taskText,
      id: DateTime.now().toString(),
      dueDate: dueDate.toString(),
      dueTime: timeOfDayAsHhMm(dueTime),
    );

    FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    String uid = user.uid;
    FirebaseFirestore.instance
        .collection("tasks")
        .doc(uid)
        .collection("mytasks")
        .doc(newTask.id)
        .set(
      {
        "desc": taskText,
        "id": newTask.id,
        "isDone": newTask.isDone,
        "hasImage": newTask.hasImage,
        "dueDate": newTask.dueDate,
        "dueTime": newTask.dueTime,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bokBar = AppBar(
      elevation: 0,
      flexibleSpace: Expanded(
        child: Container(color: Colors.grey),
      ),
    );

    final appBar = AppBar(
      shadowColor: Colors.transparent,
      title: Text(
        'To-Do List',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Theme.of(context).primaryColor,
                Theme.of(context).scaffoldBackgroundColor,
              ]),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Change Theme Color'),
                        ),
                        Icon(Icons.brush, size: 15),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Log out',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        Icon(Icons.logout, size: 15),
                      ],
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.menu),
        )
      ],
    );

    final usableHeight = MediaQuery.of(context).size.height - //whole screen
        appBar.preferredSize.height - //appbar height
        MediaQuery.of(context).padding.top - //notification bar
        MediaQuery.of(context).viewInsets.bottom; //soft keyboard

    const double textBoxHeight = 68.0;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: appBar,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                height: usableHeight - textBoxHeight,
                child: TaskList(uid),
              ),
            ),
            //this container is used to add a fade effect on top of the list
            Container(
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    Colors.white.withOpacity(0),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: NewTask(_addTaskToFirebase),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}