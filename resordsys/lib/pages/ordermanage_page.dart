import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config.dart';

IO.Socket? socket;

void log(String message) {
  developer.log(message, name: 'OrderManagePage');
}

class OrderManagePage extends StatefulWidget {
  @override
  _OrderManagePageState createState() => _OrderManagePageState();
}

class _OrderManagePageState extends State<OrderManagePage> {
  late Future<List> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = fetchOrders();
  }

  Future<List> fetchOrders() async {
    final response = await http.get(Uri.parse('${Config.API_URL}/orders'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    final response = await http.delete(
      Uri.parse('${Config.API_URL}/orders/$orderId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete order');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('订单管理'),
      ),
      body: FutureBuilder<List>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var order = snapshot.data![index];
                return Card(
                  child: ListTile(
                    title: Text('订单 ${order['id']}'),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        await deleteOrder(order['id']);
                        setState(() {
                          snapshot.data!.removeAt(index);
                        });
                      },
                      child: Text('删除'),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
