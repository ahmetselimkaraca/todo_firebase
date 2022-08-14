import 'dart:io';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditTask extends StatefulWidget {
  final dynamic currTask;
  final Function submitEdit;
  const EditTask(this.currTask, this.submitEdit, {Key key}) : super(key: key);

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final _titleController = TextEditingController();
  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  File _selectedImage;
  String _imageURL;
  final myFocusNode = FocusNode();

  void initState() {
    _titleController.text = widget.currTask['desc'];
    _selectedDate = DateTime.parse(widget.currTask['dueDate']);
    try {
      _selectedTime = TimeOfDay(
          hour: int.parse(widget.currTask['dueTime'].split(':')[0]),
          minute: int.parse(widget.currTask['dueTime'].split(':')[1]));
    } catch (e) {}
    _imageURL = widget.currTask['imageURL'];
    super.initState();
  }

  void submitData() {
    final enteredTitle = _titleController.text;
    if (enteredTitle.isEmpty) {
      return;
    }
    widget.submitEdit(widget.currTask, _titleController.text, _selectedDate,
        _selectedTime, uploadImage(_selectedImage));
    Navigator.of(context).pop();
  }

  bool isFuture(String date) {
    return date == "2200-01-01 00:00:00.000Z";
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
      if (_imageURL != "") {
        return _imageURL;
      } else {
        return "";
      }
    }
  }

  void _dateAndTimePicker() {
    /* 
    The point of the conditions in initialDate and firstDate are as follows.
    I'm choosing to set the initialDate to whichever date is picked for the task, so
    if the due date of a task has passed and the user wants to change it, I need to 
    make sure that the first available date on the calendar is the date of the task.
    But I can't simply set firstDate to the date that was selected before, because
    if the due date hasn't passed, then it would not be possible to set the due date
    to a time between now and the next 2 years. The conditions ensure that these are
    possible. 
    */

    /*
    I also wanted to make sure that it is not possible to pick a date without picking
    a time and vice versa. Pressing cancel on either of the date and time pickers sets
    the selected value to null, so there are some conditions to setting the date and time.
    */
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

  @override
  Widget build(BuildContext context) {
    //when 'CANCEL' is pressed on DatePicker, the date is set to null, this is to prevent that
    if (_selectedDate == null) {
      _selectedTime == null;
      _selectedDate = DateTime.utc(2200, 1, 1);
    }

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: (MediaQuery.of(context).viewInsets.bottom) + 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_imageURL != "" || _selectedImage != null)
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    child: _selectedImage != null
                        ? null
                        : Image.network(
                            widget.currTask['imageURL'],
                            fit: BoxFit.cover,
                          ),
                    decoration: _selectedImage != null
                        ? BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(_selectedImage),
                                fit: BoxFit.cover))
                        : null,
                  ),
                  SizedBox(
                    height: 201,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: double.infinity,
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
                        Container(
                          width: double.infinity,
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.white.withOpacity(0),
                                Theme.of(context).scaffoldBackgroundColor,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Positioned(
                              top: 3,
                              child: Container(
                                margin: EdgeInsets.all(3),
                                child: CircleAvatar(
                                  radius: 15,
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
                                radius: 15,
                                backgroundColor: Colors.white.withOpacity(0.5),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      onPressed: () {
                                        selectImageFromGallery();
                                      },
                                      icon:
                                          Icon(Icons.edit, color: Colors.white),
                                      splashRadius: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Positioned(
                              top: 3,
                              child: Container(
                                margin: EdgeInsets.all(3),
                                child: CircleAvatar(
                                  radius: 15,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.red.shade900,
                                          Colors.red,
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
                                radius: 15,
                                backgroundColor: Colors.white.withOpacity(0.5),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      onPressed: () {
                                        setState(() {
                                          _imageURL = "";
                                          _selectedImage = null;
                                        });
                                      },
                                      icon: Icon(Icons.clear,
                                          color: Colors.white),
                                      splashRadius: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            if (_imageURL == "" && _selectedImage == null)
              TextButton(
                  onPressed: () => selectImageFromGallery(),
                  child: Text('Attach Image')),
            TextField(
              focusNode: myFocusNode,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              controller: _titleController,
              onSubmitted: (_) => submitData(),
            ),
            Container(
              height: 60,
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: Row(
                      children: [
                        Text(
                          isFuture(_selectedDate.toString())
                              ? 'No Date'
                              : DateFormat('dd/MM').format(_selectedDate),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(_selectedTime == null
                            ? 'No Time'
                            : _selectedTime.format(context)),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          splashRadius: 20,
                          icon: Icon(Icons.edit_calendar_rounded),
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus;
                            _dateAndTimePicker();
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          splashRadius: 20,
                          icon: Icon(Icons.chair_outlined),
                          color: Colors.red,
                          onPressed: () {
                            setState(() {
                              _selectedDate = null;
                              _selectedTime = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    child: Text(
                      'Confirm',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: submitData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
