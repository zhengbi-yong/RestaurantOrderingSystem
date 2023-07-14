import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config.dart';
import 'waiterorder_page.dart';
import 'editorder_page.dart';

IO.Socket? socket;

void log(String message) {
  developer.log(message, name: 'WaiterPage');
}

class WaiterPage extends StatefulWidget {
  @override
  _WaiterPageState createState() => _WaiterPageState();
}

class _WaiterPageState extends State<WaiterPage> {
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

    // 当服务器发送 'new order' 事件时触发
    socket?.on('new order', (_) {
      fetchOrders();
    });
    // 当服务器发送 'dish prepared' 事件时触发
    socket?.on('dish prepared', (_) {
      fetchOrders();
    });
  }

  @override
  void dispose() {
    // 断开连接，清理资源
    socket?.disconnect();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    final response =
        await http.get(Uri.parse('${Config.API_URL}/orders/submitted'));
    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
      });
    } else {
      print('获取订单列表失败');
    }
  }

  Future<void> confirmOrder(int id) async {
    final response = await http.post(
      Uri.parse('${Config.API_URL}/orders/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    if (response.statusCode == 200) {
      fetchOrders();
    } else {
      print('确认订单失败');
    }
  }

  Future<void> serveItem(int orderId, String itemName) async {
    final response = await http.post(
      Uri.parse('${Config.API_URL}/orders/serve_item'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId, 'itemName': itemName}),
    );
    if (response.statusCode == 200) {
      fetchOrders();
    } else {
      print('上菜失败');
    }
  }

  Future<void> payOrder(int id) async {
    final response = await http.post(
      Uri.parse('${Config.API_URL}/orders/pay'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    if (response.statusCode == 200) {
      fetchOrders();
    } else {
      print('支付订单失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('服务员'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (ctx, index) {
          final order = orders[index];

          bool allItemsServed = (order['items'] as Map<String, dynamic>)
              .values
              .every((item) => item['isServed']);

          if (order['isPaid']) {
            return SizedBox.shrink();
          }

          return Card(
            child: ExpansionTile(
              title: Text('${order['user']} 的订单'),
              children: [
                ...(order['items'] as Map<String, dynamic>).entries.map((item) {
                  IconData icon;
                  if (!item.value['isPrepared']) {
                    icon = Icons.hourglass_empty;
                  } else if (item.value['isPrepared'] &&
                      !item.value['isServed']) {
                    icon = Icons.hourglass_bottom;
                  } else {
                    icon = Icons.check_circle;
                  }

                  return ListTile(
                    leading: Icon(icon),
                    title: Text(item.key),
                    subtitle: Text(
                        '${item.value['count']} x \$${item.value['price']}'),
                    trailing: item.value['isPrepared'] &&
                            !item.value['isServed']
                        ? ElevatedButton(
                            onPressed: () => serveItem(order['id'], item.key),
                            child: Text('确认上菜'),
                          )
                        : null,
                  );
                }).toList(),
                ElevatedButton(
                  onPressed: order['isPaid']
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditOrderPage(order)), // 这里跳转到新的页面
                          ).then((_) {
                            // 当从修改订单页面返回时，重新获取订单数据
                            fetchOrders();
                          });
                        },
                  child: Text('修改订单'),
                ),
                ElevatedButton(
                  onPressed: () => confirmOrder(order['id']),
                  child: Text('确认订单'),
                ),
                if (allItemsServed && !order['isPaid'])
                  ElevatedButton(
                    onPressed: () => payOrder(order['id']),
                    child: Text('确认付款'),
                  ),
                Text(
                    '订单状态:${order['isSubmitted'] ? '已提交' : '未提交'} / ${order['isConfirmed'] ? '已确认' : '未确认'} / ${order['isCompleted'] ? '已完成' : '未完成'} / ${order['isPaid'] ? '已付款' : '未付款'}'),
                Text('订单总额: ${order['total']} 元'),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WaiterOrderPage()), // 这里跳转到新的页面
          );
        },
        child: Icon(Icons.add),
        tooltip: '帮忙点菜',
      ),
    );
  }
}
