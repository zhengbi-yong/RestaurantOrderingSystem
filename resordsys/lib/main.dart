import 'package:flutter/material.dart';
// import 'pages/identity_page.dart';
import 'pages/login_page.dart';
import 'pages/customer_page.dart';
import 'pages/chef_page.dart';
import 'pages/waiter_page.dart';
import 'pages/boss_page.dart';
import 'dart:developer' as developer;

void main() {
  runApp(ResOrdSys());
}

void log(String message) {
  developer.log(message, name: 'ResOrdSys');
}

class ResOrdSys extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    log("应用程序开始构建");
    return MaterialApp(
      title: '海底世界海景餐厅点餐系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(), // 设置根路由，此处为登录页
        '/customer_page': (context) => CustomerPage(),
        '/chef_page': (context) => ChefPage(),
        '/waiter_page': (context) => WaiterPage(),
        '/boss_page': (context) => BossPage(),
        // 添加其他需要的命名路由
      },
    );
  }
}
