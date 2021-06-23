import 'package:hive/hive.dart';
import 'package:task/model/task.dart';
import 'model/task.dart';

class Boxes {
  static Box<Task> getTask() => Hive.box<Task>('tasks');
}
