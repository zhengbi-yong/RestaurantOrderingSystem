import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaiterPage extends StatefulWidget {
  @override
  _WaiterPageState createState() => _WaiterPageState();
}

class _WaiterPageState extends State<WaiterPage> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/orders/submitted'));
    if (response.statusCode == 200) {
      // print('Orders: ${response.body}');
      setState(() {
        orders = jsonDecode(response.body);
      });
    } else {
      print('Failed to fetch orders');
    }
  }

  Future<void> confirmOrder(int id) async {
    print('Order ID: $id');
    final response = await http.post(
      Uri.parse('http://localhost:5000/orders/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    if (response.statusCode == 200) {
      fetchOrders();
    } else {
      print('Failed to confirm order');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiter Page'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (ctx, index) {
          final order = orders[index];
          return ExpansionTile(
            title: Text('Order ${order['id']}'),
            children: [
              ...(order['items'] as Map<String, dynamic>).entries.map((item) {
                return ListTile(
                  title: Text(item.key),
                  subtitle:
                      Text('${item.value['count']} x \$${item.value['price']}'),
                  trailing: Text(item.value['status'] == 'completed'
                      ? 'Completed'
                      : 'Pending'),
                );
              }).toList(),
              ElevatedButton(
                onPressed: () => confirmOrder(order['id']),
                child: Text('Confirm Order'),
              ),
              Text(
                  'Status: ${order['isSubmitted'] ? 'Submitted' : 'Not submitted'} / ${order['isConfirmed'] ? 'Confirmed' : 'Not confirmed'} / ${order['isCompleted'] ? 'Completed' : 'Not completed'}'),
            ],
          );
        },
      ),
    );
  }
}
