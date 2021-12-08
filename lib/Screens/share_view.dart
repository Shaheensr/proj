import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proj/Screens/login_view.dart';
import '../authenticate.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../driver.dart';

class ShareGoals extends StatefulWidget {
  @override
  _ShareGoalsState createState() => _ShareGoalsState();
}
class _ShareGoalsState extends State<ShareGoals> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _textFieldController = TextEditingController();
  String valueText = "";
  final db = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser; 
  bool completedGoals = false;
  String title = "Share Goals";

  navigateToPage(BuildContext context, String page) {
    Navigator.of(context).pushNamedAndRemoveUntil(page, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context){
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
              leading: Icon(Icons.list_rounded),
              onTap: () {
                setState(() {
                  completedGoals = false;
                  title = "List of Goals";
                  Navigator.pop(context);
                });

                navigateToPage(context, "home");

                
              },
            ),
            ListTile(
              title: const Text('Completed Goals'),
              leading: Icon(Icons.checklist_rounded),
              onTap: () {
                navigateToPage(context, "home");
                setState(() {
                  completedGoals = true;
                  title = "Completed Goals";
                });


              },
            ),
            ListTile(
              title: const Text('Chat'),
              leading: Icon(Icons.chat),
              onTap: () {
                Navigator.pop(context); 
              },
            ),
            ListTile(
              title: const Text('Share Goals'),
              leading: Icon(Icons.forum_rounded),
              onTap: () {
                navigateToPage(context, 'share');
              },
            ),    
          ],
        ),
      ),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
              FloatingActionButton(
               heroTag: null,
                onPressed: (){
                  showAddMessageAlert(context);
                },
                child: Icon(Icons.add),
              ),
          ]
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: db.collection('sharedGoals').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index){
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.message),
                      title: Text(snapshot.data!.docs[index]['content']),
                      trailing: Text(user!.email!),
                    )
                  );
                }
              );
            }
          },
      ),
    );
  }

  void _signOut(BuildContext context) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    await _auth.signOut();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('User logged out.')));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (con) => AppDriver()));
  }


  

  showLogOutAlert(BuildContext context) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed:  () => Navigator.pop(context, "No"),
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed:  () {
        _signOut(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Log Out"),
      content: Text("Would you like to Log out?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAddMessageAlert(BuildContext context) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () => Navigator.pop(context, "Cancel"),
    );
    Widget postButton = TextButton(
      child: Text("Post"),
      onPressed:  () {
        addMessage(db, valueText);
        Navigator.pop(context, "Post");
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Goal"),
      content: TextField(
          onChanged: (value) {
            valueText = value;
           }, 
          controller: _textFieldController, 
          decoration: InputDecoration(hintText: "Your Goal"), 
      ),
      actions: [
        cancelButton,
        postButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  void addMessage(FirebaseFirestore db, String text){
    db.collection("sharedGoals").add({
      'content': text,
      'timeAdded': Timestamp.now(),
      "user": user!.uid
    });
  }

  getRole() async {
      String userID = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userID).get().then((value){
        return value.data()!['role'];
      });
    }

}



  