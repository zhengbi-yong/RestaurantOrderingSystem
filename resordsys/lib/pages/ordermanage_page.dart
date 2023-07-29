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
  Map<String, Map<String, Map<String, List<dynamic>>>>? orders;
  final color1 = Color(0xFF1c595a);
  final color2 = Color(0xFF458d8c);
  final color3 = Color(0xFF58a6a6);
  final color4 = Color(0xFF67734d);
  final color5 = Color(0xFFd7d8ac);

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

  Future<bool> deleteOrder(int orderId) async {
    final response = await http.delete(
      Uri.parse('${Config.API_URL}/orders/$orderId'),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete order');
    }
  }

// 在 deleteOrderLocally 中不再更新 futureOrders
  void deleteOrderLocally(int orderId, String year, String month, String day) {
    if (orders != null) {
      setState(() {
        orders![year]![month]![day]!
            .removeWhere((order) => order['id'] == orderId);
      });
    }
  }

  Future<void> handleDeleteOrder(
      int orderId, String year, String month, String day) async {
    var success = await deleteOrder(orderId);
    if (success) {
      deleteOrderLocally(orderId, year, month, day);
      // 重新获取一次订单
      setState(() {
        futureOrders = fetchOrders();
      });
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
        title: Text('订单管理',
            style: TextStyle(color: color5, fontSize: 20)), // 修改标题颜色和字体大小
        backgroundColor: color3, // 修改App Bar背景颜色
      ),
      body: FutureBuilder<Map<String, Map<String, Map<String, List<dynamic>>>>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!;
            var years = data.keys.toList();
            return ListView.builder(
              itemCount: years.length,
              itemBuilder: (context, yearIndex) {
                var year = years[yearIndex];
                var months = data[year]!.keys.toList();
                return ExpansionTile(
                  title: Text('$year 年',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  children: months.map((month) {
                    var days = data[year]![month]!.keys.toList();
                    return ExpansionTile(
                      title: Text('$month 月',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      children: days.map((day) {
                        var orders = data[year]![month]![day]!;
                        return ExpansionTile(
                          title: Text('$day 日',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: orders.length,
                              itemBuilder: (context, orderIndex) {
                                return OrderItemCard(
                                  order: orders[orderIndex],
                                  printOrder: printOrder,
                                  deleteOrder: deleteOrder,
                                  deleteOrderLocally: deleteOrderLocally,
                                  handleDeleteOrder: handleDeleteOrder,
                                  year: year,
                                  month: month,
                                  day: day,
                                );
                              },
                            ),
                          ],
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
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

const color1 = Color(0xFF1c595a);
const color2 = Color(0xFF458d8c);
const color3 = Color(0xFF58a6a6);
const color4 = Color(0xFF67734d);
const color5 = Color(0xFFd7d8ac);

class OrderItemCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(int) printOrder;
  final Function(int) deleteOrder;
  final Function(int, String, String, String) deleteOrderLocally;
  final Function(int, String, String, String) handleDeleteOrder;
  final String year;
  final String month;
  final String day;

  const OrderItemCard({
    required this.order,
    required this.printOrder,
    required this.deleteOrder,
    required this.deleteOrderLocally,
    required this.handleDeleteOrder,
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        title: Text('${order['user']} 的订单',
            style: TextStyle(color: color2)), // 修改订单用户的颜色
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _OrderDetailsDialog(order: order);
                  },
                );
              },
              child: Row(
                children: [
                  Icon(Icons.view_list, color: color5),
                  Text('详情', style: TextStyle(color: color5)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                primary: color1, // 修改按钮背景颜色
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
              child: Row(
                children: [
                  Icon(Icons.print, color: color5),
                  Text('打印', style: TextStyle(color: color5)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                primary: color1, // 修改按钮背景颜色
              ),
            ),
            const SizedBox(width: 8), // 添加两个按钮之间的空间
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('确认删除'),
                      content: Text('您确定要删除此订单吗？'),
                      actions: [
                        TextButton(
                          child: Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('删除'),
                          onPressed: () async {
                            await handleDeleteOrder(
                                order['id'], year, month, day);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                children: [
                  Icon(Icons.delete, color: color5),
                  Text('删除', style: TextStyle(color: color5)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                primary: color1, // 修改按钮背景颜色
              ),
            ),
          ],
        ),
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
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color2), // 修改了菜品名称颜色
          ),
          subtitle: Text(
            '数量: ${itemDetails['count']}, 价格: ${itemDetails['price']} 元, 是否准备: ${itemDetails['isPrepared'] ? '已准备' : '未准备'}, 是否上桌: ${itemDetails['isServed'] ? '已上桌' : '未上桌'}',
            style: TextStyle(color: color3), // 修改了菜品详细信息颜色
          ),
        ),
      );
    }).toList();

    return AlertDialog(
      title: Text('订单详情',
          style: TextStyle(color: color2, fontSize: 20)), // 修改了对话框标题颜色
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('订单编号: ${order['id']}',
                style: TextStyle(fontSize: 16, color: color3)), // 修改了订单编号颜色
            Text('用户名: ${order['user']}',
                style: TextStyle(fontSize: 16, color: color3)), // 修改了用户名颜色
            Text('提交时间: ${order['timestamp']}',
                style: TextStyle(fontSize: 16, color: color3)), // 修改了提交时间颜色
            Text('总价: ${order['total']} 元',
                style: TextStyle(fontSize: 16, color: Colors.red)), // 总价颜色保持不变
            Text('订单提交: ${order['isSubmitted'] ? '已提交' : '未提交'}',
                style: TextStyle(fontSize: 16, color: color3)), // 修改了订单提交状态颜色
            Text('订单确认: ${order['isConfirmed'] ? '已确认' : '未确认'}',
                style: TextStyle(fontSize: 16, color: color3)), // 修改了订单确认状态颜色
            Text('订单完成: ${order['isCompleted'] ? '已完成' : '未完成'}',
                style: TextStyle(fontSize: 16, color: color3)), // 修改了订单完成状态颜色
            Text('订单支付: ${order['isPaid'] ? '已支付' : '未支付'}',
                style: TextStyle(fontSize: 16, color: color3)), // 修改了订单支付状态颜色
            ...orderItems,
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('关闭', style: TextStyle(color: color5)), // 修改了按钮文字颜色
          style: TextButton.styleFrom(
            primary: color1, // 修改了按钮背景颜色
          ),
        ),
      ],
    );
  }
}
