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
    return Scaffold(
      appBar: AppBar(
        title: Text('海底世界海景餐厅'),
      ),
      body: ListView.builder(
        itemCount: menuItems.length + 1,
        itemBuilder: (ctx, index) {
          // 如果是最后一个，返回一个空白的容器
          if (index == menuItems.length) {
            return Container(height: 80.0);
          }

          final menuItem = menuItems[index];
          final orderCount = orderItems[menuItem['name']] ?? 0;

          // 检查是否需要插入新的标题
          bool isNewCategory = index == 0 ||
              (menuItem['category'] ?? '其他') !=
                  (menuItems[index - 1]['category'] ?? '其他');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 如果是新的类别，就添加一个标题
              if (isNewCategory)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    menuItem['category'] ?? '其他',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ListTile(
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
              ),
            ],
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
