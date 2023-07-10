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

// class ResOrdSys extends StatefulWidget {
//   final LoginInfo loginInfo;

//   ResOrdSys({required this.loginInfo});

//   @override
//   _ResOrdSysState createState() => _ResOrdSysState();
// }

// class _ResOrdSysState extends State<ResOrdSys> {
//   String? previousRoute;

//   @override
//   Widget build(BuildContext context) {
//     String currentRoute = ModalRoute.of(context)?.settings.name ?? '/';
//     if (currentRoute != previousRoute) {
//       previousRoute = currentRoute;
//       var uri = Uri.parse(currentRoute);
//       if (uri.hasQuery) {
//         if (uri.queryParameters.containsKey('username') &&
//             uri.queryParameters.containsKey('password')) {
//           widget.loginInfo.update(
//               uri.queryParameters['username'], uri.queryParameters['password']);
//         }
//       }
//     }
//     return MaterialApp(
//       title: '餐厅订单系统',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => LoginPage(),
//         '/login': (context) => LoginPage(),
//         '/auto_login': (context) => AutoLoginPage(),
//         '/chef_page': (context) => ChefPage(),
//         '/waiter_page': (context) => WaiterPage(),
//         '/boss_page': (context) => BossPage(),
//         '/customer_page': (context) => CustomerPage(),
//         '/register': (context) => RegisterPage(),
//       },
//       onUnknownRoute: (RouteSettings settings) {
//         final uri = Uri.parse(settings.name ?? '/');
//         String? username;
//         String? password;
//         if (uri.hasQuery) {
//           final params = uri.queryParameters;
//           if (params.containsKey('username') &&
//               params.containsKey('password')) {
//             username = params['username'];
//             password = params['password'];
//             widget.loginInfo.update(username, password);
//           }
//         }
//         return MaterialPageRoute(
//           builder: (context) => Builder(
//             builder: (BuildContext context) {
//               return LoginPage(
//                 initialUsername: username,
//                 initialPassword: password,
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
