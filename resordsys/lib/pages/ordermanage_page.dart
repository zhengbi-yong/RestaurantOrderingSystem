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
  late Future<Map<String, Map<String, Map<String, List<dynamic>>>>>
      futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = fetchOrders();
  }

  Future<Map<String, Map<String, Map<String, List<dynamic>>>>>
      fetchOrders() async {
    final response = await http.get(Uri.parse('${Config.API_URL}/orders'));
    if (response.statusCode == 200) {
      List ordersList = json.decode(response.body);
      Map<String, Map<String, Map<String, List<dynamic>>>> orders = {};
      for (var order in ordersList) {
        var date = DateTime.parse(order['timestamp']);
        var year = date.year.toString();
        var month = date.month.toString();
        var day = date.day.toString();
        if (!orders.containsKey(year)) {
          orders[year] = {};
        }
        if (!orders[year]!.containsKey(month)) {
          orders[year]![month] = {};
        }
        if (!orders[year]![month]!.containsKey(day)) {
          orders[year]![month]![day] = [];
        }
        orders[year]![month]![day]!.add(order);
      }
      setState(() {}); // Adding this line of code
      return orders;
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> printOrder(int id) async {
    final response = await http.post(
      Uri.parse('${Config.API_URL}/orders/print'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to print order');
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

  Future<void> modifyOrder(int orderId, double total) async {
    var updatedOrder = {
      'total': total, // Updating the order data
      // Other data that needs to be modified
    };

    final response = await http.put(
      Uri.parse('${Config.API_URL}/orders/$orderId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedOrder),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to modify order');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('订单管理'),
      ),
      body: FutureBuilder<Map<String, Map<String, Map<String, List<dynamic>>>>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, yearIndex) {
                var year = snapshot.data!.keys.elementAt(yearIndex);
                return ExpansionTile(
                  title: Text('$year 年',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  children: snapshot.data![year]!.keys.map((month) {
                    return ExpansionTile(
                      title: Text('$month 月',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      children: snapshot.data![year]![month]!.keys.map((day) {
                        return ExpansionTile(
                          title: Text('$day 日',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          children:
                              snapshot.data![year]![month]![day]!.map((order) {
                            return Card(
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ListTile(
                                title: Text('${order['user']} 的订单',
                                    style: TextStyle(color: Colors.blue)),
                                trailing: Row(
                                  // 使得尾部有两个按钮
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return _OrderDetailsDialog(
                                                order: order);
                                          },
                                        );
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.view_list,
                                              color: Colors.white),
                                          Text('详情'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8), // 添加两个按钮之间的空间
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('确认'),
                                              content: Text('您确定要打印此订单吗？'),
                                              actions: [
                                                TextButton(
                                                  child: Text('取消'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('确认'),
                                                  onPressed: () {
                                                    printOrder(order['id']);
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.print,
                                              color: Colors.white),
                                          Text('打印'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8), // 添加两个按钮之间的空间
                                    ElevatedButton(
                                      onPressed: () async {
                                        await deleteOrder(order['id']);
                                        setState(() {
                                          snapshot.data![year]![month]![day]!
                                              .remove(order);
                                        });
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.delete,
                                              color: Colors.white),
                                          Text('删除'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  }).toList(),
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

class _OrderDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderDetailsDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    List<Widget> orderItems =
        (order['items'] as Map<String, dynamic>).entries.map((item) {
      var itemName = item.key;
      var itemDetails = item.value;
      return Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          leading: Icon(Icons.fastfood),
          title: Text(
            '$itemName',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
              '数量: ${itemDetails['count']}, 价格: ${itemDetails['price']} 元, 是否准备: ${itemDetails['isPrepared'] ? '已准备' : '未准备'}, 是否上桌: ${itemDetails['isServed'] ? '已上桌' : '未上桌'}'),
        ),
      );
    }).toList();

    return AlertDialog(
      title: Text('订单详情', style: TextStyle(color: Colors.blue, fontSize: 20)),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('订单编号: ${order['id']}', style: TextStyle(fontSize: 16)),
            Text('用户名: ${order['user']}', style: TextStyle(fontSize: 16)),
            Text('提交时间: ${order['timestamp']}', style: TextStyle(fontSize: 16)),
            Text('总价: ${order['total']} 元',
                style: TextStyle(fontSize: 16, color: Colors.red)),
            Text('订单提交: ${order['isSubmitted'] ? '已提交' : '未提交'}',
                style: TextStyle(fontSize: 16)),
            Text('订单确认: ${order['isConfirmed'] ? '已确认' : '未确认'}',
                style: TextStyle(fontSize: 16)),
            Text('订单完成: ${order['isCompleted'] ? '已完成' : '未完成'}',
                style: TextStyle(fontSize: 16)),
            Text('订单支付: ${order['isPaid'] ? '已支付' : '未支付'}',
                style: TextStyle(fontSize: 16)),
            ...orderItems,
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('关闭'),
        ),
      ],
    );
  }
}
