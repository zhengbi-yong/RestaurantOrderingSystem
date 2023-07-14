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
  TextEditingController userController = TextEditingController(); // 创建一个文本输入控制器

  @override
  void initState() {
    super.initState();
    order = Map<String, dynamic>.from(widget.initialOrder);
    userController.text = order['user']; // 设置文本输入框的初始值为订单的当前用户
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

  Future<void> modifyOrder() async {
    // 过滤掉数量为0的菜品
    order['items'].removeWhere((key, value) => value['count'] == 0);
    order['user'] = userController.text;

    // 从菜单数据中获取正确的价格，并计算总价
    order['total'] = 0;
    order['items'].forEach((key, value) {
      var menuItem = menuItems.firstWhere((item) => item['name'] == key,
          orElse: () => null);
      if (menuItem != null) {
        value['price'] = menuItem['price']; // 更新价格
        order['total'] += value['count'] * value['price']; // 计算总价
      }
    });

    final response = await http.put(
      Uri.parse('${Config.API_URL}/orders/${order['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );
    if (response.statusCode == 200) {
      Navigator.pop(context, true); // 返回上一个页面
    } else {
      print('修改订单失败');
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
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
        title: Text('修改订单',
            style: TextStyle(color: Colors.white, fontSize: 20)), // 修改标题颜色和字体大小
        backgroundColor: Colors.orange, // 修改App Bar背景颜色
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
                labelStyle: TextStyle(fontSize: 18), // 修改标签字体大小
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap:
                true, // This is important as there are multiple widgets in ListView
            physics:
                NeverScrollableScrollPhysics(), // This is important as there are multiple widgets in ListView
            itemCount: groupedMenuItems.keys.length,
            itemBuilder: (ctx, index) {
              String category = groupedMenuItems.keys.elementAt(index);
              List<dynamic> categoryMenuItems =
                  groupedMenuItems[category] ?? [];

              return ExpansionTile(
                title: Text(
                  category ?? '其他',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple, // 类别名颜色修改为深紫色
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
                        style: TextStyle(fontSize: 16)), // 修改菜名字体大小
                    subtitle: Text('${menuItem['price']} 元',
                        style: TextStyle(fontSize: 14)), // 修改价格字体大小
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove,
                              color: Colors.red), // 修改减号颜色为红色
                          onPressed: () {
                            if (orderItem['count'] > 0) {
                              setState(() {
                                orderItem['count']--;
                              });
                            }
                          },
                        ),
                        Text('${orderItem['count']}',
                            style: TextStyle(fontSize: 16)), // 修改数量字体大小
                        IconButton(
                          icon:
                              Icon(Icons.add, color: Colors.green), // 修改加号颜色为绿色
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
      floatingActionButton: FloatingActionButton(
        onPressed: modifyOrder,
        child: Icon(Icons.check),
        tooltip: '确认修改',
        backgroundColor: Colors.orange, // 修改浮动操作按钮的背景颜色
      ),
    );
  }
}
