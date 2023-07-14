import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import '../config.dart';
import '../globals.dart';

void log(String message) {
  developer.log(message, name: 'ShoppingCartPage');
}

class ShoppingCartPage extends StatelessWidget {
  final Map<String, int> orderItems;
  final List<dynamic> menuItems;

  ShoppingCartPage(this.orderItems, this.menuItems);

  Future<http.Response> submitOrder(double total) async {
    final order = {
      'user': globalUser,
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
      body: ListView.builder(
        itemCount: orderItems.length,
        itemBuilder: (ctx, index) {
          final name = orderItems.keys.elementAt(index);
          final count = orderItems[name];
          final item = menuItems.firstWhere((item) => item['name'] == name);
          final itemTotal = item['price'] * count;
          return Card(
            child: ListTile(
              leading: Text(name, style: TextStyle(fontSize: 20)),
              title: Text('单价: ${item['price']} 元'),
              trailing:
                  Text('数量: x$count \n小计: ${itemTotal.toStringAsFixed(2)} 元'),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('总价: ${total.toStringAsFixed(2)} 元',
              style: TextStyle(fontSize: 20, color: Colors.red)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var response = await submitOrder(total);
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('订单已提交')),
            );
            orderItems.clear();
            Navigator.pushNamed(context, '/customer_page');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('提交订单失败')),
            );
          }
        },
        child: Icon(Icons.shopping_cart),
        backgroundColor: Colors.green, // Change the color of the button
        elevation: 4, // Add some shadow
      ),
    );
  }
}
