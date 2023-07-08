import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import '../config.dart';

void log(String message) {
  developer.log(message, name: 'RegisterPage');
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String dropdownValue = '顾客';

  Future<void> register(String username, String password) async {
    log('请求注册');
    final response = await http.post(
      Uri.parse('${Config.API_URL}/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'identity': dropdownValue,
      }),
    );
    log('请求注册:用户名($username)密码($password)身份($dropdownValue)');
    log('响应内容:${response.body}');
    log('状态码:${response.statusCode}');
    if (response.statusCode == 200) {
      // 注册成功的操作
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('注册成功'),
          content: Text('用户注册成功，您可以使用新账号登录。'),
          actions: [
            TextButton(
              onPressed: () {
                // 跳转到登录页面
                Navigator.pushNamed(context, '/login');
              },
              child: Text('去登录'),
            ),
          ],
        ),
      );
    } else {
      // 注册失败的操作
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('注册失败'),
          content: Text('用户注册失败，请重试。'),
          actions: [
            TextButton(
              onPressed: () {
                // 添加您想要的操作，如重试注册
                Navigator.pushNamed(context, '/register');
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
    log('注册页构建');
    return Scaffold(
      appBar: AppBar(
        title: Text('注册'),
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
                register(_usernameController.text, _passwordController.text);
              },
              child: Text('注册'),
            ),
          ],
        ),
      ),
    );
  }
}
