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
                    title: Text('${order['user']} 的订单'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            var newTotal = await showDialog<double>(
                              context: context,
                              builder: (context) {
                                return _ModifyOrderDialog();
                              },
                            );
                            if (newTotal != null) {
                              await modifyOrder(order['id'], newTotal);
                              setState(() {});
                            }
                          },
                          child: Text('修改'),
                        ),
                        SizedBox(width: 8), // add space between two buttons
                        ElevatedButton(
                          onPressed: () async {
                            await deleteOrder(order['id']);
                            setState(() {
                              snapshot.data!.removeAt(index);
                            });
                          },
                          child: Text('删除'),
                        ),
                      ],
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
