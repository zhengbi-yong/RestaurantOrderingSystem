import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class EditOrderPage extends StatefulWidget {
  final Map<String, dynamic> initialOrder;

  EditOrderPage(this.initialOrder);

  @override
  _EditOrderPageState createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  late Map<String, dynamic> order;
  List<dynamic> menuItems = [];
  TextEditingController userController = TextEditingController();

  // 定义颜色
  final color1 = Color(0xFF1c595a);
  final color2 = Color(0xFF458d8c);
  final color3 = Color(0xFF58a6a6);
  final color4 = Color(0xFF67734d);
  final color5 = Color(0xFFd7d8ac);

  @override
  void initState() {
    super.initState();
    order = Map<String, dynamic>.from(widget.initialOrder);
    userController.text = order['user'];
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    final response = await http.get(Uri.parse('${Config.API_URL}/menu'));
    if (response.statusCode == 200) {
      setState(() {
        menuItems = jsonDecode(response.body);
        menuItems.sort(
            (a, b) => (a['category'] ?? '其他').compareTo(b['category'] ?? '其他'));
      });
    } else {
      print('获取菜单失败');
    }
  }

  Future<void> modifyOrder() async {
    order['items'].removeWhere((key, value) => value['count'] == 0);
    order['user'] = userController.text;

    order['total'] = 0;
    order['items'].forEach((key, value) {
      var menuItem = menuItems.firstWhere((item) => item['name'] == key,
          orElse: () => null);
      if (menuItem != null) {
        value['price'] = menuItem['price'];
        order['total'] += value['count'] * value['price'];
      }
    });

    final response = await http.put(
      Uri.parse('${Config.API_URL}/orders/${order['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );
    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      print('修改订单失败');
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> groupedMenuItems = {};

    for (var menuItem in menuItems) {
      if (!groupedMenuItems.containsKey(menuItem['category'])) {
        groupedMenuItems[menuItem['category']] = [];
      }
      groupedMenuItems[menuItem['category']]?.add(menuItem);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('修改订单', style: TextStyle(color: color5, fontSize: 20)),
        backgroundColor: color3,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '用户',
                labelStyle: TextStyle(fontSize: 18, color: color2),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: groupedMenuItems.keys.length + 1, // 添加额外的一个项目作为空白距离
            itemBuilder: (ctx, index) {
              if (index == groupedMenuItems.keys.length) {
                // 如果是最后一个项目，添加一个高度为 80 的 SizedBox
                return SizedBox(height: 80);
              }
              String category = groupedMenuItems.keys.elementAt(index);
              List<dynamic> categoryMenuItems =
                  groupedMenuItems[category] ?? [];

              return ExpansionTile(
                title: Text(
                  category ?? '其他',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: color1,
                  ),
                ),
                children: categoryMenuItems.map((menuItem) {
                  var orderItem = order['items'][menuItem['name']];
                  if (orderItem == null) {
                    orderItem = {
                      'count': 0,
                      'isPrepared': false,
                      'isServed': false
                    };
                    order['items'][menuItem['name']] = orderItem;
                  }
                  return ListTile(
                    title: Text(menuItem['name'],
                        style: TextStyle(fontSize: 16, color: color2)),
                    subtitle: Text('${menuItem['price']} 元',
                        style: TextStyle(fontSize: 14, color: color2)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: color1),
                          onPressed: () {
                            if (orderItem['count'] > 0) {
                              setState(() {
                                orderItem['count']--;
                              });
                            }
                          },
                        ),
                        Text('${orderItem['count']}',
                            style: TextStyle(fontSize: 16, color: color2)),
                        IconButton(
                          icon: Icon(Icons.add, color: color1),
                          onPressed: () {
                            setState(() {
                              orderItem['count']++;
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
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: color3, // 修改BottomAppBar颜色为color3
        child: Container(height: 60.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: modifyOrder,
        child: Icon(Icons.check, color: color5),
        tooltip: '确认修改',
        backgroundColor: color1, // 修改浮动操作按钮的背景颜色为color1
      ),
    );
  }
}
