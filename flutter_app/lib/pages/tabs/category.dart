import 'package:flutter/material.dart';
import '../FormPage.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: Text("jump to FormPage"),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FormPage(
                        title: "jump to form",
                      )));
            },
            color: Theme.of(context).accentColor,
            textTheme: ButtonTextTheme.primary,
          ),
        ]);
  }
}
