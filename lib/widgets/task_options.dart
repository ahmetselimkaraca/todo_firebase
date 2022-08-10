import 'package:flutter/material.dart';
import 'package:todo_firebase/widgets/edit_task.dart';
import './edit_task.dart';

class TaskOptions extends StatelessWidget {
  final dynamic currTask;
  final Function updateHasImage;
  final Function updateTaskDesc;

  const TaskOptions(this.updateTaskDesc, this.updateHasImage, this.currTask,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showModalBottomSheet(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                ),
                context: context,
                builder: (bCtx) {
                  return EditTask(currTask, updateTaskDesc);
                });
          },
          child: const Text('Edit Task'),
        ),
        TextButton(
          style: currTask['hasImage']
              ? TextButton.styleFrom(primary: Colors.red)
              : null,
          onPressed: () {
            updateHasImage(currTask);
            Navigator.pop(context);
          },
          child: currTask['hasImage']
              ? const Text('Remove Image')
              : const Text('Attach Image'),
        )
      ],
    );
  }
}
