import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;

class ProductPrice {
  Future<Map<String, dynamic>> getcategoryitems(String category) async {
    final url = Uri.parse('${Config.apiUrl}${Config.getcategoryAPI}');
    final response = await http.post(url, body: {
      'category': category,
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = json.encode(responseData['data']);

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
