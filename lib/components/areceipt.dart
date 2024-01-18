import 'package:flutter/foundation.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fiveLPOS/repository/customerhelper.dart';
import 'package:printing/printing.dart';


class AReceipt extends StatefulWidget {
  List<Map<String, dynamic>> items;
  double cash;
  String detailid;
  String posid;
  String cashier;
  String shift;

  AReceipt(
      {Key? key,
      required this.items,
      required this.cash,
      required this.detailid,
      required this.posid,
      required this.shift,
      required this.cashier})
      : super(key: key);

  @override
  State<AReceipt> createState() => _AReceiptState();
}

class _AReceiptState extends State<AReceipt> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CReceipt(
        cash: widget.cash,
        items: widget.items,
        cashier: widget.cashier,
        detailid: widget.detailid,
        posid: widget.posid,
        shift: widget.shift,
      ),
    );
  }
}

class CReceipt extends StatefulWidget {
  List<Map<String, dynamic>> items;
  double cash;
  String detailid;
  String posid;
  String cashier;
  String shift;

  CReceipt(
      {Key? key,
      required this.items,
      required this.cash,
      required this.detailid,
      required this.posid,
      required this.shift,
      required this.cashier})
      : super(key: key);

  @override
  State<CReceipt> createState() => _CReceiptState();
}

class _CReceiptState extends State<CReceipt> {
  ///  //Currency

  Helper helper = Helper();

  String formatAsCurrency(double value) {
    return toCurrencyString(
      value.toString(), mantissaLength: 2,
      // leadingSymbol: CurrencySymbols.
    );
  }
  //Currency
  /////TOP//////

  String businessname() {
    return 'Asvesti';
  }

  String businessadd() {
    return '1234 Elm Street, City, Country';
  }

  String cartitems() {
    return '00000 00000 00000 00000';
  }

  String vatreg() {
    return '000 000 000 000000';
  }

/////INFO//////
  String datetime() {
    return helper.GetCurrentDatetime();
  }

  String officialreceipt() {
    return widget.detailid;
  }

  String staffname() {
    return widget.cashier;
  }

  String posnumber() {
    return widget.posid;
  }

  String serialnum() {
    return '4585452';
  }

  String branchname() {
    return 'Pacita';
  }

  String minnum() {
    return '23031410403868315';
  }

  ////////MIDDLE//////
  String itemquantity() {
    return 'x5';
  }

  ////////Numbers//////
  double totalamtdue(List<Map<String, dynamic>> items) {
    double total = 0;
    for (int index = 0; index < items.length; index++) {
      total += (items[index]['price'] * items[index]['quantity']);
    }

    if (kDebugMode) {
      print(total);
    }

    return total;
  }

  String customercash(cash) {
    return formatAsCurrency(cash);
  }

  String change(total, cash) {
    double change = (cash - total);

    return formatAsCurrency(change);
  }

  double vatable(total) {
    double vatable = (total / 1.12);

    return double.parse(vatable.toStringAsFixed(2));
  }

  String vatamt(total, vatable) {
    double vat = (total - vatable);

    if (kDebugMode) {
      print(vatable);
    }

    return formatAsCurrency(vat);
  }

  String vatexemptsales() {
    return '0.00';
  }

  String zerorated() {
    return '0.00';
  }

  ////////Sold To//////

  ////////Footer//////
  String tinnum() {
    return '000-000-000-000';
  }

  String biraccr() {
    return '1160003901892019081144';
  }

  String accrdate() {
    return 'test';
  }

  String permitnum() {
    return 'FP032023-116-0375318-000000';
  }

//////others///////
  String promorgimmicks() {
    return 'present the receipt to claim a freebie test';
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    List<Map<String, dynamic>> items = widget.items;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            children: [
              pw.SizedBox(
                  child: pw.Flexible(
                    child: pw.SvgImage(
                        svg:
                            '<svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="100.000000pt" height="100.000000pt" viewBox="0 0 100.000000 100.000000" preserveAspectRatio="xMidYMid meet"> <metadata> Created by potrace 1.16, written by Peter Selinger 2001-2019 </metadata> <g transform="translate(0.000000,100.000000) scale(0.100000,-0.100000)" fill="#000000" stroke="none"> <path d="M373 985 c-169 -46 -307 -182 -357 -354 -18 -62 -21 -184 -5 -251 28 -121 128 -254 240 -317 65 -37 149 -63 198 -62 29 1 26 3 -18 9 -29 5 -74 16 -100 26 -67 25 -153 82 -145 96 4 6 3 8 -3 5 -6 -4 -19 3 -29 14 -19 21 -19 21 21 14 33 -5 37 -4 22 5 -11 7 -30 10 -43 7 -19 -3 -30 3 -48 27 -121 162 -129 390 -18 562 91 141 244 224 412 224 134 0 247 -47 346 -145 64 -63 95 -113 126 -205 13 -38 17 -44 13 -20 -17 109 -133 259 -244 319 -111 59 -253 77 -368 46z"/> <path d="M518 964 c-8 -30 -59 -36 -98 -12 -17 10 -30 13 -30 8 0 -16 53 -38 88 -35 39 2 55 16 50 41 -3 17 -4 17 -10 -2z"/> <path d="M597 921 c-10 -22 -41 -61 -70 -88 -32 -29 -40 -40 -22 -29 17 10 41 28 53 40 27 24 65 92 60 107 -2 6 -11 -8 -21 -30z"/> <path d="M330 945 c0 -3 7 -22 15 -42 22 -52 19 -90 -9 -118 -20 -20 -30 -23 -67 -18 -24 3 -65 14 -91 23 -27 10 -46 14 -43 10 9 -14 98 -40 151 -44 69 -5 126 6 132 24 5 13 3 13 -11 1 -12 -9 -17 -10 -17 -2 0 7 -4 9 -10 6 -16 -10 -12 21 4 34 11 9 20 9 35 2 11 -6 28 -11 39 -11 22 0 52 30 51 51 0 8 -5 4 -11 -8 -12 -24 -18 -26 -58 -23 -34 3 -59 27 -82 78 -17 37 -28 52 -28 37z"/> <path d="M667 896 c-72 -174 -283 -245 -516 -174 -52 16 -65 17 -72 6 -14 -22 -11 -25 29 -27 20 -1 51 -3 67 -6 145 -20 269 -12 336 21 16 8 41 11 62 7 47 -7 73 2 58 21 -9 10 -8 15 3 19 8 3 20 24 26 46 12 44 36 75 52 65 6 -4 5 -10 -3 -15 -11 -7 -10 -9 3 -9 12 0 16 -5 12 -17 -4 -13 -3 -14 3 -5 7 10 13 8 27 -7 18 -19 17 -21 -4 -55 -12 -20 -32 -44 -45 -55 -14 -10 -22 -21 -18 -25 3 -3 17 6 30 20 13 14 28 22 35 18 7 -4 8 -3 4 4 -4 7 -1 12 9 12 11 0 15 -5 11 -16 -3 -8 -2 -12 4 -9 6 3 10 17 10 31 0 30 11 31 36 2 17 -19 17 -21 2 -15  -10 4 -18 3 -18 -2 0 -5 9 -11 20 -14 11 -3 18 -1 14 4 -8 14 9 10 31 -8 13 -10 15 -14 4 -10 -9 3 -22 1 -30 -4 -10 -6 -6 -9 16 -9 17 0 40 -3 53 -6 37 -10 25 10 -22 34 -70 38 -149 114 -175 171 -14 28 -27 51 -30 51 -3 0 -14 -20 -24 -44z"/> <path d="M230 889 c-19 -17 -28 -27 -20 -23 10 5 9 0 -4 -14 -11 -12 -25 -22 -32 -22 -7 0 -15 -4 -18 -9 -8 -13 51 -6 68 8 8 7 19 10 24 7 5 -3 12 7 15 22 3 15 9 35 12 45 10 26 -7 21 -45 -14z"/> <path d="M736 895 c9 -14 19 -24 21 -21 6 6 -20 46 -30 46 -4 0 0 -11 9 -25z"/> <path d="M486 897 c3 -10 9 -15 12 -12 3 3 0 11 -7 18 -10 9 -11 8 -5 -6z"/> <path d="M790 826 c0 -2 8 -10 18 -17 15 -13 16 -12 3 4 -13 16 -21 21 -21 13z"/> <path d="M250 813 c0 -12 28 -38 34 -32 2 2 -5 13 -15 23 -11 11 -19 15 -19 9z"/> <path d="M518 693 c12 -2 32 -2 45 0 12 2 2 4 -23 4 -25 0 -35 -2 -22 -4z"/> <path d="M238 603 c-21 -24 -54 -91 -62 -128 -4 -16 -9 -38 -12 -47 -11 -36 13 -17 29 23 14 35 20 40 43 37 22 -2 29 -10 38 -42 6 -22 17 -41 25 -44 9 -3 11 2 8 14 -3 11 -9 61 -12 112 -6 78 -10 92 -25 92 -9 0 -24 -8 -32 -17z m22 -80 c0 -7 -9 -13 -20 -13 -17 0 -18 3 -8 25 8 19 14 22 20 13 4 -7 8 -19 8 -25z"/> <path d="M737 584 c-4 -4 -7 -16 -7 -26 0 -15 -8 -18 -49 -18 -55 0 -74 -16 -46 -36 18 -13 18 -15 -4 -38 -25 -26 -15 -42 19 -31 32 10 45 43 25 65 -15 16 -14 18 3 23 30 7 40 -5 44 -51 4 -54 22 -55 26 -2 2 22 7 40 11 40 4 0 7 17 6 37 -3 36 -14 51 -28 37z"/> <path d="M800 570 c0 -5 7 -10 15 -10 8 0 15 5 15 10 0 6 -7 10 -15 10 -8 0 -15 -4 -15 -10z"/> <path d="M992 505 c-1 -44 -8 -102 -16 -130 -50 -190 -215 -337 -407 -365 -44 -6 -47 -8 -18 -9 90 -3 221 60 309 150 96 97 145 227 138 364 l-4 70 -2 -80z"/> <path d="M530 540 c-24 -24 -26 -57 -4 -88 19 -27 35 -28 65 -2 l24 20 -31 -6 c-23 -5 -33 -2 -38 11 -7 20 3 65 15 65 12 0 11 -17 -1 -41 -13 -24 2 -25 23 -1 21 23 21 27 1 46 -20 21 -30 20 -54 -4z"/> <path d="M790 500 c9 -67 15 -70 29 -14 10 38 10 49 -1 55 -28 18 -34 9 -28 -41z"/> <path d="M320 525 c0 -7 8 -19 18 -25 16 -9 15 -12 -7 -30 -18 -15 -21 -24 -13 -32 8 -8 18 -6 36 6 27 17 34 40 16 51 -15 9 -12 25 4 25 8 0 18 5 21 10 4 6 -10 10 -34 10 -29 0 -41 -4 -41 -15z"/> <path d="M412 493 c2 -20 8 -38 14 -40 11 -4 74 55 74 69 0 17 -28 7 -43 -14 l-16 -23 0 23 c-1 13 -7 22 -17 22 -11 0 -14 -9 -12 -37z"/> <path d="M468 313 c90 -2 234 -2 320 0 86 1 13 3 -163 3 -176 0 -247 -2 -157 -3z"/> <path d="M187 190 c43 -19 62 -43 58 -72 -2 -10 0 -18 5 -18 18 0 5 52 -18 76 l-26 26 39 -7 c49 -9 51 -11 36 -29 -10 -12 -9 -19 9 -38 12 -13 20 -17 18 -10 -5 21 47 55 82 55 25 0 28 2 15 10 -20 11 -64 1 -87 -20 -11 -10 -18 -11 -18 -5 0 16 54 42 87 42 60 0 132 -72 149 -150 l7 -35 14 44 c7 25 11 47 8 49 -3 3 -5 0 -5 -7 0 -9 -3 -9 -14 1 -7 7 -11 20 -9 28 4 12 3 12 -5 2 -7 -10 -13 -7 -26 13 -20 30 -10 58 11 30 12 -18 13 -18 13 -1 0 10 6 16 13 13 7 -2 11 -18 10 -38 l-2 -34 10 32 c5 18 16 33 24 33 19 0 19 -5 -1 -35 -13 -21 -13 -23 0 -21 20 3 56 36 53 49 -1 6 15 15 35 21 50 13 113 -11 112 -42 0 -19 1 -20 15 -8 9 7 21 12 26 10 6 -1 21 11 33 27 l24 29 -369 -1 c-366 -1 -368 -1 -326 -19z m632 -6 c3 -3 0 -9 -5 -14 -7 -7 -17 -3 -30 11 -19 22 -19 22 6 14 14 -4 27 -9 29 -11z m-204 -34 c-10 -11 -20 -18 -23 -15 -7 6 18 35 31 35 5 0 2 -9 -8 -20z"/> <path d="M353 145 c-13 -9 -23 -22 -23 -28 0 -7 5 -4 11 6 13 21 62 23 83 1 20 -20 21 -58 1 -74 -22 -18 -18 -32 5 -20 11 6 18 15 15 20 -3 5 -1 11 5 15 5 3 15 -6 22 -22 11 -26 12 -27 15 -6 5 25 -16 70 -43 95 -29 26 -66 31 -91 13z"/> <path d="M641 115 c-17 -20 -31 -40 -31 -45 0 -4 -3 -15 -6 -24 -3 -9 -2 -16 4 -16 5 0 13 15 16 33 7 30 8 31 19 12 7 -11 18 -21 26 -23 11 -2 10 3 -3 23 -17 25 -17 28 0 46 24 26 65 21 80 -9 8 -16 14 -20 19 -12 10 16 -34 50 -65 50 -19 0 -38 -11 -59 -35z"/> <path d="M384 102 c8 -26 -18 -37 -39 -16 -8 9 -15 11 -15 6 0 -17 28 -34 52 -30 17 2 23 10 23 27 0 13 -6 26 -14 29 -9 3 -11 -1 -7 -16z"/> <path d="M687 103 c-3 -5 0 -19 8 -29 15 -20 18 -11 6 20 -4 11 -10 15 -14 9z"/> <path d="M301 86 c-8 -9 -11 -19 -7 -23 9 -9 29 13 24 27 -2 8 -8 7 -17 -4z"/> </g> </svg>'),
                  ),
                  height: 50,
                  width: 50),
              pw.Text(
                businessname(),
                style: const pw.TextStyle(fontSize: 18),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                businessadd(),
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                vatreg(),
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
              //////////////////////////////////////////////////////////////////////////////////////////
              pw.Container(
                height: 1, // Set the height of the divider
                color: PdfColors.black, // Change this to your desired color
                margin: const pw.EdgeInsets.symmetric(
                    vertical: 10), // Adjust vertical spacing
              ),
              pw.Text(
                datetime(),
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'OR: ${officialreceipt()}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Staff: ${staffname()}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'POS: ${posnumber()}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'SN#: ${serialnum()}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Branch: ${branchname()}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'MIN: ${minnum()}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),

              pw.SizedBox(height: 1),
              pw.Container(
                height: 1, // Set the height of the divider
                color: PdfColors.black, // Change this to your desired color
                margin: const pw.EdgeInsets.symmetric(
                    vertical: 7), // Adjust vertical spacing
              ),
              //////////////////////////////////////////////////////////////////////////////////////////
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Description',
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Amount',
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold),
                  )
                ],
              ),
              pw.SizedBox(height: 6),

              for (int index = 0; index < items.length; index++)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      ' ${items[index]['name']} @ ${items[index]['quantity']}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      formatAsCurrency(
                          items[index]['quantity'] * items[index]['price']),
                      style: const pw.TextStyle(fontSize: 9
                          // pw.backgroundColor: Colors.grey
                          ),
                    ),
                  ],
                ),
              pw.SizedBox(height: 6),
              pw.Container(
                height: 1, // Set the height of the divider
                color: PdfColors.grey700, // Change this to your desired color
                margin: const pw.EdgeInsets.symmetric(
                    vertical: 5), // Adjust vertical spacing
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Amount Due:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    formatAsCurrency(totalamtdue(widget.items)),
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Cash:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    customercash(widget.cash),
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Change:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    change(totalamtdue(widget.items), widget.cash),
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Vatable:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    formatAsCurrency(vatable(totalamtdue(widget.items))),
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'VAT Amt:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    vatamt(totalamtdue(widget.items),
                        vatable(totalamtdue(widget.items))),
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'VAT Exempt Sales:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    vatexemptsales(),
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Zero Rated:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    zerorated(),
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                height: 0.5, // Set the height of the divider
                color: PdfColors.grey700, // Change this to your desired color
                margin: const pw.EdgeInsets.symmetric(
                    vertical: 5), // Adjust vertical spacing
              ),
              pw.SizedBox(height: 6),
              pw.Column(children: [
                pw.Text(
                  'Sold to:____________________',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Address:____________________',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'TIN:________________________',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  businessadd(),
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.Text(
                  'TIN: ${tinnum()}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.Text(
                  'BIR Accr: ${biraccr()}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.Text(
                  'AccrDate: ${accrdate()}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.Text(
                  'Permit #: ${permitnum()}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.Container(
                  alignment: pw.Alignment
                      .center, // Align the contents of the container to the center
                  width: 300, // Replace with your actual container width
                  child: pw.Text(
                    'Get a chance to win a freebie when you buy P2,000 worth of any items. Per DTI FAIR TRADE Permit Number: 123123 Series of 2023.',
                    style: const pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign
                        .center, // Align the text within the container to the center
                  ),
                ),
                pw.Text(
                  'THIS IS A OFFICIAL RECEIPT',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ]),
              //////OTHERS//////////
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PdfPreview(
          build: (format) => _generatePdf(format),
          onPrinted: (context) => () {
                Navigator.of(context).pop();
                // MaterialPageRoute(builder: (context) => const MyDashboard());
              }),
    );
  }
}
