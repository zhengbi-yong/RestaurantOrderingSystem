import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config.dart';
import 'waiterorder_page.dart';

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

    return await http.post(
      Uri.parse('${Config.API_URL}/orders'), // 修改为后端接口地址
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length + 1, // 注意这里 itemCount 加 1
              itemBuilder: (ctx, index) {
                // 如果是最后一个，返回一个空白的容器
                if (index == menuItems.length) {
                  return Container(height: 80.0); // 你可以调整这个高度来满足你的需求
                }

                final menuItem = menuItems[index];
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
                                orderItems
                                    .remove(menuItem['name']); // 如果数量为0，移除这个菜品
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          double total = orderItems.entries.fold(0, (sum, entry) {
            String name = entry.key;
            int count = entry.value;
            double price =
                menuItems.firstWhere((item) => item['name'] == name)['price'];
            return sum + price * count;
          });
          submitOrder(nameController.text, total);
        },
        child: Icon(Icons.check),
        tooltip: '提交订单',
      ),
    );
  }
}
