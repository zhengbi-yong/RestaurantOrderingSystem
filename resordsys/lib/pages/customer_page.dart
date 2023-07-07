import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shoppingcart_page.dart';
import 'dart:developer' as developer;

void log(String message) {
  developer.log(message, name: 'CustomerPage');
}

class CustomerPage extends StatefulWidget {
  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  List<dynamic> menuItems = [];
  Map<String, int> orderItems = {};
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    final response =
        await http.get(Uri.parse('http://8.134.163.125:5000/menu'));
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
      Uri.parse('http://8.134.163.125:5000/menu'),
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
          final orderCount = orderItems[menuItem['name']] ?? 0;
          return ListTile(
            title: Text(menuItem['name']),
            subtitle: Text('\$${menuItem['price']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (orderCount > 0) {
                      setState(() {
                        if (orderCount - 1 == 0) {
                          orderItems.remove(menuItem['name']); // 如果数量为0，移除这个菜品
                        } else {
                          orderItems[menuItem['name']] = orderCount - 1;
                        }
                      });
                    }
                  },
                ),
                Text('$orderCount'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      orderItems[menuItem['name']] = orderCount + 1;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShoppingCartPage(orderItems, menuItems)),
          );
        },
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}
