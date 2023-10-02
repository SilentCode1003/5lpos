import 'dart:convert';

import '../config.dart';
import 'package:http/http.dart' as http;

class POSShiftLogAPI {
  Future<Map<String, dynamic>> getPOSShift(String posid) async {
    final url = Uri.parse('${Config.apiUrl}${Config.getPOSShiftAPI}');
    final response = await http.post(url, body: {
      'posid': posid,
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> startShift(
      String posid, String cashier, String detailid) async {
    final url = Uri.parse('${Config.apiUrl}${Config.startShiftAPI}');
    final response = await http.post(url, body: {
      'posid': posid,
      'cashier': cashier,
      'receiptbeginning': detailid
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }

  Future<Map<String, dynamic>> endShift(
      String posid, String receiptending) async {
    final url = Uri.parse('${Config.apiUrl}${Config.endShiftAPI}');
    final response = await http
        .post(url, body: {'posid': posid, 'receiptending': receiptending});

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];
    final results = responseData['data'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status, 'data': results};

    return data;
  }
}
