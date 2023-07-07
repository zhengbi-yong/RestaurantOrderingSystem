import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'menuitemmanage_page.dart';
import 'dart:developer' as developer;

void log(String message) {
  developer.log(message, name: 'BossPage');
}

class BossPage extends StatefulWidget {
  @override
  _BossPageState createState() => _BossPageState();
}

class _BossPageState extends State<BossPage> {
  List<dynamic> orders = [];
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response =
        await http.get(Uri.parse('http://8.134.163.125:5000/orders'));
    // print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
        totalRevenue = orders.fold(0.0, (sum, item) => sum + item['total']);
      });
    } else {
      print('Failed to fetch orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boss Page'),
      ),
      body: Column(
        children: [
          Text('Total Revenue: \$${totalRevenue.toStringAsFixed(2)}'),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (ctx, index) {
                final order = orders[index];
                return ExpansionTile(
                  title: Text('Order from ${order['user']}'),
                  subtitle:
                      Text('Total: \$${order['total'].toStringAsFixed(2)}'),
                  children: (order['items'] as Map<String, dynamic>)
                      .entries
                      .map<Widget>((item) {
                    return ListTile(
                      title: Text(item.key),
                      subtitle: Text(
                          'Price: \$${item.value['price'].toStringAsFixed(2)}, Quantity: ${item.value['count']}'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuItemManagePage()),
                );
              },
              child: Text('菜品管理'),
            ),
          ],
        ),
      ),
    );
  }
}
