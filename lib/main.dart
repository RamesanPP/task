import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'model/task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'page/taskpage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'Hive Expense App';

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: MyApp.title,
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: TaskPage(),
      );
}
