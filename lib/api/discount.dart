import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;

class DiscountAPI {
  Future<Map<String, dynamic>> getDiscountRate(String type) async {
    final url = Uri.parse('${Config.apiUrl}${Config.discountRateAPI}');
    final response = await http.post(url, body: {'name': type});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> getDiscount() async {
    final url = Uri.parse('${Config.apiUrl}${Config.getDiscountAPI}');
    final response = await http.get(url);

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
