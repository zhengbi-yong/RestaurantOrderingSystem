import 'package:flutter/material.dart';
import 'pages/identity_page.dart';

void main() {
  runApp(ResOrdSys());
}

class ResOrdSys extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '海底世界海景餐厅点餐系统',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IdentityPage(),
    );
  }
}
