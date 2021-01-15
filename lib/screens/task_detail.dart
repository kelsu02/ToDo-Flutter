import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../utils/db_helper.dart';

class TaskDetail extends StatefulWidget {
  final String appBarTitle;
  final Task task;

  TaskDetail(this.task, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return TaskDetailState(this.task, this.appBarTitle);
  }
}

class TaskDetailState extends State<TaskDetail> {
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();
  String appBarTitle;
  Task task;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TaskDetailState(this.task, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    titleController.text = task.title;
    descriptionController.text = task.description;
    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToLastScreen();
              }),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    style: textStyle,
                    value: getPriorityAsString(task.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        debugPrint('User selected $valueSelectedByUser');
                        updatePriorityAsInt(valueSelectedByUser);
                      });
                    }),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Title Text Field');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Description Text Field');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("Save button clicked");
                            _save();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 5.0,
                    ),
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("Delete button clicked");
                            _delete();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        task.priority = 1;
        break;
      case 'Low':
        task.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateDescription() {
    task.description = descriptionController.text;
  }

  void updateTitle() {
    task.title = titleController.text;
  }

  void _save() async {
    moveToLastScreen();
    task.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (task.id != null) {
      result = await helper.updateTask(task);
    } else {
      result = await helper.insertTask(task);
    }
    if (result != 0) {
      _showAlertDialog('Status', 'Task Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Problem Saving Task');
    }
  }

  void _delete() async {
    moveToLastScreen();
    if (task.id == null) {
      _showAlertDialog('Status', 'No Task was deleted');
      return;
    }

    int result = await helper.deleteTask(task.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Task Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Task');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
