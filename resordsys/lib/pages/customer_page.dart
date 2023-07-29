import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shoppingcart_page.dart';
import 'dart:developer' as developer;
import '../config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket? socket;
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

  // 定义颜色
  final color1 = Color(0xFF1c595a);
  final color2 = Color(0xFF458d8c);
  final color3 = Color(0xFF58a6a6);
  final color4 = Color(0xFF67734d);
  final color5 = Color(0xFFd7d8ac);

  @override
  void initState() {
    super.initState();
    fetchMenu();
    // 初始化socket连接
    socket = IO.io('${Config.API_URL}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // 连接到服务器
    socket?.connect();

    socket?.on('new menuitem', (_) {
      fetchMenu();
    });
    socket?.on('modify menuitem', (_) {
      fetchMenu();
    });
    socket?.on('delete menuitem', (_) {
      fetchMenu();
    });
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
        title: Text('海底世界海景餐厅',
            style: TextStyle(color: color5, fontSize: 20)), // 修改标题颜色和字体大小
        backgroundColor: color3, // 修改App Bar背景颜色
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
                color: color1, // 类别名颜色修改为color1
              ),
            ),
            children: categoryMenuItems.map((menuItem) {
              final orderCount = orderItems[menuItem['name']] ?? 0;
              return ListTile(
                title: Text(menuItem['name'],
                    style:
                        TextStyle(fontSize: 16, color: color2)), // 修改菜名字体大小和颜色
                subtitle: Text('${menuItem['price']} 元',
                    style:
                        TextStyle(fontSize: 14, color: color2)), // 修改价格字体大小和颜色
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: color1), // 修改减号颜色为color1
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
                    Text('$orderCount',
                        style: TextStyle(
                            fontSize: 16, color: color2)), // 修改数量字体大小和颜色
                    IconButton(
                      icon: Icon(Icons.add, color: color1), // 修改加号颜色为color1
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
        color: color3, // 修改BottomAppBar颜色为color3
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
        child: Icon(Icons.shopping_cart, color: color5), // 修改图标颜色为color5
        backgroundColor: color1, // 修改浮动操作按钮的背景颜色为color1
      ),
    );
  }
}
