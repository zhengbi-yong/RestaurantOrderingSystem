import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_page.dart'; // 需要导入新的register_page

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String dropdownValue = '顾客';

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // 登录成功的操作
      String identity = dropdownValue;
      switch (identity) {
        case '顾客':
          Navigator.pushNamed(context, '/customer_page');
          break;
        case '厨师':
          Navigator.pushNamed(context, '/chef_page');
          break;
        case '服务员':
          Navigator.pushNamed(context, '/waiter_page');
          break;
        case '老板':
          Navigator.pushNamed(context, '/boss_page');
          break;
        default:
          // 处理未知身份的情况，例如显示错误消息或其他操作
          break;
      }
    } else {
      // 登录失败的操作
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('Failed to login.'),
          actions: [
            TextButton(
              onPressed: () {
                // 添加您想要的操作，如重试登录
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                }
              },
              items: <String>['顾客', '厨师', '服务员', '老板']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(hintText: 'Enter your username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(hintText: 'Enter your password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                login(_usernameController.text, _passwordController.text);
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterPage()), // 点击注册按钮跳转到注册页面
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
