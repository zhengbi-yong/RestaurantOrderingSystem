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
  final color1 = Color(0xFF1c595a);
  final color2 = Color(0xFF458d8c);
  final color3 = Color(0xFF58a6a6);
  final color4 = Color(0xFF67734d);
  final color5 = Color(0xFFd7d8ac);

  @override
  void initState() {
    super.initState();
    fetchOrders();

    socket = IO.io('${Config.API_URL}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();

    socket?.on('order confirmed', (_) {
      fetchOrders();
    });
    socket?.on('order modified', (_) {
      fetchOrders();
    });
    socket?.on('new order', (_) {
      fetchOrders();
    });
    socket?.on('delete order', (_) {
      fetchOrders();
    });
    socket?.on('order paid', (_) {
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
            style: TextStyle(color: color5, fontSize: 20)), // 修改了标题颜色
        backgroundColor: color3, // 修改了背景颜色
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];

          bool allItemsPrepared = (order['items'] as Map<String, dynamic>)
              .values
              .every((item) => item['isPrepared']);

          if (order['isSubmitted'] &&
              order['isConfirmed'] &&
              order['isPaid'] &&
              allItemsPrepared) {
            return SizedBox.shrink();
          }

          return Material(
            color: Colors.transparent,
            child: ExpansionTile(
              title: Text('${order['user']} 的订单',
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: color2)), // 修改了订单标题颜色
              children: order['items'].entries.map<Widget>((itemEntry) {
                var itemName = itemEntry.key;
                var itemDetails = itemEntry.value;
                Color backgroundColor = itemDetails['isPrepared']
                    ? color4.withOpacity(0.5) // 修改了已备菜的背景颜色
                    : color1.withOpacity(0.5); // 修改了未备菜的背景颜色
                return Container(
                  color: backgroundColor,
                  child: Card(
                    child: ListTile(
                      title: Text(itemName,
                          style: TextStyle(
                              fontSize: 16, color: color3)), // 修改了菜品名称颜色
                      subtitle: Text(itemDetails['isPrepared'] ? '已备菜' : '未备菜',
                          style: TextStyle(
                              fontSize: 14, color: color5)), // 修改了备菜状态颜色
                      trailing: !itemDetails['isPrepared']
                          ? ElevatedButton(
                              onPressed: () async {
                                await completeOrderItem(order['id'], itemName);
                                fetchOrders();
                              },
                              child: Text('出菜',
                                  style: TextStyle(color: color5)), // 修改了按钮文字颜色
                              style: ElevatedButton.styleFrom(
                                primary: color1, // 修改了按钮背景颜色
                              ),
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
        shape: CircularNotchedRectangle(),
        color: color3, // 使用 color3
        child: Container(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 50,
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MenuItemManagePage()),
                    );
                  },
                  child: Text('菜品管理'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(color1), // 使用 color1
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: color1), // 使用 color1
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
