import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../config.dart';
import 'package:http/http.dart' as http;

class POSTransaction {
  Future<Map<String, dynamic>> sending(
      String detailid,
      String date,
      String posid,
      String shift,
      String paymenttype,
      String referenceid,
      String paymentname,
      String items,
      String total,
      String cashier,
      String cash,
      String ecash,
      String branch,
      String discountdetail) async {
    final url = Uri.parse('${Config.apiUrl}${Config.salesDetailAPI}');
    final response = await http.post(url, body: {
      'detailid': detailid,
      'date': date,
      'posid': posid,
      'shift': shift,
      'paymenttype': paymenttype,
      'description': items,
      'total': total,
      'cashier': cashier,
      'paymentname': paymentname,
      'referenceid': referenceid,
      'cash': cash,
      'ecash': ecash,
      'branch': branch,
      'discountdetail': discountdetail
    });

    final responseData = json.decode(response.body);
    final status = response.statusCode;
    final msg = responseData['msg'];

    Map<String, dynamic> data = {};
    data = {'msg': msg, 'status': status};

    return data;
  }
}
