import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'customer_page.dart';
import 'boss_page.dart';
import 'waiter_page.dart';
import 'chef_page.dart';

class IdentityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('请选择你的身份'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CustomerPage()));
              },
              child: Text('顾客'),
            ),
            ElevatedButton(
              onPressed: () {
                // 导航到厨师页面
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChefPage()));
              },
              child: Text('厨师'),
            ),
            ElevatedButton(
              onPressed: () {
                // 导航到服务员页面
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WaiterPage()));
              },
              child: Text('服务员'),
            ),
            ElevatedButton(
              onPressed: () {
                // 导航到老板页面
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BossPage()));
              },
              child: Text('老板'),
            ),
          ],
        ),
      ),
    );
  }
}
