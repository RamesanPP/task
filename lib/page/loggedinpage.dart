import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:task/api/google_signin.dart';
import 'package:task/model/task.dart';
import 'package:task/page/taskpage.dart';

class LoggedInPage extends StatelessWidget {
  final GoogleSignInAccount user;

  LoggedInPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () async {
                  await Hive.openBox<Task>('tasks');
                  await GoogleSignInApi.logout();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => TaskPage()));
                },
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: Container(
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl!),
              ),
              Text("Name: " + user.displayName!),
              Text('Email: ' + user.email)
            ],
          ),
        ),
      );
}
