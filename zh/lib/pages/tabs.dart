import 'package:flutter/material.dart';
import 'tabs/home.dart';
import 'tabs/category.dart';
import 'tabs/setting.dart';

class Tabs extends StatefulWidget {
  Tabs({Key key}) : super(key: key);

  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;

  List _pageList = [HomePage(), CategoryPage(), SettingPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SmartLED Demo"),
      ),
      floatingActionButton: Container(
        height: 65,
        width: 65,
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40), color: Colors.white),
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            print(1);
            setState(() {
              this._currentIndex = 1;
            });
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: this._pageList[this._currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: this._currentIndex,
          onTap: (int index) {
            setState(() {
              this._currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("首页")),
            BottomNavigationBarItem(
                icon: Icon(Icons.category), title: Text("分类")),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), title: Text("设置")),
          ]),
      drawer: Drawer(
          child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(
              child: UserAccountsDrawerHeader(
                accountName: Text("username"),
                accountEmail: Text("useremail"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1028479771,2944343576&fm=26&gp=0.jpg"),
                ),
              ),
            )
          ]),
          ListTile(
            title: Text("home"),
            leading: CircleAvatar(
              child: Icon(Icons.home),
            ),
          ),
          Divider(),
          ListTile(
            title: Text("center"),
            leading: CircleAvatar(
              child: Icon(Icons.people),
            ),
          ),
          Divider(),
          ListTile(
            title: Text("setting"),
            leading: CircleAvatar(
              child: Icon(Icons.settings),
            ),
          ),
        ],
      )),
    );
  }
}
