import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'menuitemmanage_page.dart';
import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config.dart';

IO.Socket? socket;

void log(String message) {
  developer.log(message, name: 'BossPage');
}

class BossPage extends StatefulWidget {
  @override
  _BossPageState createState() => _BossPageState();
}

class _BossPageState extends State<BossPage> {
  List<dynamic> orders = [];
  double totalRevenue = 0.0;

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
    // 当服务器发送 'new order' 事件时触发
    socket?.on('new order', (_) {
      fetchOrders();
    });
  }

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse('${Config.API_URL}/orders'));
    // print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
        totalRevenue = orders.fold(0.0, (sum, item) => sum + item['total']);
      });
    } else {
      print('获取订单列表失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('老板'),
      ),
      body: Column(
        children: [
          Text('总营业额: ${totalRevenue.toStringAsFixed(0)} 元'),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (ctx, index) {
                final order = orders[index];
                return ExpansionTile(
                  title: Text('${order['user']} 的订单'),
                  subtitle: Text('总计 ${order['total'].toStringAsFixed(0)} 元'),
                  children: (order['items'] as Map<String, dynamic>)
                      .entries
                      .map<Widget>((item) {
                    return ListTile(
                      title: Text(item.key),
                      subtitle: Text(
                          '价格: ${item.value['price'].toStringAsFixed(0)} 元, 数量: ${item.value['count']} 份'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
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
