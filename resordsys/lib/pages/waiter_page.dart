import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerPage extends StatefulWidget {
  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  List<dynamic> menuItems = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    final response = await http.get(Uri.parse('http://localhost:5000/menu'));
    if (response.statusCode == 200) {
      setState(() {
        menuItems = jsonDecode(response.body);
      });
    } else {
      print('Failed to fetch menu items');
    }
  }

  Future<void> addMenuItem(String name, double price) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/menu'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'price': price}),
    );
    if (response.statusCode == 200) {
      fetchMenu();
    } else {
      print('Failed to add menu item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('海底世界海景餐厅点餐系统'),
      ),
      body: ListView.builder(
        itemCount: menuItems.length,
        itemBuilder: (ctx, index) {
          final menuItem = menuItems[index];
          return ListTile(
            title: Text(menuItem['name']),
            subtitle: Text('\$${menuItem['price']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Add Menu Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Name'),
                    controller: nameController,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    controller: priceController,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    String name = nameController.text;
                    double price = double.parse(priceController.text);
                    addMenuItem(name, price);
                    Navigator.of(context).pop();
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
