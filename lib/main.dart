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

class DeviceDescriptor {
  late String id;
  late String name;

  DeviceDescriptor(this.id, this.name);
}

class _MyHomePageState extends State<MyHomePage> {
  List<DeviceDescriptor> _deviceList = [];
  bool _isScanning = false;
  String _statusText = 'no device connected.';

  @override
  void initState() {
    super.initState();

    QuickBlue.setConnectionHandler((deviceId, state) {
      Developer.log('$deviceId ${state.value}', name: 'bluetooth');
      var device = _deviceList.firstWhere((element) => element.id == deviceId);
      var statusText = '${device.id}(${device.name}) is ${state.value}.';
      setState(() {
        _statusText = statusText;
      });
    });
  }

  void _toggleScan() {
    if (_isScanning) {
      QuickBlue.stopScan();
      _resetDeviceList();
    } else {
      QuickBlue.scanResultStream.listen((event) {
        var deviceId = event.deviceId;
        var deviceName = event.name;
        Developer.log('discovered: $deviceId - $deviceName', name: 'bluetooth');
        _addDevice(id: deviceId, name: deviceName);
      });
      QuickBlue.startScan();
    }

    setState(() {
      _isScanning = !_isScanning;
    });
  }

  void _addDevice({id: String, name: String}) {
    if (-1 != _deviceList.indexWhere((element) => element.id == id)) {
      return;
    }

    setState(() {
      _deviceList.add(DeviceDescriptor(id, name));
    });
  }

  void _resetDeviceList() {
    setState(() {
      _deviceList.clear();
    });
  }

  void _onTapDeviceRowAtIndex(int index) {
    var deviceId = _deviceList[index].id;
    QuickBlue.connect(deviceId);

    if (_isScanning) {
      QuickBlue.stopScan();
      setState(() {
        _isScanning = false;
      });
    }
  }

  ListView _renderDeviceListView() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.bluetooth_outlined),
          title: Text(_deviceList[index].id),
          subtitle: Text(_deviceList[index].name),
          onTap: () {
            _onTapDeviceRowAtIndex(index);
          },
        );
      },
      itemCount: _deviceList.length,
    );
  }

  Widget _renderStatusBar() {
    return Container(
      height: 32,
      color: Colors.black12,
      child: Center(
        child: Text(_statusText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var statusBar = _renderStatusBar();
    var contentView = _deviceList.length > 0
        ? _renderDeviceListView()
        : Text(_isScanning
            ? 'Searching...'
            : 'Tap the bluetooth button to start scanning.');

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
      body: Column(
        children: <Widget>[
          statusBar,
          Expanded(child: contentView),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleScan,
        tooltip: 'Scan Bluetooth Devices',
        child: _isScanning
            ? RefreshProgressIndicator()
            : Icon(Icons.bluetooth_searching),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
