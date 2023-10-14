// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pos2/api/branch.dart';
import 'package:pos2/components/circularprogressbar.dart';
import 'package:pos2/components/loadingspinner.dart';
import 'package:pos2/components/loginpage.dart';
import 'package:pos2/repository/dbhelper.dart';
import 'package:pos2/api/posconfig.dart';
import 'package:sqflite/sqlite_api.dart';

class PosConfig extends StatefulWidget {
  const PosConfig({super.key});

  @override
  State<PosConfig> createState() => _PosConfigState();
}

class _PosConfigState extends State<PosConfig> {
  final TextEditingController _posidController = TextEditingController();
  final TextEditingController _branchidController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _emailPasswordController =
      TextEditingController();
  final TextEditingController _emailServerController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper();
  @override
  void initState() {
    _check();
    super.initState();
  }

  Future<void> _check() async {
    Database db = await dbHelper.database;
    List<Map<String, dynamic>> posconfig = await db.query('pos');
    List<Map<String, dynamic>> branchconfig = await db.query('branch');
    List<Map<String, dynamic>> emailconfig = await db.query('email');

    if (posconfig.isNotEmpty &&
        branchconfig.isNotEmpty &&
        emailconfig.isNotEmpty) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      if (posconfig.isNotEmpty) {
        for (var pos in posconfig) {
          // String name = pos['posid'];
          print('${pos['posid']}');
          setState(() {
            _posidController.text = pos['posid'].toString();
          });
          // Process data
        }
      }

      if (branchconfig.isNotEmpty) {
        for (var branch in branchconfig) {
          // String name = pos['posid'];
          print('${branch['branchid']}');

          setState(() {
            _branchidController.text = branch['branchid'];
          });
          // Process data
        }
      }

      if (emailconfig.isNotEmpty) {
        for (var email in emailconfig) {
          // String name = pos['posid'];
          print(
              '${email['emailaddress']} ${email['emailpassword']} ${email['emailserver']}');

          setState(() {
            _emailAddressController.text = email['emailaddress'];
            _emailPasswordController.text = email['emailpassword'];
            _emailServerController.text = email['emailserver'];
          });
          // Process data
        }
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Not yet configured'),
          content: const Text('Please enter POS ID and SYNC to Server'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _sync() async {
    String branch = '';
    String pos = '';
    String email = '';

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CircularProgressBar(
            status: 'Loading...',
          );
        });

    branch = await _getbranch();

    if (branch != 'success') {
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CircularProgressBar(
              status: 'Branch Done Syncing...',
            );
          });
    }

    pos = await _getposconfig();
    if (pos != 'success') {
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CircularProgressBar(
              status: 'POS Done Syncing...',
            );
          });
    }

    email = await _emailconfig();
    if (email != 'success') {
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CircularProgressBar(
              status: 'Email Done Syncing...',
            );
          });
    }

    if (email == '' || branch == '' || pos == '') {
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Success'),
          content: Text('POS ${_posidController.text} sync successfully'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<String> _getposconfig() async {
    try {
      Database db = await dbHelper.database;
      String posid = _posidController.text;
      final result = await PosConfigAPI().posconfig(posid);
      final jsonData = json.encode(result['data']);

      List<Map<String, dynamic>> posconfig = await db.query('pos');

      if (posconfig.isNotEmpty) {
        for (var pos in posconfig) {
          // String name = pos['posid'];
          print('${pos['posid']}');

          dbHelper.updateItem(pos, 'pos', 'posid=?', pos['posid']);
          // Process data
        }
        Navigator.pop(context);
        return 'success';
      } else {
        if (jsonData.length != 2) {
          for (var data in json.decode(jsonData)) {
            await dbHelper.insertItem({
              "posid": data['posid'],
              "posname": data['posname'],
              "serial": data['serial'],
              "min": data['min'],
              "ptu": data['ptu'],
            }, 'pos');
          }

          List<Map<String, dynamic>> posconfig = await db.query('pos');
          for (var pos in posconfig) {
            // String name = pos['posid'];
            print('${pos['posid']} ${pos['posname']}');
            // Process data
          }

          Navigator.pop(context);

          return 'success';
        } else {
          Navigator.of(context).pop();

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Not Found'),
              content: const Text('POS ID has no confuguration'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          return 'POS ID has no confuguration';
        }
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> _getbranch() async {
    try {
      Database db = await dbHelper.database;
      String branchid = _branchidController.text;
      final results = await BranchAPI().getBranch(branchid);
      final jsonData = json.encode(results['data']);
      List<Map<String, dynamic>> branchconfig = await db.query('branch');

      if (branchconfig.isNotEmpty) {
        for (var branch in branchconfig) {
          // String name = pos['posid'];
          print('${branch['posid']}');

          dbHelper.updateItem(
              branch, 'branch', 'branchid=?', branch['branchid']);
          // Process data
        }
        Navigator.pop(context);
        return 'success';
      } else {
        if (jsonData.length != 2) {
          for (var data in json.decode(jsonData)) {
            await dbHelper.insertItem({
              "branchid": data['branchid'],
              "branchname": data['branchname'],
              "tin": data['tin'],
              "address": data['address'],
              "logo": data['logo'],
            }, 'branch');
          }

          List<Map<String, dynamic>> branchconfig = await db.query('branch');
          for (var branch in branchconfig) {
            print(
                '${branch['branchname']} ${branch['tin']} ${branch['address']}');
          }
          Navigator.pop(context);
          return 'success';
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Not Found'),
              content: const Text('Branch ID has no confuguration'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );

          return 'Branch ID has no confuguration';
        }
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> _emailconfig() async {
    try {
      Database db = await dbHelper.database;
      String emailaddress = _emailAddressController.text;
      String emailpassword = _emailPasswordController.text;
      String emailserver = _emailServerController.text;

      List<Map<String, dynamic>> emailconfig = await db.query('email');

      if (emailconfig.isNotEmpty) {
        for (var email in emailconfig) {
          // String name = pos['posid'];
          print('${email['posid']}');

          dbHelper.updateItem(
              email, 'email', 'emailaddress=?', email['emailaddress']);
          // Process data
        }
        Navigator.pop(context);
        return
         'success';
      } else {
        await dbHelper.insertItem({
          "emailaddress": emailaddress,
          "emailpassword": emailpassword,
          "emailserver": emailserver,
        }, 'email');

        List<Map<String, dynamic>> branchconfig = await db.query('email');
        for (var branch in branchconfig) {
          print(
              '${branch['emailaddress']} ${branch['emailpassword']} ${branch['emailserver']}');
        }
        Navigator.pop(context);
        return 'success';
      }
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                'POS Config',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: _branchidController,
                decoration: const InputDecoration(labelText: "BRANCH ID"),
              ),
              TextFormField(
                controller: _posidController,
                decoration: const InputDecoration(labelText: "POS ID"),
              ),
              const SizedBox(height: 32),
              const Text(
                'Email Config',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: _emailAddressController,
                decoration: const InputDecoration(labelText: "EMAIL ADDRESS"),
              ),
              TextFormField(
                controller: _emailPasswordController,
                decoration: const InputDecoration(labelText: "EMAIL PASSWORD"),
              ),
              TextFormField(
                controller: _emailServerController,
                decoration: const InputDecoration(labelText: "EMAIL SERVER"),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  _sync();
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 80)),
                child: const Text("SYNC"),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
