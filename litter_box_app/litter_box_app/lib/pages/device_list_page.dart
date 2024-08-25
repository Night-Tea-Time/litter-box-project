import 'package:cat_monitoring_app/components/my_button.dart';
import 'package:cat_monitoring_app/components/my_drawer.dart';
import 'package:cat_monitoring_app/firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/device.dart';
import '../theme/color.dart';

class DeviceListPage extends StatefulWidget {
  static const title = 'Devices';
  static const androidIcon = Icon(Icons.devices);

  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> nearbyDevices = [];

  void _startScan() async {
    
    if (await _checkPermissions()) {
      flutterBlue.startScan(timeout: Duration(seconds: 4));

      flutterBlue.scanResults.listen((results) {
        setState(() {
          nearbyDevices = results.map((r) => r.device).toList();
        });
      });

      flutterBlue.stopScan();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bluetooth permissions are not granted')),
      );
    }
  }

  Future<bool> _checkPermissions() async {
    if (await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted) {
      return true;
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
      return statuses[Permission.bluetoothScan]!.isGranted &&
          statuses[Permission.bluetoothConnect]!.isGranted &&
          statuses[Permission.location]!.isGranted;
    }
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: Text(
            DeviceListPage.title,
            style: GoogleFonts.fredoka(
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
        ),
        drawer: MyDrawer(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(children: [
            SizedBox(height: 20),
            FutureBuilder<List<Device>>(
              future: fetchDevices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No devices found.'));
                }

                final devices = snapshot.data!;

                return Expanded(
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) =>
                        DeviceTile(device: devices[index], onTap: () {}),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            MyButton(
                onTap: () {
                  // error
                  //_startScan();
                  //_showNearbyDevices(context);

                },
                text: "New Litterbox"),
          ]),
        ));
  }

  void _showNearbyDevices(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: nearbyDevices.length,
        itemBuilder: (context, index) {
          final device = nearbyDevices[index];
          return ListTile(
            title: Text(device.name ?? 'Unknown Device'),
            subtitle: Text(device.id.toString()),
            onTap: () {
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(context) {
    return _buildAndroid(context);
  }
}

class DeviceTile extends StatelessWidget {
  final Device device;
  final void Function()? onTap;

  const DeviceTile({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: greyForTile,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    device.name,
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "ID: ${device.id}",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: deleteDevice,
              icon: Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }

  void deleteDevice() {
    // Implement delete device functionality here
  }
}
