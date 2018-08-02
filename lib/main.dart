import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';


void main() => runApp(new MyApp());

String _inputErrorText;
String receiver = "Kenneth";


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Blockchain Demo',
      home: new MyTabbedPage(),
    );
  }
}

class MyTabbedPage extends StatefulWidget {
  const MyTabbedPage({Key key}) : super(key: key);

  @override
  _MyTabbedPageState createState() => new _MyTabbedPageState();
}


class _MyTabbedPageState extends State<MyTabbedPage> with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    new Tab(text: 'Send'),
    new Tab(text: 'Receive'),
    new Tab(text: 'Blocks'),
  ];

  TabController _tabController;
  TextEditingController _FromFieldcontroller;
  TextEditingController _ToFieldcontroller;
  final _formKey = GlobalKey<FormState>();
  String result = "";
  
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: myTabs.length);
    _FromFieldcontroller = new TextEditingController(text: receiver);
    _ToFieldcontroller = new TextEditingController(text: result);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
         _ToFieldcontroller = new TextEditingController(text: result);
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Wallet"),
        bottom: new TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: new TabBarView(
        controller: _tabController,
        children: myTabs.map((Tab tab) {
          final bodyHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom;
          
          if (tab.text=='Send') { 
              print("Send"); 
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'From:'
                      ),
                      controller: _FromFieldcontroller,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'From Address is required';
                        }
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'To:'
                      ),
                      controller: _ToFieldcontroller,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'To Address is required';
                        }
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Amount:'
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Amount is required';
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: 
                          RaisedButton(
                                onPressed: () {
                                  // Validate will return true if the form is valid, or false if
                                  // the form is invalid.
                                  if (_formKey.currentState.validate()) {
                                    // If the form is valid, we want to show a Snackbar
                                    Scaffold
                                        .of(context)
                                        .showSnackBar(SnackBar(content: Text('Sending ...')));
                                  }
                                },
                                child: Text('Transfer'),
                              ),
                    ),
                  ],
                ),
              );
          }
          if (tab.text=='Receive') { 
              return new Center(child: new Center(
                child: new QrImage(
                    data: receiver,
                    size: 0.5 * bodyHeight,
                    onError: (ex) {
                      print("[QR] ERROR - $ex");
                      setState((){
                        _inputErrorText = "Error! Maybe your input value is too long?";
                      });
                    },
                  ),
                //new Text(tab.text)
              )
            ); 
          } else { 
              print("Blocks"); 
              return new Center(child: new Text(tab.text)); 
          } 
          
          
        }).toList(),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the Drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Logo'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Setting'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        //onPressed: () => _tabController.animateTo((_tabController.index + 1) % 2), // Switch tabs
        onPressed: _scanQR,
        child: new Icon(Icons.camera_alt),
      ),
    );
  }
}