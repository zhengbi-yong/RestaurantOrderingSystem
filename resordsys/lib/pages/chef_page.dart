import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'menuitemmanage_page.dart';
import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config.dart';

IO.Socket? socket;

void log(String message) {
  developer.log(message, name: 'ChefPage');
}

class ChefPage extends StatefulWidget {
  @override
  _ChefPageState createState() => _ChefPageState();
}

class _ChefPageState extends State<ChefPage> {
  List<dynamic> orders = [];
  @override
  void initState() {
    super.initState();
    fetchOrders();

    // 初始化socket连接
    socket = IO.io('${Config.API_URL}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // 连接到服务器
    socket?.connect();

    // 当服务器发送 'order confirmed' 事件时触发
    socket?.on('order confirmed', (_) {
      fetchOrders();
    });
  }

  Future<void> fetchOrders() async {
    final response =
        await http.get(Uri.parse('${Config.API_URL}/orders/confirmed'));
    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
      });
    } else {
      print('获取订单列表失败');
    }
  }

  Future<void> completeOrderItem(int orderId, String itemName) async {
    final response = await http.post(
      Uri.parse('${Config.API_URL}/orders/complete_item'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId, 'itemName': itemName}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to complete order item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('厨师'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          return Material(
            color: Colors.transparent,
            child: ExpansionTile(
              title: Text('订单: ${order['id']}'),
              children: order['items'].entries.map<Widget>((itemEntry) {
                var itemName = itemEntry.key;
                var itemDetails = itemEntry.value;
                return Card(
                  child: ListTile(
                    title: Text(itemName),
                    subtitle: Text(itemDetails['isPrepared'] ? '已备菜' : '未备菜'),
                    trailing: !itemDetails['isPrepared']
                        ? ElevatedButton(
                            onPressed: () async {
                              await completeOrderItem(order['id'], itemName);
                              // 如果所有的菜品都已经完成，那么订单就从列表中移除
                              if (order['items'].values.every(
                                  (item) => item['isPrepared'] == true)) {
                                setState(() {
                                  orders.removeAt(index);
                                });
                              } else {
                                setState(() {
                                  itemDetails['isPrepared'] = true;
                                });
                              }
                            },
                            child: Text('出菜'),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuItemManagePage()),
                );
              },
              child: Text('菜品管理'),
            ),
          ],
        ),
      ),
    );
  }
}
