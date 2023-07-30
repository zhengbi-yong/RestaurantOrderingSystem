import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import '../config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void log(String message) {
  developer.log(message, name: 'WaiterOrderPage');
}

class WaiterOrderPage extends StatefulWidget {
  @override
  _WaiterOrderPageState createState() => _WaiterOrderPageState();
}

class _WaiterOrderPageState extends State<WaiterOrderPage> {
  List<dynamic> menuItems = [];
  Map<String, double> orderItems = {};
  Map<String, TextEditingController> controllers = {};
  TextEditingController nameController = TextEditingController();

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
  }

  @override
  void dispose() {
    nameController.dispose();
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
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

  Future<http.Response> submitOrder(String userName, double total) async {
    final order = {
      'user': userName,
      'timestamp': DateTime.now().toIso8601String(),
      'total': total,
      'isSubmitted': true,
      'isConfirmed': false,
      'isCompleted': false,
      'isPaid': false,
      'items': orderItems.map((name, count) => MapEntry(name, {
            'count': count,
            'price':
                menuItems.firstWhere((item) => item['name'] == name)['price'],
            'isPrepared': false,
            'isServed': false,
          }))
    };

    final response = await http.post(
      Uri.parse('${Config.API_URL}/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
    }

    return response;
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

    double total = orderItems.entries.fold(0, (sum, entry) {
      String name = entry.key;
      double count = entry.value;
      double price =
          menuItems.firstWhere((item) => item['name'] == name)['price'];
      return sum + price * count;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('服务员帮忙点菜',
            style: TextStyle(color: color5, fontSize: 20)), // 修改标题颜色和字体大小
        backgroundColor: color3, // 修改App Bar背景颜色
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
                      color: color1, // 类别名颜色修改为color1
                    ),
                  ),
                  children: categoryMenuItems.map((menuItem) {
                    final orderCount = orderItems[menuItem['name']] ?? 0.0;
                    if (controllers[menuItem['name']] == null) {
                      controllers[menuItem['name']] = TextEditingController(
                          text: orderCount.toStringAsFixed(2));
                      controllers[menuItem['name']]?.addListener(() {
                        double newCount = double.tryParse(
                                controllers[menuItem['name']]?.text ?? '0') ??
                            0.0;
                        if (newCount == 0.0) {
                          orderItems.remove(menuItem['name']);
                        } else {
                          orderItems[menuItem['name']] = newCount;
                        }
                      });
                    } else {
                      controllers[menuItem['name']]?.text =
                          orderCount.toStringAsFixed(2);
                    }
                    return Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text(
                          menuItem['name'],
                          style: TextStyle(
                            color: orderCount > 0 ? color4 : color2, // 修改菜品名称颜色
                          ),
                        ),
                        subtitle: Text('${menuItem['price']} 元',
                            style: TextStyle(color: color2)), // 修改价格颜色
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove,
                                  color: color1), // 修改减号颜色为color1
                              onPressed: () {
                                if (orderCount > 0) {
                                  setState(() {
                                    if (orderCount - 1.0 == 0) {
                                      orderItems.remove(menuItem['name']);
                                    } else {
                                      orderItems[menuItem['name']] =
                                          orderCount - 1.0;
                                    }
                                  });
                                }
                              },
                            ),
                            SizedBox(
                              width: 50,
                              child: TextField(
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                controller: controllers[menuItem['name']],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add,
                                  color: color1), // 修改加号颜色为color1
                              onPressed: () {
                                setState(() {
                                  orderItems[menuItem['name']] =
                                      orderCount + 1.0;
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
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: color3, // 修改BottomAppBar颜色为color3
        child: Container(height: 60.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          double total = orderItems.entries.fold(0, (sum, entry) {
            String name = entry.key;
            double count = entry.value;
            double price =
                menuItems.firstWhere((item) => item['name'] == name)['price'];
            return sum + price * count;
          });
          submitOrder(nameController.text, total);
        },
        child: Icon(Icons.check, color: color5), // 修改图标颜色为color5
        backgroundColor: color1, // 修改浮动操作按钮的背景颜色为color1
      ),
    );
  }
}
