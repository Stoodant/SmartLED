import 'package:flutter/material.dart';

class FormPage extends StatelessWidget {
  String title = 'form';
  FormPage({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("goback"),
        ),
        appBar: AppBar(
          title: Text(this.title),
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              TextField(),
              SizedBox(height: 20,),
              TextField(
                decoration: InputDecoration(
                  hintText: "input some words",
                  border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                decoration: InputDecoration(
                  labelText: "username",
                  border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: 20,),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "userpwd",
                  border: OutlineInputBorder()
                ),
              )
            ],
          ),
        
        ));
  }
}
