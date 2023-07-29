import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_page.dart';
import 'dart:developer' as developer;
import '../config.dart';
import '../globals.dart';
import 'package:provider/provider.dart';
import '../main.dart';

void log(String message) {
  developer.log(message, name: 'LoginPage');
}

class LoginPage extends StatefulWidget {
  final String? initialUsername;
  final String? initialPassword;
  LoginPage({this.initialUsername, this.initialPassword});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final _usernameController;
  late final _passwordController;
  String dropdownValue = '顾客';

  // 定义颜色
  final color1 = Color(0xFF1c595a);
  final color2 = Color(0xFF458d8c);
  final color3 = Color(0xFF58a6a6);
  final color4 = Color(0xFF67734d);
  final color5 = Color(0xFFd7d8ac);

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();

    Future.delayed(Duration.zero, () {
      if (globalUrl != null) {
        final loginInfo = Provider.of<LoginInfo>(context, listen: false);
        final uri = Uri.parse(globalUrl!);
        if (uri.hasQuery) {
          final params = uri.queryParameters;
          if (params.containsKey('username') &&
              params.containsKey('password')) {
            loginInfo.update(params['username'], params['password']);
            login(loginInfo.username!, loginInfo.password!);
            globalUrl = null;
          }
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loginInfo = Provider.of<LoginInfo>(context, listen: false);
    _usernameController.text = loginInfo.username ?? '';
    _passwordController.text = loginInfo.password ?? '';
    if (loginInfo.username != null && loginInfo.password != null) {
      login(loginInfo.username!, loginInfo.password!);
    }
  }

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
      log('登录成功');
      String identity = dropdownValue;
      globalUser = "$username";
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
          log('身份未知');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('登录失败'),
              content: Text('身份未知'),
              actions: [
                TextButton(
                  onPressed: () {
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
      log('登录失败');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('登录失败'),
          content: Text('用户名或密码错误'),
          actions: [
            TextButton(
              onPressed: () {
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
        backgroundColor: color3, // 修改背景颜色
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
              dropdownColor: color5, // 修改下拉菜单颜色
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: '用户名',
                filled: true,
                fillColor: color2, // 修改填充颜色
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: '密码',
                filled: true,
                fillColor: color2, // 修改填充颜色
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  login(_usernameController.text, _passwordController.text);
                },
                child: Text('登录'),
                style: ElevatedButton.styleFrom(
                  primary: color1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text('注册'),
                style: ElevatedButton.styleFrom(
                  primary: color4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
