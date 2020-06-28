import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do/models/Item.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-do App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();
  HomePage() {
    items = [];
  }
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // variavel de controle do edit
  var newTaskCtrl = TextEditingController();
  // adiciona item na lista
  void add() {
    if (newTaskCtrl.text.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: newTaskCtrl.text, done: false));
      newTaskCtrl.clear();
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text("Lista de tarefas"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              SizedBox(width: 10),
              Flexible(
                child: Container(
                  height: 50,
                  child: TextFormField(
                    controller: newTaskCtrl,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Digite a tarefa",
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                height: 50,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.red)),
                  onPressed: add,
                  color: Colors.red,
                  textColor: Colors.white,
                  child: Text("Adicionar".toUpperCase(),
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: widget.items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = widget.items[index];
                return Dismissible(
                  child: CheckboxListTile(
                    activeColor: Colors.green,
                    title: Text(item.title),
                    value: item.done,
                    onChanged: (value) {
                      setState(() {
                        item.done = value;
                        save();
                      });
                    },
                  ),
                  key: Key(item.title),
                  background: Container(
                    color: Colors.red.withOpacity(0.2),
                  ),
                  onDismissed: (direction) {
                    //print(direction);
                    remove(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
