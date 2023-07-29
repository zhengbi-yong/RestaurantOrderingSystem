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

  final color1 = Color(0xFF1c595a);
  final color2 = Color(0xFF458d8c);
  final color3 = Color(0xFF58a6a6);
  final color4 = Color(0xFF67734d);
  final color5 = Color(0xFFd7d8ac);

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
        totalRevenue = summary['revenueToday'] ?? 0.0;
        employeeCount = summary['employeeCount'] ?? 0;
        menuItemCount = summary['menuItemCount'] ?? 0;
        orderCount = summary['orderCount'] ?? 0;
      });
    } else {
      print('获取总览数据失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('老板', style: TextStyle(color: color5, fontSize: 20)),
        backgroundColor: color3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当天营业额: ${totalRevenue.toStringAsFixed(0)} 元',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color2)),
            SizedBox(height: 10),
            Text('员工人数: $employeeCount',
                style: TextStyle(fontSize: 18, color: color2)),
            SizedBox(height: 10),
            Text('菜品数量: $menuItemCount',
                style: TextStyle(fontSize: 18, color: color2)),
            SizedBox(height: 10),
            Text('订单数量: $orderCount',
                style: TextStyle(fontSize: 18, color: color2)),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: color3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildButton(context, '菜品管理', MenuItemManagePage()),
              buildButton(context, '用户管理', UserManagePage()),
              buildButton(context, '订单管理', OrderManagePage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, String title, Widget page) {
    return Container(
      height: 50,
      width: 120,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Text(title, style: TextStyle(color: color5)),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(color1),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: color1))),
          shadowColor:
              MaterialStateProperty.all<Color>(color1.withOpacity(0.5)),
          elevation: MaterialStateProperty.all<double>(5),
        ),
      ),
    );
  }
}
