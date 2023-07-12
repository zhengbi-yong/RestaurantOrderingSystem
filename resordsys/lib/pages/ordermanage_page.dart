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
      setState(() {}); // 添加这行代码
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
      'total': total, // 更新订单的数据
      // 其他需要修改的数据
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
                  title: Text('$year 年'),
                  children: snapshot.data![year]!.keys.map((month) {
                    return ExpansionTile(
                      title: Text('$month 月'),
                      children: snapshot.data![year]![month]!.keys.map((day) {
                        return ExpansionTile(
                          title: Text('$day 日'),
                          children:
                              snapshot.data![year]![month]![day]!.map((order) {
                            return ListTile(
                              title: Text('${order['user']} 的订单'),
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
                                    child: Text('详情'),
                                  ),
                                  SizedBox(width: 8), // 添加两个按钮之间的空间
                                  ElevatedButton(
                                    onPressed: () => printOrder(order['id']),
                                    child: Text('打印'),
                                  ),
                                  SizedBox(width: 8), // 添加两个按钮之间的空间
                                  ElevatedButton(
                                    onPressed: () async {
                                      await deleteOrder(order['id']);
                                      setState(() {
                                        snapshot.data![year]![month]![day]!
                                            .remove(order);
                                      });
                                    },
                                    child: Text('删除'),
                                  ),
                                ],
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

class _ModifyOrderDialog extends StatefulWidget {
  @override
  __ModifyOrderDialogState createState() => __ModifyOrderDialogState();
}

class __ModifyOrderDialogState extends State<_ModifyOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  late double _total;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('修改订单'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入一个数字';
            }
            try {
              _total = double.parse(value);
            } catch (e) {
              return '请输入一个有效的数字';
            }
            return null;
          },
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_total);
            }
          },
          child: Text('确认'),
        ),
      ],
    );
  }
}

class _OrderDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> order;

  _OrderDetailsDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    List<Widget> orderItems =
        (order['items'] as Map<String, dynamic>).entries.map((item) {
      var itemName = item.key;
      var itemDetails = item.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$itemName, 数量: ${itemDetails['count']}, 价格: ${itemDetails['price']} 元',
            style: TextStyle(color: Colors.blue), // Change color to blue
          ),
          Text(
              '是否准备: ${itemDetails['isPrepared'] ? '已准备' : '未准备'}, 是否上桌: ${itemDetails['isServed'] ? '已上桌' : '未上桌'}'),
        ],
      );
    }).toList();

    return AlertDialog(
      title: Text('订单详情'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('订单编号: ${order['id']}'),
            Text('用户名: ${order['user']}'),
            Text('提交时间: ${order['timestamp']}'),
            Text('总价: ${order['total']} 元'),
            Text('订单提交: ${order['isSubmitted'] ? '已提交' : '未提交'}'),
            Text('订单确认: ${order['isConfirmed'] ? '已确认' : '未确认'}'),
            Text('订单完成: ${order['isCompleted'] ? '已完成' : '未完成'}'),
            Text('订单支付: ${order['isPaid'] ? '已支付' : '未支付'}'),
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
