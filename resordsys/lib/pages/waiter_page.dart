import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

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
  }

  Future<void> fetchOrders() async {
    final response =
        await http.get(Uri.parse('http://8.134.163.125:5000/orders/submitted'));
    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
      });
    } else {
      print('Failed to fetch orders');
    }
  }

  Future<void> confirmOrder(int id) async {
    final response = await http.post(
      Uri.parse('http://8.134.163.125:5000/orders/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    if (response.statusCode == 200) {
      fetchOrders();
    } else {
      print('Failed to confirm order');
    }
  }

  Future<void> serveItem(int orderId, String itemName) async {
    final response = await http.post(
      Uri.parse('http://8.134.163.125:5000/orders/serve_item'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId, 'itemName': itemName}),
    );
    if (response.statusCode == 200) {
      fetchOrders();
    } else {
      print('Failed to serve item');
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
          return ExpansionTile(
            title: Text('订单： ${order['id']}'),
            children: [
              ...(order['items'] as Map<String, dynamic>).entries.map((item) {
                return ListTile(
                  title: Text(item.key),
                  subtitle:
                      Text('${item.value['count']} x \$${item.value['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(item.value['isPrepared'] ? '已就绪' : '准备中'),
                      if (item.value['isPrepared'] && !item.value['isServed'])
                        TextButton(
                          onPressed: () => serveItem(order['id'], item.key),
                          child: Text('确认上菜'),
                        ),
                      Text(item.value['isServed'] ? '已上菜' : '未上菜'),
                    ],
                  ),
                );
              }).toList(),
              ElevatedButton(
                onPressed: () => confirmOrder(order['id']),
                child: Text('确认订单'),
              ),
              Text(
                  'Status: ${order['isSubmitted'] ? '已提交' : '未提交'} / ${order['isConfirmed'] ? '已确认' : '未确认'} / ${order['isCompleted'] ? '已完成' : '未完成'}'),
            ],
          );
        },
      ),
    );
  }
}
