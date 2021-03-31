import 'package:flutter/material.dart';
import 'package:quick_blue/quick_blue.dart';
import 'dart:developer' as Developer;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Bluetooth Device Scanning Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _deviceIdList = [];
  bool _isScanning = false;

  void _toggleScan() {
    if (_isScanning) {
      QuickBlue.stopScan();
      _resetDeviceIdList();
    } else {
      QuickBlue.scanResultStream.listen((event) {
        var deviceDesc = '${event.name} (${event.deviceId})';
        Developer.log('discovered: $deviceDesc', name: 'bluetooth');
        _addDeviceId(deviceDesc);
      });
      QuickBlue.startScan();
    }

    setState(() {
      _isScanning = !_isScanning;
    });
  }

  void _addDeviceId(String deviceId) {
    if (_deviceIdList.contains(deviceId)) {
      return;
    }

    setState(() {
      _deviceIdList.add(deviceId);
    });
  }

  void _resetDeviceIdList() {
    setState(() {
      _deviceIdList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    var deviceIdTextList = _deviceIdList.length > 0
        ? _deviceIdList.map((e) => Text(e)).toList()
        : [
            Text(_isScanning
                ? 'Searching...'
                : 'Tap the bluetooth button to start scanning.')
          ];

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title!),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: deviceIdTextList,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleScan,
        tooltip: 'Scan Bluetooth Devices',
        child: _isScanning ? RefreshProgressIndicator() : Icon(Icons.bluetooth),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
