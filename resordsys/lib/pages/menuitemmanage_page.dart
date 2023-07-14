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
            style: TextStyle(color: Colors.white, fontSize: 20)), // 添加文本样式
        backgroundColor: Colors.orange, // 修改 AppBar 的背景色
      ),
      body: FutureBuilder<List>(
        future: futureMenuItems,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
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
                          fontWeight: FontWeight.bold), // 修改文本样式
                    ),
                    subtitle: Text(
                      '\$${menuItem['price'].toStringAsFixed(0)} 元',
                      style: TextStyle(color: Colors.red), // 修改文本样式
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red, // 修改按钮颜色
                          ),
                          onPressed: () async {
                            await deleteMenuItem(menuItem['id']);
                            setState(() {
                              snapshot.data!.removeAt(index);
                            });
                          },
                          child: Text('删除'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue, // 修改按钮颜色
                          ),
                          onPressed: () {
                            showUpdateMenuItemDialog(
                                context,
                                menuItem['id'],
                                menuItem['name'],
                                menuItem['price'].toStringAsFixed(0),
                                menuItem['category']);
                          },
                          child: Text('修改'),
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
        backgroundColor: Colors.orange, // 修改 FloatingActionButton 的背景色
        onPressed: () {
          showAddMenuItemDialog(context);
        },
        tooltip: 'Add Menu Item',
        child: Icon(Icons.add),
      ),
    );
  }
}
