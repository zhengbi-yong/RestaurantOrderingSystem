import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config.dart';

void log(String message) {
  developer.log(message, name: 'WaiterOrderPage');
}

class WaiterOrderPage extends StatefulWidget {
  @override
  _WaiterOrderPageState createState() => _WaiterOrderPageState();
}

class _WaiterOrderPageState extends State<WaiterOrderPage> {
  List<dynamic> menuItems = [];
  Map<String, int> orderItems = {};
  TextEditingController nameController = TextEditingController();

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

  Future<http.Response> submitOrder(String userName, double total) async {
    final order = {
      'user': userName, // 用服务员输入的用户名替换 globalUser
      'timestamp': DateTime.now().toIso8601String(),
      'total': total,
      'isSubmitted': true, // 订单已经被提交
      'isConfirmed': false, // 订单尚未被确认
      'isCompleted': false, // 订单尚未完成
      'isPaid': false, // 订单尚未支付
      'items': orderItems.map((name, count) => MapEntry(name, {
            'count': count,
            'price':
                menuItems.firstWhere((item) => item['name'] == name)['price'],
            'isPrepared': false, // 菜品尚未被准备
            'isServed': false, // 菜品尚未上桌
          }))
    };

    final response = await http.post(
      Uri.parse('${Config.API_URL}/orders'), // 修改为后端接口地址
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // 如果订单提交成功，返回上一个页面
    }

    return response;
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

    double total = orderItems.entries.fold(0, (sum, entry) {
      String name = entry.key;
      int count = entry.value;
      double price =
          menuItems.firstWhere((item) => item['name'] == name)['price'];
      return sum + price * count;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('服务员帮忙点菜'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: '输入顾客名',
              contentPadding: EdgeInsets.all(16.0),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                      color: Colors.blue, // 类别名颜色修改为蓝色
                    ),
                  ),
                  children: categoryMenuItems.map((menuItem) {
                    final orderCount = orderItems[menuItem['name']] ?? 0;
                    return Card(
                      child: ListTile(
                        title: Text(
                          menuItem['name'],
                          style: TextStyle(
                            color: orderCount > 0 ? Colors.green : Colors.black,
                          ),
                        ),
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
                                      orderItems.remove(
                                          menuItem['name']); // 如果数量为0，移除这个菜品
                                    } else {
                                      orderItems[menuItem['name']] =
                                          orderCount - 1;
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
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          submitOrder(nameController.text, total);
        },
        icon: Icon(Icons.check),
        label: Text('提交订单: $total 元'),
      ),
    );
  }
}
