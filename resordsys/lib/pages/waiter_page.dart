import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config.dart';
import 'waiterorder_page.dart';
import 'editorder_page.dart';
import 'ordermanage_page.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

IO.Socket? socket;

void log(String message) {
  developer.log(message, name: 'WaiterPage');
}

class WaiterPage extends StatefulWidget {
  @override
  _WaiterPageState createState() => _WaiterPageState();
}

class _WaiterPageState extends State<WaiterPage> {
  List<dynamic> orders = [];
  late Future<pw.Font> _font;
  // 定义颜色
  final color1 = Color(0xFF1c595a);
  final color2 = Color(0xFF458d8c);
  final color3 = Color(0xFF58a6a6);
  final color4 = Color(0xFF67734d);
  final color5 = Color(0xFFd7d8ac);
  @override
  void initState() {
    super.initState();
    fetchOrders();
    _font = loadFont();
    socket = IO.io('${Config.API_URL}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();

    socket?.on('new order', (_) {
      fetchOrders();
    });
    socket?.on('dish prepared', (_) {
      fetchOrders();
    });
    socket?.on('order confirmed', (_) {
      fetchOrders();
    });
    socket?.on('dish served', (_) {
      fetchOrders();
    });
    socket?.on('delete order', (_) {
      fetchOrders();
    });
    socket?.on('order modified', (_) {
      fetchOrders();
    });
    socket?.on('order paid', (_) {
      fetchOrders();
    });
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    final response =
        await http.get(Uri.parse('${Config.API_URL}/orders/submitted'));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          orders = jsonDecode(response.body);
        });
      }
    } else {
      print('获取订单列表失败');
    }
  }

  Future<pw.Font> loadFont() async {
    final fontData = await rootBundle.load("assets/CN.ttf");
    return pw.Font.ttf(fontData);
  }

  Future<pw.Document> generateOrderPdf(
      int id, Map<String, dynamic> order, pw.Font font) async {
    final pw.Document pdf = pw.Document();

    // Calculate the total and get the items data
    double total = 0;
    List<pw.Widget> items = [];
    for (var item in order['items'].entries) {
      total += item.value['count'] * item.value['price'];
      items.add(_buildItem(item, font));
    }

    // Add the header
    List<pw.Widget> header = _buildHeader(id, order, font, total);

    // Combine the header and the first 9 items for the first page
    List<pw.Widget> firstPageData = [
      ...header,
      pw.SizedBox(height: 20),
      ...items.take(15)
    ];

    // Generate the first page
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(10.0), // Add padding to the page
          child: pw.Row(
            children: [
              pw.Expanded(child: pw.Column(children: firstPageData)),
              pw.SizedBox(width: 30), // Add a space between the columns
              pw.Expanded(child: pw.Column(children: firstPageData)),
            ],
          ),
        ),
      ),
    );

    // Calculate the number of remaining pages
    final numPages = ((items.length - 15) / 15).ceil();

    // Generate the remaining pages
    for (var i = 0; i < numPages; i++) {
      // Get the data for this page
      final pageItems = items.skip(15 + i * 15).take(15).toList();

      // Combine the header and the items for this page
      List<pw.Widget> pageData = [
        ...header,
        pw.SizedBox(height: 20),
        ...pageItems
      ];

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Padding(
            padding: const pw.EdgeInsets.all(10.0), // Add padding to the page
            child: pw.Row(
              children: [
                pw.Expanded(child: pw.Column(children: pageData)),
                pw.SizedBox(width: 30), // Add a space between the columns
                pw.Expanded(child: pw.Column(children: pageData)),
              ],
            ),
          ),
        ),
      );
    }

    return pdf;
  }

  List<pw.Widget> _buildHeader(
      int id, Map<String, dynamic> order, pw.Font font, double total) {
    return [
      pw.Text('顾客: ${order['user']}',
          style: pw.TextStyle(fontSize: 40, font: font)),
      pw.Text('订单编号: $id', style: pw.TextStyle(fontSize: 30, font: font)),
      pw.Text('订单总价: $total 元', style: pw.TextStyle(fontSize: 20, font: font)),
      pw.SizedBox(height: 20),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('菜品名称', style: pw.TextStyle(fontSize: 20, font: font)),
          pw.Text('数量', style: pw.TextStyle(fontSize: 20, font: font)),
          pw.Text('单价', style: pw.TextStyle(fontSize: 20, font: font)),
        ],
      ),
      pw.SizedBox(height: 10),
    ];
  }

  pw.Widget _buildItem(MapEntry<String, dynamic> item, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('${item.key}', style: pw.TextStyle(fontSize: 20, font: font)),
        pw.Text('${item.value['count']}',
            style: pw.TextStyle(fontSize: 20, font: font)),
        pw.Text('${item.value['price']} 元',
            style: pw.TextStyle(fontSize: 20, font: font)),
      ],
    );
  }

  Future<void> confirmOrder(int id) async {
    final response = await http.post(
      Uri.parse('${Config.API_URL}/orders/confirm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    if (response.statusCode == 200) {
      fetchOrders();
    } else {
      print('确认订单失败');
    }
  }

  Future<void> serveItem(int orderId, String itemName) async {
    final response = await http.post(
      Uri.parse('${Config.API_URL}/orders/serve_item'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId, 'itemName': itemName}),
    );
    if (response.statusCode == 200) {
      fetchOrders();
    } else {
      print('上菜失败');
    }
  }

  Future<void> payOrder(int id) async {
    final response = await http.post(
      Uri.parse('${Config.API_URL}/orders/pay'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    if (response.statusCode == 200) {
      fetchOrders();
    } else {
      print('支付订单失败');
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

  ButtonStyle _createButtonStyle(Color color) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(color),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(color: color),
        ),
      ),
      elevation: MaterialStateProperty.all(10),
      padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(horizontal: 30, vertical: 20)), // 增大垂直内边距
      textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('服务员',
            style: TextStyle(color: color5, fontSize: 20)), // 修改标题颜色和字体大小
        backgroundColor: color3, // 修改App Bar背景颜色
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (ctx, index) {
          final order = orders[index];

          bool allItemsPreparedAndServed =
              (order['items'] as Map<String, dynamic>)
                  .values
                  .every((item) => item['isPrepared'] && item['isServed']);

          if (order['isSubmitted'] &&
              order['isConfirmed'] &&
              order['isCompleted'] &&
              order['isPaid'] &&
              allItemsPreparedAndServed) {
            return SizedBox.shrink();
          }

          return Card(
            child: ExpansionTile(
              title: Text('${order['user']} 的订单'),
              children: [
                ...(order['items'] as Map<String, dynamic>).entries.map((item) {
                  IconData icon;
                  if (!item.value['isPrepared']) {
                    icon = Icons.hourglass_empty;
                  } else if (item.value['isPrepared'] &&
                      !item.value['isServed']) {
                    icon = Icons.hourglass_bottom;
                  } else {
                    icon = Icons.check_circle;
                  }

                  return ListTile(
                    leading: Icon(icon),
                    title: Text(item.key,
                        style: TextStyle(color: color2)), // 使用 color2
                    subtitle: Text(
                        '${item.value['count']} x \$${item.value['price']}',
                        style: TextStyle(color: color2)), // 使用 color2
                    trailing: item.value['isPrepared'] &&
                            !item.value['isServed']
                        ? ElevatedButton(
                            onPressed: () => serveItem(order['id'], item.key),
                            child: Text('确认上菜'),
                          )
                        : null,
                  );
                }).toList(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // 设置滚动方向为水平方向
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditOrderPage(order)),
                          ).then((_) {
                            fetchOrders();
                          });
                        },
                        child: Text('修改订单'),
                        style: _createButtonStyle(color1),
                      ),
                      ElevatedButton(
                        onPressed: () => confirmOrder(order['id']),
                        child: Text('确认订单'),
                        style: _createButtonStyle(color3),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final font = await _font;
                          final pdf =
                              await generateOrderPdf(order['id'], order, font);
                          final bytes = await pdf.save();
                          Printing.layoutPdf(
                            onLayout: (PdfPageFormat format) async => bytes,
                            name: 'order_${order['id']}.pdf',
                            format: PdfPageFormat.a4,
                          );
                        },
                        child: Text('本地打印'),
                        style: _createButtonStyle(color4),
                      ),
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
                                      printOrder(order['id'])
                                          .catchError((error) {
                                        print(error);
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('远程打印'),
                        style: _createButtonStyle(Colors.orange),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: new Text("确认付款"),
                                content: new Text("你确定要确认付款吗？"),
                                actions: <Widget>[
                                  new TextButton(
                                    child: new Text("取消"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  new TextButton(
                                    child: new Text("确认"),
                                    onPressed: () {
                                      payOrder(order['id']);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('确认付款'),
                        style: _createButtonStyle(Colors.red),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20), // Increased spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        height: screenHeight * 0.08, // Increased height
                        margin: EdgeInsets.symmetric(
                            horizontal: 10), // Added horizontal margin
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: color4, // 使用 color4
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            // Added shadow
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                '订单状态',
                                style: TextStyle(
                                  fontSize: screenHeight *
                                      0.020, // Decreased font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 5), // Added spacing
                            Flexible(
                              child: Text(
                                '${order['isSubmitted'] ? '已提交' : '未提交'} / ${order['isConfirmed'] ? '已确认' : '未确认'} / ${order['isCompleted'] ? '已完成' : '未完成'} / ${order['isPaid'] ? '已付款' : '未付款'}',
                                style: TextStyle(
                                  fontSize: screenHeight *
                                      0.012, // Decreased font size
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        height: screenHeight * 0.08, // Increased height
                        margin: EdgeInsets.symmetric(
                            horizontal: 10), // Added horizontal margin
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: color3, // 使用 color3
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            // Added shadow
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              spreadRadius: 0,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                '订单总额',
                                style: TextStyle(
                                  fontSize: screenHeight *
                                      0.020, // Decreased font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 5), // Added spacing
                            Flexible(
                              child: Text(
                                '${order['total']} 元',
                                style: TextStyle(
                                  fontSize: screenHeight *
                                      0.022, // Decreased font size
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20), // Increased spacing
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: color3, // 使用 color3
        child: Container(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 50,
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderManagePage()),
                    );
                  },
                  child: Text('订单管理'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(color1), // 使用 color1
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: color1), // 使用 color1
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WaiterOrderPage()),
                    );
                  },
                  child: Text('帮忙点菜'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(color5), // 使用 color5
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: color5), // 使用 color5
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
