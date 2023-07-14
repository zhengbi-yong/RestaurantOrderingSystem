import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'menuitemmanage_page.dart';
import 'ordermanage_page.dart';
import 'usermanage_page.dart';
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
  double totalRevenue = 0.0;
  int employeeCount = 0;
  int menuItemCount = 0;
  int orderCount = 0;

  @override
  void initState() {
    super.initState();
    fetchSummaryData();

    // 初始化socket连接
    socket = IO.io('${Config.API_URL}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    // 连接到服务器
    socket?.connect();

    // 当服务器发送 'order confirmed' 事件时触发
    socket?.on('order confirmed', (_) {
      fetchSummaryData();
    });
    // 当服务器发送 'new order' 事件时触发
    socket?.on('new order', (_) {
      fetchSummaryData();
    });
  }

  Future<void> fetchSummaryData() async {
    final summaryResponse =
        await http.get(Uri.parse('${Config.API_URL}/summary'));

    if (summaryResponse.statusCode == 200) {
      var summary = jsonDecode(summaryResponse.body);
      setState(() {
        totalRevenue = summary['revenueToday'];
        employeeCount = summary['employeeCount'];
        menuItemCount = summary['menuItemCount'];
        orderCount = summary['orderCount'];
      });
    } else {
      print('获取总览数据失败');
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
          Text('当天营业额: ${totalRevenue.toStringAsFixed(0)} 元'),
          Text('员工人数: $employeeCount'),
          Text('菜品数量: $menuItemCount'),
          Text('订单数量: $orderCount'),
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserManagePage()), // 跳转到用户管理页面
                );
              },
              child: Text('用户管理'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrderManagePage()), // 跳转到订单管理页面
                );
              },
              child: Text('订单管理'),
            ),
          ],
        ),
      ),
    );
  }
}
