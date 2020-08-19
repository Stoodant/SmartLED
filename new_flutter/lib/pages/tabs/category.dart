import 'package:flutter/material.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  var textController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  void _showDialog() {
    slideDialog.showSlideDialog(
      context: context,
      child: Column(
        children: <Widget>[
          Text("请输入自定义名称"),
          SizedBox(
            height: 20,
          ),
          TextField(
            decoration: InputDecoration(
                hintText: "input name", border: OutlineInputBorder()),
            controller: textController,
          ),
          SizedBox(height: 40),
          Container(
            child: FloatingActionButton(
              child: Text("确定"),
              onPressed: () {
                print(textController.text);
              },
            ),
            margin: EdgeInsets.only(left: 280),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: FloatingActionButton(
              onPressed: () => _showDialog(),
              heroTag: "toshow",
              child: Text("Show"),
            ),
            width: 50,
            height: 50,
          )
        ]);
  }
}
