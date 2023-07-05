import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String dropdownValue = '顾客';

  Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
        'identity': dropdownValue,
      }),
    );

    if (response.statusCode == 200) {
      // 注册成功的操作
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registration Successful'),
          content: Text('User registered successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                // 添加您想要的操作，如导航到其他页面
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // 注册失败的操作
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Registration Failed'),
          content: Text('Failed to register user.'),
          actions: [
            TextButton(
              onPressed: () {
                // 添加您想要的操作，如重试注册
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
        title: Text('Register'),
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
                register(_usernameController.text, _passwordController.text);
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
