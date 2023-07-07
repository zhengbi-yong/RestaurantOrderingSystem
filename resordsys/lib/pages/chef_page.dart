import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'menuitemmanage_page.dart';
import 'dart:developer' as developer;

void log(String message) {
  developer.log(message, name: 'ChefPage');
}

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
        await http.get(Uri.parse('http://8.134.163.125:5000/orders/confirmed'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> completeOrderItem(int orderId, String itemName) async {
    final response = await http.post(
      Uri.parse('http://8.134.163.125:5000/orders/complete_item'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId, 'itemName': itemName}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to complete order item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('厨师'),
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
                                    // 如果所有的菜品都已经完成，那么订单就从列表中移除
                                    if (order['items'].values.every(
                                        (item) => item['isPrepared'] == true)) {
                                      setState(() {
                                        snapshot.data!.removeAt(index);
                                      });
                                    } else {
                                      setState(() {
                                        itemDetails['isPrepared'] = true;
                                      });
                                    }
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
