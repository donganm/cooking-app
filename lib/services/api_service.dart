import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchUserRecipes(String userId) async {
    final url = Uri.parse('$baseUrl/recipes/status/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return {
        'approved': [],
        'waiting': [],
        'counts': {'approved': 0, 'waiting': 0},
      };
    } else {
      throw Exception('Lỗi khi lấy dữ liệu bài viết của user: ${response.statusCode}');//debug
    }
  }
}
