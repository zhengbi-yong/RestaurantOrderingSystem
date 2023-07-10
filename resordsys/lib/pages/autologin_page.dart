import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_page.dart';
import 'dart:developer' as developer;
import '../config.dart';
import '../globals.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'login_page.dart';

class AutoLoginPage extends StatefulWidget {
  final String? initialUsername;
  final String? initialPassword;

  AutoLoginPage({this.initialUsername, this.initialPassword});
  @override
  _AutoLoginPageState createState() => _AutoLoginPageState();
}

class _AutoLoginPageState extends State<AutoLoginPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final loginInfo = Provider.of<LoginInfo>(context, listen: false);
      var uri = Uri.parse(globalUrl ?? 'http://localhost');
      if (uri.hasQuery) {
        if (uri.queryParameters.containsKey('username') &&
            uri.queryParameters.containsKey('password')) {
          loginInfo.update(
              uri.queryParameters['username'], uri.queryParameters['password']);
        }
      }
      if (loginInfo.username != null && loginInfo.password != null) {
        _login(context);
      }
    });
  }

  Future<void> _login(BuildContext context) async {
    final loginInfo = Provider.of<LoginInfo>(context, listen: false);
    var client = http.Client();
    try {
      var uriResponse = await client.post(
        Uri.parse('${Config.API_URL}/login'),
        body: {
          'username': loginInfo.username,
          'password': loginInfo.password,
        },
      );
      var response = jsonDecode(uriResponse.body);
      if (response['status'] == 'ok') {
        Navigator.pushNamed(context, '/customer_page');
      } else {
        // Handle error...
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return a loading screen while the automatic login is in progress
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
