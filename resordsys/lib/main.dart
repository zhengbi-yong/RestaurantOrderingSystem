import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/customer_page.dart';
import 'pages/chef_page.dart';
import 'pages/waiter_page.dart';
import 'pages/boss_page.dart';
import 'pages/register_page.dart';
import 'pages/autologin_page.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'globals.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'dart:convert';

void log(String message) {
  developer.log(message, name: 'ResOrdSys');
}

class LoginInfo with ChangeNotifier {
  String? _username;
  String? _password;
  String dropdownValue = '顾客';
  String? get username => _username;
  String? get password => _password;

  void update(String? username, String? password) {
    _username = username;
    _password = password;
    notifyListeners();
  }
}

void main() {
  final loginInfo = LoginInfo();
  runApp(
    ChangeNotifierProvider(
      create: (context) => loginInfo,
      child: ResOrdSys(loginInfo: loginInfo),
    ),
  );
}

class ResOrdSys extends StatelessWidget {
  final LoginInfo loginInfo;

  ResOrdSys({required this.loginInfo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '餐厅订单系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');
        String? username;
        String? password;
        if (uri.hasQuery) {
          final params = uri.queryParameters;
          if (params.containsKey('username') &&
              params.containsKey('password')) {
            username = params['username'];
            password = params['password'];
            loginInfo.update(username, password);
          }
        }
        switch (uri.path) {
          case '/':
          case '/login':
            return MaterialPageRoute(
              builder: (context) => LoginPage(
                initialUsername: username,
                initialPassword: password,
              ),
            );
          case '/auto_login':
            return MaterialPageRoute(
              builder: (context) => AutoLoginPage(
                initialUsername: username,
                initialPassword: password,
              ),
            );
          case '/chef_page':
            return MaterialPageRoute(
              builder: (context) => ChefPage(),
            );
          case '/waiter_page':
            return MaterialPageRoute(
              builder: (context) => WaiterPage(),
            );
          case '/boss_page':
            return MaterialPageRoute(
              builder: (context) => BossPage(),
            );
          case '/customer_page':
            return MaterialPageRoute(
              builder: (context) => CustomerPage(),
            );
          case '/register':
            return MaterialPageRoute(
              builder: (context) => RegisterPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => LoginPage(
                initialUsername: username,
                initialPassword: password,
              ),
            );
        }
      },
    );
  }
}
