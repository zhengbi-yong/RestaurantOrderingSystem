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
    socket?.on('order modified', (_) {
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
        title: Text('厨师',
            style: TextStyle(color: Colors.white, fontSize: 20)), // 修改标题颜色和字体大小
        backgroundColor: Colors.blue, // 修改App Bar背景颜色
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          return Material(
            color: Colors.transparent,
            child: ExpansionTile(
              title: Text('${order['user']} 的订单',
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold)), // 修改字体大小和样式
              children: order['items'].entries.map<Widget>((itemEntry) {
                var itemName = itemEntry.key;
                var itemDetails = itemEntry.value;
                Color backgroundColor = itemDetails['isPrepared']
                    ? Colors.green.withOpacity(0.5)
                    : Colors.red.withOpacity(0.5);
                return Container(
                  color: backgroundColor,
                  child: Card(
                    child: ListTile(
                      title: Text(itemName,
                          style: TextStyle(fontSize: 16)), // 修改字体大小
                      subtitle: Text(itemDetails['isPrepared'] ? '已备菜' : '未备菜',
                          style: TextStyle(fontSize: 14)), // 修改字体大小
                      trailing: !itemDetails['isPrepared']
                          ? ElevatedButton(
                              onPressed: () async {
                                await completeOrderItem(order['id'], itemName);
                                // 如果所有的菜品都已经完成，那么订单就从列表中移除
                                fetchOrders();
                              },
                              child: Text('出菜'),
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue, // 修改BottomAppBar颜色为蓝色
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuItemManagePage()),
                );
              },
              child: Text('菜品管理',
                  style: TextStyle(color: Colors.white)), // 修改文字颜色为白色
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange)), // 修改按钮颜色为橙色
            ),
          ],
        ),
      ),
    );
  }
}
