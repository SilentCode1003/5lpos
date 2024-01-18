import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';

class PrintReceiptPage extends StatefulWidget {
  const PrintReceiptPage({super.key});

  @override
  State<PrintReceiptPage> createState() => _PrintReceiptPageState();
}

class _PrintReceiptPageState extends State<PrintReceiptPage> {
  final PaperSize paper = PaperSize.mm58;
  late CapabilityProfile profile;
  var printer;

  @override
  void initState() {
    setState(() {
      CapabilityProfile.load().then((result) {
        profile = result;
        printer = NetworkPrinter(paper, profile);
        printer.connect('192.168.10.120', port: 9100).then((result) {
          if (result == PosPrintResult.success) {}

          // Navigator.pushReplacementNamed(context, 'print');
        });
      });
    });
    super.initState();
  }

  Future<void> _print() async {
    testReceipt(printer);
  }

  void testReceipt(NetworkPrinter printer) {
    printer.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
        styles: const PosStyles(codeTable: 'CP1252'));
    printer.text('Special 2: blåbærgrød',
        styles: const PosStyles(codeTable: 'CP1252'));

    printer.text('Bold text', styles: const PosStyles(bold: true));
    printer.text('Reverse text', styles: const PosStyles(reverse: true));
    printer.text('Underlined text',
        styles: const PosStyles(underline: true), linesAfter: 1);
    printer.text('Align left', styles: const PosStyles(align: PosAlign.left));
    printer.text('Align center', styles: const PosStyles(align: PosAlign.center));
    printer.text('Align right',
        styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    printer.text('Text size 200%',
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    printer.feed(2);
    printer.cut();
    // printer.disconnect(delayMs: 10000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Receipt')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                _print();
              },
              child: const Text('PRINT'))
        ],
      ),
    );
  }
}










































// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:fiveLPOS/repository/customerhelper.dart';
// import 'package:fiveLPOS/repository/dbhelper.dart';
// import 'package:printing/printing.dart';
// import 'package:sqflite_common/sqlite_api.dart';

// class PrintReceipt extends StatefulWidget {
//   const PrintReceipt({super.key});

//   @override
//   State<PrintReceipt> createState() => _PrintReceiptState();
// }

// class _PrintReceiptState extends State<PrintReceipt> {
//   Helper helper = Helper();
//   DatabaseHelper dbHelper = DatabaseHelper();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PdfPreview(
//           build: (format) => _receipt(format),
//           onPrinted: (context) => () {
//                 Navigator.of(context).pop();
//                 // MaterialPageRoute(builder: (context) => const MyDashboard());
//               }),
//     );
//   }

//   _receipt(PdfPageFormat format) async {
//     String id = '';
//     String posname = '';
//     String serial = '';
//     String min = '';
//     String ptu = '';

//     String branchid = '';
//     String branchname = '';
//     String tin = '';
//     List<String> address = [];
//     List<String> logo = [];

//     PdfPageFormat format = PdfPageFormat.roll80;
//     final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

//     Database db = await dbHelper.database;
//     List<Map<String, dynamic>> posconfig = await db.query('pos');
//     for (var pos in posconfig) {
//       id = pos['posid'].toString();
//       posname = pos['posname'];
//       serial = pos['serial'];
//       min = pos['min'];
//       ptu = 'PTU: ${pos['ptu']}';
//     }

//     List<Map<String, dynamic>> branchconfig = await db.query('branch');
//     for (var branch in branchconfig) {
//       branchid = branch['branchid'].toString();
//       branchname = branch['branchname'];
//       tin = 'VAT REG TIN: ${branch['tin']}';
//       address = branch['address'].toString().split(',').toList();
//       logo = utf8.decode(base64.decode(branch['logo'])).split('<svg');
//     }

//     return pdf.save();
//   }
// }
