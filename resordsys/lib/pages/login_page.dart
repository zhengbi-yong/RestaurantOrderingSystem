import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_page.dart';
import 'dart:developer' as developer;
import '../config.dart';

void log(String message) {
  developer.log(message, name: 'LoginPage');
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String dropdownValue = '顾客';

  Future<void> login(String username, String password) async {
    log('请求登录');
    final response = await http.post(
      Uri.parse('${Config.API_URL}/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'identity': dropdownValue,
      }),
    );
    log('请求登录:用户名($username) 密码($password) 身份($dropdownValue)');
    log('响应内容:${response.body}');
    log('状态码:${response.statusCode}');
    if (response.statusCode == 200) {
      // 登录成功的操作
      log('登录成功');
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
          log('身份未知');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('登录失败'),
              content: Text('身份未知'),
              actions: [
                TextButton(
                  onPressed: () {
                    // 重试登录
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('重新登录'),
                ),
              ],
            ),
          );
          break;
      }
    } else {
      // 登录失败的操作
      log('登录失败');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('登录失败'),
          content: Text('用户名或密码错误'),
          actions: [
            TextButton(
              onPressed: () {
                // 添加您想要的操作，如重试登录
                Navigator.pushNamed(context, '/login');
              },
              child: Text('重新登录'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    log('登录页构建');
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
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
              decoration: InputDecoration(hintText: '用户名'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(hintText: '密码'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                login(_usernameController.text, _passwordController.text);
              },
              child: Text('登录'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterPage()), // 点击注册按钮跳转到注册页面
                );
              },
              child: Text('注册'),
            ),
          ],
        ),
      ),
    );
  }
}
