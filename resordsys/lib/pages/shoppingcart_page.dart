import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShoppingCartPage extends StatelessWidget {
  final Map<String, int> orderItems;
  final List<dynamic> menuItems;

  ShoppingCartPage(this.orderItems, this.menuItems);

  @override
  Widget build(BuildContext context) {
    if (orderItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('购物车'),
        ),
        body: Center(
          child: Text('购物车为空'),
        ),
      );
    }

    double total = 0;
    for (var name in orderItems.keys) {
      var item = menuItems.firstWhere((item) => item['name'] == name);
      total += item['price'] * orderItems[name];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('购物车'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: orderItems.length,
              itemBuilder: (ctx, index) {
                final name = orderItems.keys.elementAt(index);
                final count = orderItems[name];
                return ListTile(
                  title: Text(name),
                  trailing: Text('x$count'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('总价: \$${total.toStringAsFixed(2)}'),
                ElevatedButton(
                  onPressed: () async {
                    var response = await submitOrder(total);
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('订单已提交')),
                      );
                      orderItems.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('提交订单失败')),
                      );
                    }
                  },
                  child: Text('提交订单'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<http.Response> submitOrder(double total) async {
    final order = {
      'user': 'customer', // 或者其他用户身份
      'timestamp': DateTime.now().toIso8601String(),
      'total': total,
      'isSubmitted': true, // 订单已经被提交
      'isConfirmed': false, // 订单尚未被确认
      'isCompleted': false, // 订单尚未完成
      'items': orderItems.map((name, count) => MapEntry(name, {
            'count': count,
            'price':
                menuItems.firstWhere((item) => item['name'] == name)['price'],
            'isPrepared': false, // 菜品尚未被准备
            'isServed': false, // 菜品尚未上桌
          }))
    };

    return await http.post(
      Uri.parse('http://localhost:5000/orders'), // 修改为后端接口地址
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );
  }
}
