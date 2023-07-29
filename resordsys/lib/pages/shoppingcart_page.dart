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

  // 定义颜色
  final color1 = Color(0xFF1c595a);
  final color2 = Color(0xFF458d8c);
  final color3 = Color(0xFF58a6a6);
  final color4 = Color(0xFF67734d);
  final color5 = Color(0xFFd7d8ac);

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
          title: Text('购物车', style: TextStyle(color: color5)), // 修改标题颜色
          backgroundColor: color3, // 修改App Bar背景颜色
        ),
        body: Center(
          child: Text('购物车为空', style: TextStyle(color: color1)), // 修改文本颜色
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
        title: Text('购物车', style: TextStyle(color: color5)), // 修改标题颜色
        backgroundColor: color3, // 修改App Bar背景颜色
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
              leading: Text(name,
                  style:
                      TextStyle(fontSize: 20, color: color2)), // 修改菜品名字体大小和颜色
              title: Text('单价: ${item['price']} 元',
                  style: TextStyle(color: color2)), // 修改价格颜色
              trailing: Text(
                  '数量: x$count \n小计: ${itemTotal.toStringAsFixed(2)} 元', // 修改数量和小计的颜色
                  style: TextStyle(color: color2)),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('总价: ${total.toStringAsFixed(2)} 元',
              style: TextStyle(fontSize: 20, color: color4)), // 修改总价字体大小和颜色
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var response = await submitOrder(total);
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('订单已提交',
                      style: TextStyle(color: color5)), // 修改Snack Bar文本颜色
                  backgroundColor: color3), // 修改Snack Bar背景颜色
            );
            orderItems.clear();
            Navigator.pushNamed(context, '/customer_page');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('提交订单失败',
                      style: TextStyle(color: color5)), // 修改Snack Bar文本颜色
                  backgroundColor: color3), // 修改Snack Bar背景颜色
            );
          }
        },
        child: Icon(Icons.shopping_cart, color: color5), // 修改图标颜色
        backgroundColor: color1, // 修改浮动操作按钮的背景颜色
      ),
    );
  }
}
