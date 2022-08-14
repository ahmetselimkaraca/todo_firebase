import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewTask extends StatefulWidget {
  final Function addToFirestore;

  NewTask(this.addToFirestore, {Key key}) : super(key: key);

  @override
  State<NewTask> createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  final textController = TextEditingController();
  final myFocusNode = FocusNode();

  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  File _selectedImage;

  bool isFuture(String date) {
    return date == '2200-01-01 00:00:00.000Z';
  }

  selectImageFromGallery() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _selectedImage = File(imageFile.path);
      });
    }
  }

  Future<String> uploadImage(File image) async {
    String imageURL;
    String imageId = DateTime.now().microsecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance.ref().child('images/$imageId');
    try {
      await ref.putFile(_selectedImage);
      imageURL = await ref.getDownloadURL();
      return imageURL;
    } catch (e) {
      return "";
    }
  }

  void _dateAndTimePicker() {
    showDatePicker(
      context: context,
      //if the task has no date, set initial date to now. If it does, set it to that date
      initialDate:
          isFuture(_selectedDate.toString()) ? DateTime.now() : _selectedDate,
      //if the task has no date, set first available date to now. If it does, check if the selected date has passed.
      firstDate: isFuture(_selectedDate.toString())
          ? DateTime.now()
          : _selectedDate.compareTo(DateTime.now()) <= 0
              // if the selected date has passed, set first available date to selected date. If not, set it to now.
              ? _selectedDate
              : DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 731)),
    ).then(
      (dateValue) {
        // If date picking isn't cancelled...
        if (dateValue != null) {
          // set the picked date to the date of the task.
          setState(() => _selectedDate = dateValue);
          showTimePicker(
            context: context,
            initialTime: _selectedTime != null
                ? _selectedTime
                : TimeOfDay(hour: 12, minute: 00),
          ).then(
            (timeValue) {
              if (timeValue != null) {
                setState(
                  () {
                    _selectedTime = timeValue;
                  },
                );
              }
              // if the task has no initial time, set the initial date to null
              if (_selectedTime == null) {
                setState(
                  () {
                    _selectedDate = null;
                  },
                );
              }
            },
          );
        }
      },
    );
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

  void submit() {
    if (textController.text.isEmpty) {
      return;
    }
    widget.addToFirestore(textController.text, _selectedDate, _selectedTime,
        uploadImage(_selectedImage));
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedDate == null) {
      _selectedTime == null;
      _selectedDate = DateTime.utc(2200, 1, 1);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 15,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.white.withOpacity(0),
                  Theme.of(context).scaffoldBackgroundColor,
                ]),
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: SizedBox(
                height: 50,
                child: Card(
                  color: Colors.white.withOpacity(0.85),
                  elevation: 5,
                  shadowColor: Theme.of(context).primaryColorDark,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onTap: () => myFocusNode.requestFocus(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: 'Enter task',
                            contentPadding: EdgeInsets.all(15),
                            border: InputBorder.none,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          controller: textController,
                          focusNode: myFocusNode,
                          onSubmitted: (_) {
                            submit();
                            myFocusNode.requestFocus();
                            textController.clear();
                          },
                        ),
                      ),
                      if (!isFuture(_selectedDate.toString()))
                        Row(
                          children: [
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: FittedBox(
                                child: IconButton(
                                  splashRadius: 15,
                                  onPressed: () => setState(() {
                                    _selectedDate = null;
                                    _selectedTime = null;
                                  }),
                                  icon: Icon(Icons.close),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              child: FittedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('dd/MM').format(_selectedDate),
                                    ),
                                    Text(timeOfDayAsHhMm(_selectedTime)),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      IconButton(
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: _dateAndTimePicker,
                        icon: isFuture(_selectedDate.toString())
                            ? const Icon(Icons.calendar_month)
                            : const Icon(Icons.edit_calendar),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      if (_selectedImage != null)
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: FittedBox(
                            child: IconButton(
                              splashRadius: 15,
                              onPressed: () => setState(() {
                                _selectedImage = null;
                              }),
                              icon: Icon(Icons.close),
                            ),
                          ),
                        ),
                      IconButton(
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () => selectImageFromGallery(),
                        icon: _selectedImage == null
                            ? const Icon(Icons.image_outlined)
                            : const Icon(Icons.image),
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Stack(
              children: [
                Positioned(
                  top: 3,
                  child: Container(
                    margin: EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 23,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).primaryColorDark,
                              Theme.of(context).primaryColorLight,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(3),
                  child: CircleAvatar(
                    radius: 23,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: IconButton(
                          onPressed: () {
                            submit();
                            myFocusNode.requestFocus();
                            textController.clear();
                            setState(() {
                              _selectedDate = null;
                              _selectedTime = null;
                              _selectedImage = null;
                            });
                          },
                          icon: Icon(Icons.add, color: Colors.white),
                          splashRadius: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
      ],
    );
  }
}
