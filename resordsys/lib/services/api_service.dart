import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:resordsys/models/menu_item.dart';

class ApiService {
  final String baseUrl = "http://your_backend_ip:5000";

  Future<List<MenuItem>> getMenuItems() async {
    final response = await http.get(Uri.parse('$baseUrl/menu_items'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => MenuItem.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load menu items.");
    }
  }
}
