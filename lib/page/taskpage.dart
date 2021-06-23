import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task/api/google_signin.dart';
import '/boxes.dart';
import '../model/task.dart';
import '/widget/task_dialog.dart';
import 'package:intl/intl.dart';
import 'loggedinpage.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  void dispose() {
    Hive.close();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String filterType = "today";
  String taskPop = "close";
  var monthNames = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEPT",
    "OCT",
    "NOV",
    "DEC"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff96060),
        elevation: 0,
        title: Text(
          "Task",
          style: TextStyle(fontSize: 30),
        ),
        actions: [
          IconButton(
            onPressed: null,
            icon: Icon(
              Icons.short_text,
              color: Colors.white,
              size: 30,
            ),
          )
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(indicatorColor: Colors.red, labelColor: Colors.black, tabs: [
              Tab(
                text: 'Today',
              ),
              Tab(
                text: 'Monthly',
              ),
            ]),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Today ${monthNames[_focusedDay.month - 1]}, ${_focusedDay.day}/${_focusedDay.year}",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Expanded(
                          child: Container(
                            child: ValueListenableBuilder<Box<Task>>(
                              valueListenable: Boxes.getTask().listenable(),
                              builder: (context, box, _) {
                                final tasks = box.values.toList().cast<Task>();

                                return buildContent(tasks);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: Column(
                      children: [
                        TableCalendar(
                          firstDay: DateTime(2000),
                          lastDay: DateTime(2050),
                          focusedDay: _focusedDay,
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            if (!isSameDay(_selectedDay, selectedDay)) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            }
                          },
                          onFormatChanged: (format) {
                            if (_calendarFormat != format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            }
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                        ),
                        ElevatedButton(
                            onPressed: () => signIn(context),
                            child: Text("Sign In"))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: InkWell(
                onTap: () => showDialog(
                    context: context,
                    builder: (context) => TaskDialog(
                          onClickedDone: addTask,
                        )),
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xfff96060), Colors.red],
                      ),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      "+",
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget buildContent(List<Task> tasks) {
  if (tasks.isEmpty) {
    return Center(
      child: Text(
        'No Tasks yet!',
        style: TextStyle(fontSize: 24),
      ),
    );
  } else {
    return Expanded(
        child: Column(children: <Widget>[
      SizedBox(height: 24),
      Text(
        'Tasks',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      Stack(
        children: [
          SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(8),
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) {
                final task = tasks[index];

                return buildTask(context, task);
              },
            ),
          ),
        ],
      ),
    ]));
  }
}

Widget buildTask(
  BuildContext context,
  Task task,
) {
  final date = DateFormat.yMMMd().format(task.createdDate);

  return Card(
    color: Colors.white,
    child: ExpansionTile(
      tilePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(
        task.name,
        maxLines: 2,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text(date),
      children: [
        buildButtons(context, task),
      ],
    ),
  );
}

Widget buildButtons(BuildContext context, Task task) => Row(
      children: [
        Expanded(
          child: TextButton.icon(
            label: Text('Edit'),
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TaskDialog(
                  task: task,
                  onClickedDone: (name, createdDate) =>
                      editTask(task, name, createdDate),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: TextButton.icon(
            label: Text('Delete'),
            icon: Icon(Icons.delete),
            onPressed: () => deleteTask(task),
          ),
        )
      ],
    );

Future addTask(String name, DateTime createdDate) async {
  final task = Task()
    ..name = name
    ..createdDate = DateTime.now();

  final box = Boxes.getTask();
  box.add(task);
  //box.put('mykey', task);

  // final mybox = Boxes.getTasks();
  // final myTask = mybox.get('key');
  // mybox.values;
  // mybox.keys;
}

void editTask(
  Task task,
  String name,
  DateTime createdDate,
) {
  task.name = name;
  task.createdDate = DateTime.now();

  // final box = Boxes.getTasks();
  // box.put(task.key, task);

  task.save();
}

void deleteTask(Task task) {
  // final box = Boxes.getTasks();
  // box.delete(task.key);

  task.delete();
  //setState(() => tasks.remove(task));
}

Future signIn(BuildContext context) async {
  final user = await GoogleSignInApi.login();
  if (user == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Sign in failed')));
  } else {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoggedInPage(user: user)));
  }
}
