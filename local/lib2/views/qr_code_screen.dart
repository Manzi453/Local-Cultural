import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String? localUrl;

  @override
  void initState() {
    super.initState();
    _getLocalUrl();
  }

  Future<void> _getLocalUrl() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            setState(() {
              localUrl = 'http://${addr.address}:8080';
            });
            return;
          }
        }
      }
    } catch (e) {
      setState(() {
        localUrl = 'Error getting IP';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan to Access on Mobile'),
      ),
      body: Center(
        child: localUrl == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: localUrl!,
                    version: QrVersions.auto,
                    size: 300.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localUrl!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Scan this QR code with your mobile device\nMake sure both devices are on the same Wi-Fi',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
