import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config.dart';

IO.Socket? socket;

void log(String message) {
  developer.log(message, name: 'UserManagePage');
}

class UserManagePage extends StatefulWidget {
  @override
  _UserManagePageState createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  late Future<List> futureUsers;
  final color1 = Color(0xFF1c595a);
  final color2 = Color(0xFF458d8c);
  final color3 = Color(0xFF58a6a6);
  final color4 = Color(0xFF67734d);
  final color5 = Color(0xFFd7d8ac);

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
  }

  Future<List> fetchUsers() async {
    final response = await http.get(Uri.parse('${Config.API_URL}/users'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('${Config.API_URL}/users/$userId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户管理', style: TextStyle(color: color5, fontSize: 20)),
        backgroundColor: color3,
      ),
      body: FutureBuilder<List>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var user = snapshot.data![index];
                return Card(
                  color: color3.withOpacity(0.5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color3,
                      child: Text(
                        user['username'][0].toUpperCase(),
                        style: TextStyle(fontSize: 24.0, color: color5),
                      ),
                    ),
                    title: Text(user['username'],
                        style: TextStyle(color: color5, fontSize: 16)),
                    subtitle: Text('Additional User Info',
                        style: TextStyle(color: color4, fontSize: 14)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: color4,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('确认',
                                  style:
                                      TextStyle(color: color2, fontSize: 20)),
                              content: Text('您确定要删除 ${user['username']}？',
                                  style:
                                      TextStyle(color: color4, fontSize: 16)),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('取消',
                                      style: TextStyle(color: color2)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('删除',
                                      style: TextStyle(color: color2)),
                                  onPressed: () async {
                                    await deleteUser(user['id']);
                                    setState(() {
                                      snapshot.data!.removeAt(index);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
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
