import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class LocalPrint {
  Future<NetworkPrinter> printnetwork(ipaddress) async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();

    print(profile.name);

    final printer = NetworkPrinter(paper, profile);

    final PosPrintResult res = await printer.connect('192.168.10.120',
        port: 9100, timeout: const Duration(seconds: 1));

    if (res == PosPrintResult.success) {
      print('Print result: ${res.msg}');
      printer.text('TEST');
      printer.feed(5);
      printer.cut();
      return printer;
      // await testReceipt(printer);
      // printer.disconnect();
    } else {
      print('Print result: ${res.msg}');
      return printer;
    }
  }

  Future<void> testReceipt(NetworkPrinter printer) async {
    printer.text('Bold text', styles: const PosStyles(bold: true));
    printer.text('Reverse text', styles: const PosStyles(reverse: true));
    printer.text('Underlined text',
        styles: const PosStyles(underline: true), linesAfter: 1);
    printer.text('Align left', styles: const PosStyles(align: PosAlign.left));
    printer.text('Align center',
        styles: const PosStyles(align: PosAlign.center));
    printer.text('Align right',
        styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    printer.text('Text size 200%',
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    printer.feed(2);
    printer.cut();
  }
}
