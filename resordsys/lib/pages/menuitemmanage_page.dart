import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import '../config.dart';

void log(String message) {
  developer.log(message, name: 'MenuItemManagePage');
}

class MenuItemManagePage extends StatefulWidget {
  @override
  _MenuItemManagePageState createState() => _MenuItemManagePageState();
}

class _MenuItemManagePageState extends State<MenuItemManagePage> {
  late Future<List> futureMenuItems;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  // 定义颜色
  final color1 = Color(0xFF1c595a);
  final color2 = Color(0xFF458d8c);
  final color3 = Color(0xFF58a6a6);
  final color4 = Color(0xFF67734d);
  final color5 = Color(0xFFd7d8ac);

  @override
  void initState() {
    super.initState();
    futureMenuItems = fetchMenuItems();
  }

  Future<void> updateMenuItem(
      int itemId, String name, String price, String category) async {
    final response = await http.put(
      Uri.parse('${Config.API_URL}/menu/$itemId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'price': price,
        'category': category, // 添加类别
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update menu item');
    }

    setState(() {
      futureMenuItems = fetchMenuItems();
    });
  }

  Future<List> fetchMenuItems() async {
    final response = await http.get(Uri.parse('${Config.API_URL}/menu'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  Future<void> deleteMenuItem(int itemId) async {
    final response = await http.delete(
      Uri.parse('${Config.API_URL}/menu/$itemId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete menu item');
    }
  }

  Future<void> addMenuItem(String name, String price, String category) async {
    final response = await http.post(
      Uri.parse('${Config.API_URL}/menu'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'price': price,
        'category': category, // 添加类别
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add menu item');
    }

    setState(() {
      futureMenuItems = fetchMenuItems();
    });
  }

  void showUpdateMenuItemDialog(BuildContext context, int itemId, String name,
      String price, String category) {
    _nameController.text = name;
    _priceController.text = price;
    _categoryController.text = category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('修改菜品',
              style: TextStyle(fontSize: 24, color: Colors.orange)), // 添加标题样式
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // 设置弹窗内容最小化
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '菜名', // 使用label代替hint
                    labelStyle: TextStyle(fontSize: 18), // 添加标签样式
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入菜名';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: '价格',
                    labelStyle: TextStyle(fontSize: 18),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入价格';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: '类别',
                    labelStyle: TextStyle(fontSize: 18),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入类别';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消',
                  style: TextStyle(color: Colors.grey[700])), // 修改按钮颜色
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  Text('提交', style: TextStyle(color: Colors.orange)), // 修改按钮颜色
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  updateMenuItem(itemId, _nameController.text,
                      _priceController.text, _categoryController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showAddMenuItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('添加菜品',
              style: TextStyle(fontSize: 24, color: Colors.orange)), // 添加标题样式
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '菜名',
                    labelStyle: TextStyle(fontSize: 18),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入菜名';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: '价格',
                    labelStyle: TextStyle(fontSize: 18),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入价格';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: '类别',
                    labelStyle: TextStyle(fontSize: 18),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入类别';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消',
                  style: TextStyle(color: Colors.grey[700])), // 修改按钮颜色
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  Text('添加', style: TextStyle(color: Colors.orange)), // 修改按钮颜色
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  addMenuItem(_nameController.text, _priceController.text,
                      _categoryController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('菜品管理',
            style: TextStyle(color: color5, fontSize: 20)), // 使用color5作为标题颜色
        backgroundColor: color3, // 使用color3作为AppBar的背景色
      ),
      body: FutureBuilder<List>(
        future: futureMenuItems,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.only(
                  bottom: 70.0), // 在列表底部添加额外的空间，使得浮动按钮不会挡住最后一个列表项
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var menuItem = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0), // 添加卡片边距
                  elevation: 4.0, // 添加卡片阴影
                  child: ListTile(
                    title: Text(
                      menuItem['name'],
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: color2), // 使用color2作为标题颜色
                    ),
                    subtitle: Text(
                      '\$${menuItem['price'].toStringAsFixed(0)} 元',
                      style: TextStyle(color: color4), // 使用color4作为副标题颜色
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: color1, // 使用color1作为修改按钮颜色
                          ),
                          onPressed: () {
                            showUpdateMenuItemDialog(
                                context,
                                menuItem['id'],
                                menuItem['name'],
                                menuItem['price'].toStringAsFixed(0),
                                menuItem['category']);
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.edit,
                                  color: color5), // 使用color5作为修改图标颜色
                              SizedBox(width: 5), // 添加一些空间在图标和文字之间
                              Text('修改',
                                  style: TextStyle(
                                      color: color5)) // 使用color5作为文字颜色
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: color2, // 使用color2作为删除按钮颜色
                          ),
                          onPressed: () async {
                            final confirmDelete = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // 弹出确认删除的对话框
                                return AlertDialog(
                                  title: Text('确认删除'),
                                  content: Text('您确定要删除此菜品吗？'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('取消',
                                          style: TextStyle(
                                              color: color2)), // 使用color2作为按钮颜色
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                    ),
                                    TextButton(
                                      child: Text('确认',
                                          style: TextStyle(
                                              color: color1)), // 使用color1作为按钮颜色
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirmDelete) {
                              await deleteMenuItem(menuItem['id']);
                              setState(() {
                                snapshot.data!.removeAt(index);
                              });
                            }
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.delete,
                                  color: color5), // 使用color5作为删除图标颜色
                              SizedBox(width: 5), // 添加一些空间在图标和文字之间
                              Text('删除',
                                  style: TextStyle(
                                      color: color5)) // 使用color5作为文字颜色
                            ],
                          ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: color1, // 使用color1作为浮动操作按钮的背景色
        onPressed: () {
          showAddMenuItemDialog(context);
        },
        tooltip: 'Add Menu Item',
        child: Icon(Icons.add, color: color5), // 使用color5作为图标颜色
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // 将浮动操作按钮移动到底部中间位置
    );
  }
}
