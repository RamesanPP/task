import 'package:flutter/material.dart';

import '../model/task.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final Function(String name, DateTime createdDate) onClickedDone;

  const TaskDialog({
    Key? key,
    this.task,
    required this.onClickedDone,
  }) : super(key: key);

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  bool isExpense = true;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      final task = widget.task!;

      nameController.text = task.name;
    }
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final title = isEditing ? 'Edit Task' : 'Add Task';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 8),
            buildName(),
            SizedBox(height: 8),
            buildDate(),
            SizedBox(height: 8),
          ],
        ),
      ),
      actions: <Widget>[
        buildCancelButton(context),
        buildAddButton(context, isEditing: isEditing),
      ],
    );
  }

  Widget buildName() => TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Enter Name',
        ),
        validator: (name) =>
            name != null && name.isEmpty ? 'Enter a name' : null,
      );

  Widget buildDate() => TextFormField(
      // decoration: InputDecoration(
      //   border: OutlineInputBorder(),
      //   hintText: 'Enter Amount',
      // ),
      // keyboardType: TextInputType.number,
      // validator: (amount) => amount != null && double.tryParse(amount) == null
      //     ? 'Enter a valid number'
      //     : null,
      );

  Widget buildCancelButton(BuildContext context) => TextButton(
        child: Text('Cancel'),
        onPressed: () => Navigator.of(context).pop(),
      );

  Widget buildAddButton(BuildContext context, {required bool isEditing}) {
    final text = isEditing ? 'Save' : 'Add';

    return TextButton(
      child: Text(text),
      onPressed: () async {
        final isValid = formKey.currentState!.validate();

        if (isValid) {
          final name = nameController.text;

          widget.onClickedDone(name, DateTime.now());

          Navigator.of(context).pop();
        }
      },
    );
  }
}
