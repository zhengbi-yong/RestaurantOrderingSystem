import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuItemManagePage extends StatefulWidget {
  @override
  _MenuItemManagePageState createState() => _MenuItemManagePageState();
}

class _MenuItemManagePageState extends State<MenuItemManagePage> {
  late Future<List> futureMenuItems;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureMenuItems = fetchMenuItems();
  }

  Future<List> fetchMenuItems() async {
    final response = await http.get(Uri.parse('http://localhost:5000/menu'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  Future<void> deleteMenuItem(int itemId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:5000/menu/$itemId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete menu item');
    }
  }

  Future<void> addMenuItem(String name, String price) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/menu'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'price': price,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add menu item');
    }

    setState(() {
      futureMenuItems = fetchMenuItems();
    });
  }

  void showAddMenuItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Menu Item'),
          content: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: 'Enter item name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(hintText: 'Enter item price'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter item price';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  addMenuItem(_nameController.text, _priceController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Item Manage Page'),
      ),
      body: FutureBuilder<List>(
        future: futureMenuItems,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var menuItem = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text(menuItem['name']),
                    subtitle: Text('\$${menuItem['price'].toStringAsFixed(2)}'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await deleteMenuItem(menuItem['id']);
                        setState(() {
                          snapshot.data!.removeAt(index);
                        });
                      },
                      child: Text('删除'),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddMenuItemDialog(context);
        },
        tooltip: 'Add Menu Item',
        child: Icon(Icons.add),
      ),
    );
  }
}
