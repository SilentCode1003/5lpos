import 'package:flutter/services.dart';

class UsbPrinterWindows {
  static const MethodChannel _channel = MethodChannel('usb_printer_windows',);

  static Future<String?> printData(String data) async {
    try {
      final String result = await _channel.invokeMethod('printData', data);

      return result;
    } on PlatformException catch (e) {
      return 'Printing failed: ${e.toString()}';
    }
  }
}
