import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shoppingcart_page.dart';
import 'dart:developer' as developer;
import '../config.dart';

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
    final response = await http.get(Uri.parse('${Config.API_URL}/menu'));
    if (response.statusCode == 200) {
      setState(() {
        menuItems = jsonDecode(response.body);
        // 对菜品列表按照 'category' 字段进行排序
        menuItems.sort(
            (a, b) => (a['category'] ?? '其他').compareTo(b['category'] ?? '其他'));
      });
    } else {
      print('获取菜单失败');
    }
  }

  Future<void> addMenuItem(String name, double price) async {
    final response = await http.post(
      Uri.parse('${Config.API_URL}/menu'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'price': price}),
    );
    if (response.statusCode == 200) {
      fetchMenu();
    } else {
      print('获取菜单失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 对menuItems进行分组，以类别作为key，对应类别的菜品作为value
    Map<String, List<dynamic>> groupedMenuItems = {};

    for (var menuItem in menuItems) {
      if (!groupedMenuItems.containsKey(menuItem['category'])) {
        groupedMenuItems[menuItem['category']] = [];
      }
      groupedMenuItems[menuItem['category']]?.add(menuItem);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('海底世界海景餐厅'),
      ),
      body: ListView.builder(
        itemCount: groupedMenuItems.keys.length,
        itemBuilder: (ctx, index) {
          String category = groupedMenuItems.keys.elementAt(index);
          List<dynamic> categoryMenuItems = groupedMenuItems[category] ?? [];

          return ExpansionTile(
            title: Text(
              category ?? '其他',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // 类别名颜色修改为蓝色
              ),
            ),
            children: categoryMenuItems.map((menuItem) {
              final orderCount = orderItems[menuItem['name']] ?? 0;
              return ListTile(
                title: Text(menuItem['name']),
                subtitle: Text('${menuItem['price']} 元'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        if (orderCount > 0) {
                          setState(() {
                            if (orderCount - 1 == 0) {
                              orderItems.remove(menuItem['name']);
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
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(height: 60.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
