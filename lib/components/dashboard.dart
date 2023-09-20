import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pos2/api/posshiftlog.dart';
import 'package:pos2/components/loadingspinner.dart';
import 'package:pos2/components/loginpage.dart';
import 'package:pos2/model/productprice.dart';
import 'package:pos2/api/category.dart';
import 'package:pos2/repository/customerhelper.dart';
import 'package:pos2/api/salesdetails.dart';
import 'package:pos2/api/productprice.dart';
import 'package:pos2/repository/dbhelper.dart';
import 'package:pos2/repository/email.dart';
import 'package:pos2/repository/receipt.dart';
import 'package:pos2/api/transaction.dart';
import 'package:pos2/repository/reprint.dart';
import 'package:printing/printing.dart';
import 'package:sqflite_common/sqlite_api.dart';

class ButtonStyleInfo {
  final Color backgroundColor;
  final Color textColor;

  ButtonStyleInfo({
    required this.backgroundColor,
    required this.textColor,
  });
}

class MyDashboard extends StatefulWidget {
  String employeeid;
  String fullname;
  String accesstype;
  String positiontype;

  MyDashboard(
      {super.key,
      required this.employeeid,
      required this.fullname,
      required this.accesstype,
      required this.positiontype});

  @override
  _MyDashboardState createState() => _MyDashboardState();
}

class _MyDashboardState extends State<MyDashboard> {
  List<Map<String, dynamic>> itemsList = [];
  List<ProductPriceModel> productList = [];
  List<String> categoryList = [];
  String companyname = "";
  String address = "";
  String tin = "";
  String posid = "";
  String shift = "";
  bool isStartShift = false;
  bool isEndShift = false;

  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _referenceidController = TextEditingController();
  final TextEditingController _receiptORController = TextEditingController();

  Helper helper = Helper();
  DatabaseHelper dbHelper = DatabaseHelper();
  int detailid = 100000000;

  @override
  void initState() {
    // TODO: implement initState
    // _getbranch();
    _getposconfig();
    _getcategory();
    super.initState();
  }

  Future<void> _getPOSShift(posid) async {
    final results = await POSShiftLogAPI().getPOSShift(posid);
    final jsonData = json.encode(results['data']);

    print(jsonData);

    if (jsonData.length == 2) {
      print('empty');
      setState(() {
        isStartShift = true;
        isEndShift = false;
      });
    }

    for (var data in json.decode(jsonData)) {
      print('processing');
      shift = data['shift'];
      if (data['status'] != 'START') {
        setState(() {
          isStartShift = true;
        });
      } else {
        setState(() {
          isEndShift = true;
        });
      }
    }
  }

  Future<void> _startShift(BuildContext context, posid) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingSpinner(
            message: 'Loading',
          );
        });

    final results = await POSShiftLogAPI().startShift(posid);
    // final jsonData = json.encode(results['data']);
    print(results['msg']);

    if (results['msg'] == 'success') {
      setState(() {
        isStartShift = false;
      });
    }
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pop(context);

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Shift started!'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _getPOSShift(posid);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    });
  }

  Future<void> _endShift(BuildContext context, posid) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingSpinner(
            message: 'Loading',
          );
        });

    final results = await POSShiftLogAPI().endShift(posid);
    // final jsonData = json.encode(results['data']);
    print(results['msg']);

    if (results['msg'] == 'success') {
      setState(() {
        isStartShift = false;
      });
    }
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pop(context);

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Shift Ended!'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _getPOSShift(posid);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    });
  }

  Future<void> _getdetails(BuildContext context, detailid) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingSpinner(
            message: 'Loading',
          );
        });

    final results = await SalesDetails().getdetails(detailid);
    final jsonData = json.encode(results['data']);

    if (results['msg'] == 'success') {
      Navigator.of(context).pop();
    }

    if (jsonData.length == 2) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Not Found'),
              content: Text('OR Number $detailid not found'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    } else {
      for (var data in json.decode(jsonData)) {
        int amount = data['amount'];

        final pdfBytes = ReprintingReceipt(
                data['ornumber'],
                data['ordate'],
                data['ordescription'],
                data['orpaymenttype'],
                data['posid'],
                data['shift'],
                data['cashier'],
                double.parse(data['total']),
                data['epaymentname'],
                data['referenceid'],
                amount.toDouble())
            .printReceipt();

        if (Platform.isWindows) {
          List<Printer> printerList = await Printing.listPrinters();
          for (var printer in printerList) {
            if (printer.isDefault) {
              Printing.directPrintPdf(
                  printer: printer,
                  onLayout: (PdfPageFormat format) => pdfBytes);
            }
          }
        }
      }
    }
  }

  Future<String> _semdreceipt(email, ornumber) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingSpinner(
            message: 'Loading',
          );
        });

    final results = await SalesDetails().getdetails(ornumber);
    final jsonData = json.encode(results['data']);

    if (results['msg'] == 'success') {
      Navigator.of(context).pop();
      if (jsonData.length == 2) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Not Found'),
                content: Text('OR Number $detailid not found'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });

        return 'notfound';
      } else {
        for (var data in json.decode(jsonData)) {
          int amount = data['amount'];

          final pdfBytes = await ReprintingReceipt(
                  data['ornumber'],
                  data['ordate'],
                  data['ordescription'],
                  data['orpaymenttype'],
                  data['posid'],
                  data['shift'],
                  data['cashier'],
                  double.parse(data['total']),
                  data['epaymentname'],
                  data['referenceid'],
                  amount.toDouble())
              .printReceipt();

          List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
              jsonDecode(data['ordescription']));

          await Email().sendMail(
              data['ornumber'],
              email,
              pdfBytes,
              data['cashier'],
              items,
              data['orpaymenttype'],
              data['referenceid']);
        }
      }
    }
    return 'success';
  }

  Future<void> _getposconfig() async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> posconfig = await db.query('pos');
    for (var pos in posconfig) {
      setState(() {
        posid = pos['posid'].toString();
        print(posid);
        _getdetailid(posid);
        _getPOSShift(posid);
      });
    }
  }

  Future<void> _search() async {
    String serial = _serialNumberController.text;
    final results = await ProductPrice().getitemserial(serial);
    final jsonData = json.decode(results['data']);
    String description = "";
    double price = 0;

    setState(() {
      for (var data in jsonData) {
        description = data['description'];
        price = double.parse(data['price']);
        addItem(description, price, 1);
      }
    });
  }

  Future<void> _getcategory() async {
    final results = await CategoryAPI().getCategory();
    final jsonData = json.encode(results['data']);

    setState(() {
      for (var data in json.decode(jsonData)) {
        categoryList.add(data['categoryname']);
      }
    });
  }

  Future<void> _getcategoryitems(String category) async {
    final result = await ProductPrice().getcategoryitems(category);
    final List<dynamic> jsonData = json.decode(result['data']);

    if (result['msg'] == 'success') {
      setState(() {
        productList =
            jsonData.map((data) => ProductPriceModel.fromJson(data)).toList();
      });
    }
  }

  Future<void> _getdetailid(String pos) async {
    final result = await SalesDetails().getdetailid(pos);
    int id = int.parse(result['data']);

    print(id);

    setState(() {
      detailid = id;
      print(detailid);
    });
  }

  String formatAsCurrency(double value) {
    return '₱ ${toCurrencyString(value.toString())}';
  }

  Future<void> confirmAndRemove(int index) async {
    bool shouldRemove = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Removal'),
          content: const Text(
              'Are you sure you want to remove this item from the list?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel removal
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm removal
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      setState(() {
        itemsList.removeAt(index);
      });
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity < 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Quantity'),
            content: const Text(
                'Setting the quantity to 0 or below will remove the item from the list. Continue?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  confirmAndRemove(index); // Show remove confirmation
                },
                child: const Text('Remove'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        itemsList[index]['quantity'] = newQuantity;
      });
    }
  }

  double calculateGrandTotal() {
    double grandTotal = 0;
    for (var product in itemsList) {
      grandTotal += product['price'] * product['quantity'];
    }
    return grandTotal;
  }

  double cashAmount = 0;

  void addItem(name, price, quantity) {
    setState(() {
      int existingIndex = itemsList.indexWhere((item) => item['name'] == name);

      if (existingIndex != -1) {
        setState(() {
          int newQuantity = itemsList[existingIndex]['quantity'] + quantity;
          itemsList[existingIndex]['quantity'] = newQuantity;
        });
      } else {
        setState(() {
          itemsList.add({'name': name, 'price': price, 'quantity': quantity});
        });
      }
    });
  }

  void _showSimpleDialog(BuildContext context, category) async {
    _getcategoryitems(category);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingSpinner(
            message: 'Loading',
          );
        });

    Future.delayed(const Duration(milliseconds: 1200), () {
      Navigator.of(context).pop();

      final List<Widget> product = List<Widget>.generate(
          productList.length,
          (index) => SizedBox(
                height: 60,
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    // Add your button press logic here
                    addItem(productList[index].description,
                        double.parse(productList[index].price), 1);
                  },
                  child: Text(
                    productList[index].description,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ));

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Center(child: Text('Products')),
            content: SingleChildScrollView(
              child: Center(
                child: Wrap(
                    spacing: 8, // Adjust the spacing between buttons
                    runSpacing: 8, // Adjust the vertical spacing between rows
                    children: product),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    });
  }

  void others() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Others'),
            content: SingleChildScrollView(
              child: Center(
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(120, 80))),
                      onPressed: isStartShift
                          ? () {
                              _startShift(context, posid);
                            }
                          : null,
                      child: const Text(
                        'START\nSHIFT',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(120, 80))),
                      onPressed: isEndShift
                          ? () {
                              _endShift(context, posid);
                            }
                          : null,
                      child: const Text(
                        'END\nSHIFT',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(120, 80))),
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Re-printing'),
                                content: SizedBox(
                                  height: 80,
                                  width: 200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextField(
                                        controller: _receiptORController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: "OR Number",
                                            hintText: '200000001'),
                                      )
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      String receiptOR =
                                          _receiptORController.text.trim();
                                      Navigator.of(context).pop();
                                      _getdetails(context, receiptOR);
                                    },
                                    child: const Text('Print'),
                                  ),
                                ],
                              );
                            });
                      },
                      child: const Text(
                        'RE-PRINT',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize:
                              MaterialStateProperty.all(const Size(120, 80))),
                      onPressed: () {
                        final TextEditingController _emailController =
                            TextEditingController();
                        final TextEditingController _ornumberController =
                            TextEditingController();

                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Customer Email'),
                                content: Container(
                                  height: 200,
                                  width: 200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                            labelText: "Customer Email",
                                            hintText: 'you@example.com'),
                                      ),
                                      TextField(
                                        controller: _ornumberController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: "OR Number",
                                            hintText: '200000001'),
                                      )
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () async {
                                        String email = _emailController.text;
                                        String ornumber =
                                            _ornumberController.text;
                                        if (isValidEmail(email)) {
                                          String message = '';

                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return LoadingSpinner(
                                                  message: 'Sending...',
                                                );
                                              });
                                          message = await _semdreceipt(
                                              email, ornumber);

                                          Navigator.of(context).pop();

                                          _clearItems();

                                          if (message != 'success') {
                                          } else {
                                            Navigator.of(context).pop();
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        const Text('Success'),
                                                    content: const Text(
                                                        'E-Receipt sent successfully!'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text('Ok'))
                                                    ],
                                                  );
                                                });
                                          }
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Invalid'),
                                                  content: const Text(
                                                      'Invalid Email Address!'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Close'))
                                                  ],
                                                );
                                              });
                                        }
                                      },
                                      child: const Text("Send")),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Close")),
                                ],
                              );
                            });
                      },
                      child: const Text(
                        'SEND\nE-RECEIPT',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                ]),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'))
            ],
          );
        });
  }

  bool isValidEmail(String email) {
    String emailRegex = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regex = RegExp(emailRegex);

    return regex.hasMatch(email);
  }

  Future<void> _transaction(
    String detailid,
    String posid,
    String date,
    String shift,
    String paymenttype,
    String items,
    String total,
    String cashier,
    String referenceid,
    String paymentname,
  ) async {
    try {
      final TextEditingController _emailController = TextEditingController();
      final result = await POSTransaction().sending(
          detailid,
          date,
          posid,
          shift,
          paymenttype,
          referenceid,
          paymentname,
          items,
          total,
          cashier,
          cashAmount.toString());
      final pdfBytes = await Receipt(
              itemsList,
              cashAmount,
              detailid,
              posid,
              cashier,
              shift,
              companyname,
              address,
              tin,
              paymenttype,
              referenceid,
              paymentname)
          .printReceipt();

      if (result['msg'] == 'success') {
        if (Platform.isAndroid) {
          // Printing.layoutPdf(
          //   onLayout: (PdfPageFormat format) => pdfBytes,
          // );

          // Printing.directPrintPdf(
          //     printer: const Printer(url: ''),
          //     onLayout: (PdfPageFormat format) => pdfBytes);
        } else if (Platform.isWindows) {
          List<Printer> printerList = await Printing.listPrinters();
          for (var printer in printerList) {
            if (printer.isDefault) {
              Printing.directPrintPdf(
                  printer: printer,
                  onLayout: (PdfPageFormat format) => pdfBytes);
            }
          }
        }

        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: const Text('Transaction process successfully!'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      _clearItems();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ReceiptScreen(
                      //       cash: cashAmount,
                      //       items: itemsList,
                      //       cashier: cashier,
                      //       detailid: detailid,
                      //       posid: posid,
                      //       shift: shift,
                      //     ),
                      //   ),
                      // );
                    },
                    child: const Text('OK'),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Customer Email'),
                                content: Container(
                                  height: 200,
                                  width: 200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                            labelText: "Customer Email",
                                            hintText: 'you@example.com'),
                                      )
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () async {
                                        String email = _emailController.text;
                                        if (isValidEmail(email)) {
                                          String message = '';

                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return LoadingSpinner(
                                                  message: 'Sending...',
                                                );
                                              });
                                          message = await Email().sendMail(
                                              detailid.toString(),
                                              email,
                                              pdfBytes,
                                              cashier,
                                              itemsList,
                                              paymenttype,
                                              referenceid);

                                          Navigator.of(context).pop();

                                          if (message != 'success') {
                                          } else {
                                            Navigator.of(context).pop();
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        const Text('Success'),
                                                    content: const Text(
                                                        'E-Receipt sent successfully!'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text('Ok'))
                                                    ],
                                                  );
                                                });

                                            _clearItems();
                                          }
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Invalid'),
                                                  content: const Text(
                                                      'Invalid Email Address!'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Close'))
                                                  ],
                                                );
                                              });
                                        }
                                      },
                                      child: const Text("Send")),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Close")),
                                ],
                              );
                            });
                      },
                      child: const Text('Send E-Receipt')),
                ],
              );
            });
      } else {
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(
                    'Please inform administrator. Thank you! ${result['status']}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Transaction Error'),
              content: Text('Please inform administrator. Thank you! $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    }
  }

  void _clearItems() {
    setState(() {
      itemsList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> category = List<Widget>.generate(
        categoryList.length,
        (index) => SizedBox(
              height: 80,
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  // Add your button press logic here
                  _showSimpleDialog(context, categoryList[index]);
                },
                child: Text(
                  categoryList[index],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ));

    String selectedValue = 'Select Payment Type';
    List<String> options = ['Select Payment Type', 'Gcash', 'Paymaya', 'Card'];

    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        leading: Container(
          padding: const EdgeInsets.all(5),
          alignment: Alignment.center,
          child: Image.asset('assets/asvesti.png'),
        ),
        title: const Text('Asvesti'),
        actions: <Widget>[
          Row(
            children: [
              const Text('Logout'),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // Add your logout logic here

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Logut'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage())),
                              child: const Text('OK'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ],
                        );
                      });
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 67, 67, 67),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 10,
                    columns: const [
                      DataColumn(
                          label: Text('Name',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Price',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Qty',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      // DataColumn(label: Text('')),
                    ],
                    rows: itemsList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> product = entry.value;
                      double totalCost = product['price'] * product['quantity'];
                      return DataRow(cells: [
                        DataCell(SizedBox(
                            width: 50,
                            child: Text(
                              product['name'],
                            ))),
                        DataCell(
                          SizedBox(
                            width: 60,
                            child: Text(formatAsCurrency(product['price'])),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20),
                                  color: const Color.fromARGB(255, 213, 86, 86),
                                  onPressed: () {
                                    if (product['quantity'] > 0) {
                                      updateQuantity(
                                          index, product['quantity'] - 1);
                                    }
                                  },
                                ),
                                Expanded(
                                  child: SizedBox(
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      onChanged: (newQuantity) {
                                        int parsedQuantity =
                                            int.tryParse(newQuantity) ?? 0;
                                        updateQuantity(index, parsedQuantity);
                                      },
                                      controller: TextEditingController(
                                          text: product['quantity'].toString()),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  color: const Color.fromARGB(255, 92, 213, 86),
                                  onPressed: () {
                                    updateQuantity(
                                        index, product['quantity'] + 1);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(Text(formatAsCurrency(totalCost))),
                        // DataCell(IconButton(
                        //   icon: const Icon(Icons.delete),
                        //   color: const Color.fromARGB(255, 58, 58, 67),
                        //   onPressed: () => confirmAndRemove(index),
                        // )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ':  ${formatAsCurrency(calculateGrandTotal())}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5), //DIVIDER START
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _serialNumberController,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 156, 84, 84)),
                            ),
                            labelText: 'Serial Number',
                            labelStyle: TextStyle(
                                color: Color.fromARGB(255, 156, 84, 84)),
                            border: OutlineInputBorder(),
                            hintText: 'Enter Serial',
                            prefixIcon: Icon(Icons.qr_code_2_outlined),
                          ),
                          textInputAction: TextInputAction.go,
                          onEditingComplete: () {
                            _search();
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(
                            //     content: Text('Enter pressed!'),
                            //   ),
                            // );
                            _serialNumberController.clear();
                          },
                        )),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _search();
                        },
                        child: const Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 5), //DIVIDER START

            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(120, 80)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.tag,
                              size: 28), // Adjust size as needed
                        ),
                        const Text('DISCOUNT'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(120, 80)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.barcode,
                              size: 28), // Adjust size as needed
                        ),
                        const Text('SCAN'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (kDebugMode) {
                        print(itemsList.length);
                      }
                      if (itemsList.isEmpty) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Empty Transaction'),
                                content: const Text(
                                    'Your transaction list is empty. Please add items before proceeding to payment.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            });
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              // alignment: Alignment.center,
                              title: const Text(
                                'PAYMENT METHOD',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      String paymenttype = 'EPAYMENT';
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  'Select E-Payment type'),
                                              content: Container(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    'GCASH INFO, Total: ${formatAsCurrency(calculateGrandTotal())}'),
                                                                content:
                                                                    SizedBox(
                                                                  height: 300,
                                                                  width: 300,
                                                                  child: Column(
                                                                      children: [
                                                                        TextField(
                                                                          controller:
                                                                              _referenceidController,
                                                                          decoration:
                                                                              const InputDecoration(labelText: "Reference ID"),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        TextField(
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          inputFormatters: [
                                                                            CurrencyInputFormatter(
                                                                              leadingSymbol: CurrencySymbols.PESO,
                                                                            ),
                                                                          ],
                                                                          onChanged:
                                                                              (value) {
                                                                            // Remove currency symbols and commas to get the numeric value
                                                                            String
                                                                                numericValue =
                                                                                value.replaceAll(
                                                                              RegExp('[${CurrencySymbols.PESO},]'),
                                                                              '',
                                                                            );
                                                                            setState(() {
                                                                              cashAmount = double.tryParse(numericValue) ?? 0;
                                                                            });
                                                                          },
                                                                          decoration:
                                                                              const InputDecoration(
                                                                            hintText:
                                                                                'Enter amount',
                                                                            border:
                                                                                OutlineInputBorder(),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                      ]),
                                                                ),
                                                                actions: [
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      String
                                                                          paymentname =
                                                                          "GCASH";
                                                                      String
                                                                          message =
                                                                          "";
                                                                      String
                                                                          title =
                                                                          "";

                                                                      if (cashAmount ==
                                                                          0) {
                                                                        message +=
                                                                            "Please enter amount to proceed.";
                                                                        title +=
                                                                            "[Enter Amount]";
                                                                      }
                                                                      if (cashAmount <
                                                                          calculateGrandTotal()) {
                                                                        message +=
                                                                            "Please enter the right amount received from e-payment.";
                                                                        title +=
                                                                            "[Insufficient Funds]";
                                                                      }

                                                                      if (message !=
                                                                          "") {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return AlertDialog(
                                                                                title: Text(title),
                                                                                content: Text(message),
                                                                                actions: [
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.of(context).pop(); // Close the dialog
                                                                                    },
                                                                                    child: const Text('OK'),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            });
                                                                      } else {
                                                                        String
                                                                            referenceid =
                                                                            _referenceidController.text;
                                                                        detailid++;
                                                                        _transaction(
                                                                            detailid.toString(),
                                                                            posid,
                                                                            helper.GetCurrentDatetime(),
                                                                            shift,
                                                                            paymenttype,
                                                                            jsonEncode(itemsList),
                                                                            calculateGrandTotal().toString(),
                                                                            widget.fullname,
                                                                            referenceid,
                                                                            paymentname);

                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }
                                                                    },
                                                                    style:
                                                                        ButtonStyle(
                                                                      backgroundColor:
                                                                          MaterialStateProperty.all<
                                                                              Color>(
                                                                        Colors
                                                                            .brown, // Change the color here
                                                                      ),
                                                                      // Other button styles...
                                                                    ),
                                                                    child: const Text(
                                                                        'Proceed'),
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        minimumSize:
                                                            const Size(80, 60),
                                                      ),
                                                      child:
                                                          const Text('GCASH'),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        String paymentname =
                                                            'PAYMAYA';
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    'GCASH INFO, Total: ${formatAsCurrency(calculateGrandTotal())}'),
                                                                content:
                                                                    SizedBox(
                                                                  height: 300,
                                                                  width: 300,
                                                                  child: Column(
                                                                      children: [
                                                                        TextField(
                                                                          controller:
                                                                              _referenceidController,
                                                                          decoration:
                                                                              const InputDecoration(labelText: "Reference ID"),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        TextField(
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          inputFormatters: [
                                                                            CurrencyInputFormatter(
                                                                              leadingSymbol: CurrencySymbols.PESO,
                                                                            ),
                                                                          ],
                                                                          onChanged:
                                                                              (value) {
                                                                            // Remove currency symbols and commas to get the numeric value
                                                                            String
                                                                                numericValue =
                                                                                value.replaceAll(
                                                                              RegExp('[${CurrencySymbols.PESO},]'),
                                                                              '',
                                                                            );
                                                                            setState(() {
                                                                              cashAmount = double.tryParse(numericValue) ?? 0;
                                                                            });
                                                                          },
                                                                          decoration:
                                                                              const InputDecoration(
                                                                            hintText:
                                                                                'Enter amount',
                                                                            border:
                                                                                OutlineInputBorder(),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                      ]),
                                                                ),
                                                                actions: [
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      String
                                                                          message =
                                                                          "";
                                                                      String
                                                                          title =
                                                                          "";

                                                                      if (cashAmount ==
                                                                          0) {
                                                                        message +=
                                                                            "Please enter amount to proceed.";
                                                                        title +=
                                                                            "[Enter Amount]";
                                                                      }
                                                                      if (cashAmount <
                                                                          calculateGrandTotal()) {
                                                                        message +=
                                                                            "Please enter the right amount received from e-payment.";
                                                                        title +=
                                                                            "[Insufficient Funds]";
                                                                      }

                                                                      if (message !=
                                                                          "") {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (BuildContext context) {
                                                                              return AlertDialog(
                                                                                title: Text(title),
                                                                                content: Text(message),
                                                                                actions: [
                                                                                  TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.of(context).pop(); // Close the dialog
                                                                                    },
                                                                                    child: const Text('OK'),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            });
                                                                      } else {
                                                                        String
                                                                            referenceid =
                                                                            _referenceidController.text;
                                                                        detailid++;
                                                                        _transaction(
                                                                            detailid.toString(),
                                                                            posid,
                                                                            helper.GetCurrentDatetime(),
                                                                            shift,
                                                                            paymenttype,
                                                                            jsonEncode(itemsList),
                                                                            calculateGrandTotal().toString(),
                                                                            widget.fullname,
                                                                            referenceid,
                                                                            paymentname);

                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }
                                                                    },
                                                                    style:
                                                                        ButtonStyle(
                                                                      backgroundColor:
                                                                          MaterialStateProperty.all<
                                                                              Color>(
                                                                        Colors
                                                                            .brown, // Change the color here
                                                                      ),
                                                                      // Other button styles...
                                                                    ),
                                                                    child: const Text(
                                                                        'Proceed'),
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        minimumSize:
                                                            const Size(80, 60),
                                                      ),
                                                      child:
                                                          const Text('PAYMAYA'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(120, 100),
                                    ),
                                    child: const Text('E-PAYMENT'),
                                  ),
                                  const SizedBox(
                                      width: 16), // Add spacing between buttons
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Cash Payment'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    'Please collect cash from the customer. Total: ${formatAsCurrency(calculateGrandTotal())}'),
                                                const SizedBox(
                                                  height: 16,
                                                ), // Add spacing between text and text field

                                                TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    CurrencyInputFormatter(
                                                      leadingSymbol:
                                                          CurrencySymbols.PESO,
                                                    ),
                                                  ],
                                                  onChanged: (value) {
                                                    // Remove currency symbols and commas to get the numeric value
                                                    String numericValue =
                                                        value.replaceAll(
                                                      RegExp(
                                                          '[${CurrencySymbols.PESO},]'),
                                                      '',
                                                    );
                                                    setState(() {
                                                      cashAmount =
                                                          double.tryParse(
                                                                  numericValue) ??
                                                              0;
                                                    });
                                                  },
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: 'Enter amount',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ////ARECEIPT
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  String message = "";
                                                  String title = "";

                                                  if (cashAmount == 0) {
                                                    message +=
                                                        "Please enter cash tendered to proceed.";
                                                    title += "[Enter Amount]";
                                                  }
                                                  if (cashAmount <
                                                      calculateGrandTotal()) {
                                                    message +=
                                                        "Please enter the right amount of cash.";
                                                    title +=
                                                        "[Insufficient Funds]";
                                                  }

                                                  if (message != "") {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(title),
                                                            content:
                                                                Text(message),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(); // Close the dialog
                                                                },
                                                                child:
                                                                    const Text(
                                                                        'OK'),
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  } else {
                                                    detailid++;
                                                    _transaction(
                                                        detailid.toString(),
                                                        posid,
                                                        helper
                                                            .GetCurrentDatetime(),
                                                        shift,
                                                        'CASH',
                                                        jsonEncode(itemsList),
                                                        calculateGrandTotal()
                                                            .toString(),
                                                        widget.fullname,
                                                        'none',
                                                        'none');

                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(
                                                    Colors
                                                        .brown, // Change the color here
                                                  ),
                                                  // Other button styles...
                                                ),
                                                child: const Text('Proceed'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(120, 100),
                                    ),
                                    child: const Text('CASH'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(120, 80)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.moneyBill,
                              size: 28), // Adjust size as needed
                        ),
                        const Text('PAYMENT'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ), //END

            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      others();
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                          const Size(120, 80)), // Adjust the size here
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              10.0), // Adjust padding as needed
                          child: const FaIcon(FontAwesomeIcons.gears,
                              size: 32), // Adjust size as needed
                        ),
                        const Text('OTHERS'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ), //END

            const Center(
              child: Text('Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 5),

            Wrap(
                spacing: 8, // Adjust the spacing between buttons
                runSpacing: 8, // Adjust the vertical spacing between rows
                children: category),
          ],
        ),
      ),
    );
  }
}
