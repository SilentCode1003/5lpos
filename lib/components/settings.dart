import 'dart:io';

import 'package:fiveLPOS/repository/customerhelper.dart';
import 'package:fiveLPOS/repository/dbhelper.dart';
import 'package:fiveLPOS/repository/printing.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int currentPage = 1;

  void changePage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: buildBody(),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal.shade400),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('email: 5L Main'),
                  Text('ID: 9999'),
                  Text('POS ID: 1000'),
                ],
              )),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Printer'),
            onTap: () {
              setState(() {
                currentPage = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            onTap: () {
              setState(() {
                currentPage = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.gif_box),
            title: const Text('Products'),
            onTap: () {
              setState(() {
                currentPage = 2;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.discount),
            title: const Text('Discounts & Promo'),
            onTap: () {
              setState(() {
                currentPage = 3;
              });
              Navigator.pop(context);
            },
          ),
          const SizedBox(
            height: 250,
          ),
          const Divider(
            thickness: 4,
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  icon: const Icon(Icons.arrow_back))
            ],
          )
        ]),
      ),
    );
  }

  Widget buildBody() {
    switch (currentPage) {
      case 0:
        return PrinterPage();
      case 1:
        return EmailPage();
      case 2:
        return const ProductPage();
      case 3:
        return const DiscountPromoPage();
      default:
        return Container();
    }
  }
}

class PrinterPage extends StatelessWidget {
  PrinterPage({super.key});

  final TextEditingController _printername = TextEditingController();
  final TextEditingController _printeripaddress = TextEditingController();
  final TextEditingController _printerpaperwidth = TextEditingController();

  DatabaseHelper dbHelper = DatabaseHelper();

  void _printerconfig() async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> printerconfig = await db.query('printer');

    if (printerconfig.isNotEmpty) {
      for (var config in printerconfig) {
        dbHelper.updateItem(config, 'printer', 'name=?', config['name']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(
                  minWidth: 200.0,
                  maxWidth: 380.0,
                ),
                child: TextField(
                  controller: _printername,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    border: OutlineInputBorder(),
                    hintText: 'Priter Name',
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                constraints: const BoxConstraints(
                  minWidth: 200.0,
                  maxWidth: 380.0,
                ),
                child: TextField(
                  controller: _printeripaddress,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'IP Address',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    border: OutlineInputBorder(),
                    hintText: 'Printer IP Address',
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                constraints: const BoxConstraints(
                  minWidth: 200.0,
                  maxWidth: 380.0,
                ),
                child: TextField(
                  controller: _printerpaperwidth,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    labelText: 'Paper',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    border: OutlineInputBorder(),
                    hintText: 'Paper width',
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: ElevatedButton(
                      onPressed: () {
                        _printerconfig();
                      },
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ))),
              const SizedBox(
                height: 5,
              ),
              Container(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    minWidth: 200.0,
                    maxWidth: 380.0,
                  ),
                  child: ElevatedButton(
                      onPressed: () {
                        String ipaddress = _printeripaddress.text;
                        LocalPrint().printnetwork(ipaddress);
                      },
                      child: const Text(
                        'TEST PRINT',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      )))
            ]),
      ),
    );
  }
}

class EmailPage extends StatelessWidget {
  EmailPage({super.key});

  final TextEditingController _emailaddress = TextEditingController();
  final TextEditingController _emailpassword = TextEditingController();
  final TextEditingController _smtpserver = TextEditingController();
  Map<String, dynamic> email = {};

  Future<void> _getemailconfig() async {
    if (Platform.isWindows) {
      email = await Helper().readJsonToFile('email.json');
    }

    if (Platform.isAndroid) {
      email = await Helper().JsonToFileRead('email.json');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(
              minWidth: 200.0,
              maxWidth: 380.0,
            ),
            child: TextField(
              controller: _emailaddress,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'Email Address',
                  prefixIcon: Icon(Icons.email)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            constraints: const BoxConstraints(
              minWidth: 200.0,
              maxWidth: 380.0,
            ),
            child: TextField(
              controller: _emailpassword,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'Email Password',
                  prefixIcon: Icon(Icons.password)),
              obscureText: true,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            constraints: const BoxConstraints(
              minWidth: 200.0,
              maxWidth: 380.0,
            ),
            child: TextField(
              controller: _smtpserver,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  labelText: 'SMTP',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  border: OutlineInputBorder(),
                  hintText: 'SMTP Server',
                  prefixIcon: Icon(Icons.desktop_windows)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
              constraints: const BoxConstraints(
                minHeight: 40,
                minWidth: 200.0,
                maxWidth: 380.0,
              ),
              child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'SAVE',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  )))
        ],
      ),
    );
  }
}

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class DiscountPromoPage extends StatelessWidget {
  const DiscountPromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
