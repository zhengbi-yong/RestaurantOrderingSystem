import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChefPage extends StatefulWidget {
  @override
  _ChefPageState createState() => _ChefPageState();
}

class _ChefPageState extends State<ChefPage> {
  late Future<List> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = fetchOrders();
  }

  Future<List> fetchOrders() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/orders/confirmed'));
    if (response.statusCode == 200) {
      // print(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> completeOrderItem(int orderId, String itemName) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/orders/complete_item'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId, 'itemName': itemName}),
    );
    print('Server response: ${response.body}'); // 新添加的打印语句
    if (response.statusCode != 200) {
      throw Exception('Failed to complete order item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chef Page'),
      ),
      body: FutureBuilder<List>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var order = snapshot.data![index];
                return Material(
                  color: Colors.transparent,
                  child: ExpansionTile(
                    title: Text('Order #${order['id']}'),
                    children: order['items'].entries.map<Widget>((itemEntry) {
                      var itemName = itemEntry.key;
                      var itemDetails = itemEntry.value;
                      return Card(
                        child: ListTile(
                          title: Text(itemName),
                          subtitle:
                              Text(itemDetails['isPrepared'] ? '已完成' : '未完成'),
                          trailing: !itemDetails['isPrepared']
                              ? ElevatedButton(
                                  onPressed: () async {
                                    await completeOrderItem(
                                        order['id'], itemName);
                                    setState(() {
                                      itemDetails['isPrepared'] = true;
                                      futureOrders = fetchOrders(); // 更新订单列表
                                    });
                                  },
                                  child: Text('确认完成'),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
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
