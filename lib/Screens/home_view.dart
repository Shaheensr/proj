// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proj/Screens/login_view.dart';
import '../authenticate.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController taskTitleInputController = TextEditingController();
  TextEditingController taskDescripInputController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  bool isSelected = false;
  bool completedGoals = false;
  String title = "List of Goals";

  @override
  initState() {
    taskTitleInputController = TextEditingController();
    taskDescripInputController = TextEditingController();
    super.initState();
  }

  _showDialog() async {
    await showDialog<String>(
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Column(
          children: <Widget>[
            Text("Please fill all fields to create a new task"),
            Expanded(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(labelText: 'Task Title*'),
                controller: taskTitleInputController,
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(labelText: 'Task Description*'),
                controller: taskDescripInputController,
              ),
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                taskTitleInputController.clear();
                taskDescripInputController.clear();
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text('Add'),
              onPressed: () {
                if (taskDescripInputController.text.isNotEmpty &&
                    taskTitleInputController.text.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('goal')
                      .add({
                        "title": taskTitleInputController.text,
                        "description": taskDescripInputController.text,
                        "user": user!.uid,
                        "isCompleted": false
                      })
                      .then((result) => {
                            Navigator.pop(context),
                            taskTitleInputController.clear(),
                            taskDescripInputController.clear(),
                          })
                      .catchError((err) => print(err));
                }
              })
        ],
      ),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Current Goals'),
              onTap: () {
                setState(() {
                  completedGoals = false;
                  title = "List of Goals";
                  Navigator.pop(context);
                });
                
              },
            ),
            ListTile(
              title: const Text('Completed Goals'),
              onTap: () {
                setState(() {
                  completedGoals = true;
                  title = "Completed Goals";
                  Navigator.pop(context); 
                });

              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey[600],
        child: Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
        onPressed: () => _showDialog(),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("goal")
              .where("user", isEqualTo: user!.uid)
              .where("isCompleted", isEqualTo: completedGoals)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    Card(
                      elevation: 15,
                      child: ListTile(
                        title: Text(
                          snapshot.data!.docs[index]["title"],
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          snapshot.data!.docs[index]["description"],
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold),
                        ),
                        leading: IconButton(
                          icon: Icon(
                            Icons.check,
                            size: 30,
                            color: Colors.green,
                          ),
                          onPressed: (){
                            snapshot.data!.docs[index].reference.update({'isCompleted': true});

                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            size: 30,
                            color: Colors.red[800],
                          ),
                          onPressed: () {
                            snapshot.data!.docs[index].reference.delete();
                          },
                        ),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.only(top: 10)),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
