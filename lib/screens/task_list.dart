import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/db_helper.dart';
import '../screens/task_detail.dart';
import 'package:sqflite/sqflite.dart';

class TaskList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaskListState();
  }
}

class TaskListState extends State<TaskList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Task> taskList;
  int count = 0;

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Task>> taskListFuture = databaseHelper.getTaskList();
      taskListFuture.then((taskList) {
        setState(() {
          this.taskList = taskList;
          this.count = taskList.length;
        });
      });
    });
  }

  void navigateToDetail(Task task, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TaskDetail(task, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  ListView getTaskListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subtitle1;

    void _showSnackBar(BuildContext context, String message) {
      final sBar = SnackBar(content: Text(message));
      Scaffold.of(context).showSnackBar(sBar);
    }

    Color getPriorityColor(int priority) {
      switch (priority) {
        case 1:
          return Colors.red;
          break;
        case 2:
          return Colors.green;
          break;
        default:
          return Colors.pink;
      }
    }

    Icon getPriorityIcon(int priority) {
      switch (priority) {
        case 1:
          return Icon(Icons.assignment_late);
          break;
        case 2:
          return Icon(Icons.assignment);
          break;
        default:
          return Icon(Icons.beach_access);
      }
    }

    void _delete(BuildContext context, Task task) async {
      int result = await databaseHelper.deleteTask(task.id);
      if (result != 0) {
        _showSnackBar(context, 'Task Deleted Successfully');
        updateListView();
      }
    }

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        getPriorityColor(this.taskList[position].priority),
                    child: getPriorityIcon(this.taskList[position].priority),
                  ),
                  title: Text(
                    this.taskList[position].title,
                    style: titleStyle,
                  ),
                  subtitle: Text(this.taskList[position].date),
                  trailing: GestureDetector(
                    child: Icon(
                      Icons.delete,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      _delete(context, taskList[position]);
                    },
                  ),
                  onTap: () {
                    debugPrint("ListTile Tapped");
                    navigateToDetail(this.taskList[position], 'Edit Task');
                  }));
        });
  }

  @override
  Widget build(BuildContext context) {
    if (taskList == null) {
      taskList = List<Task>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: getTaskListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Task('', '', 2), 'Add Task');
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add),
      ),
    );
  }
}
