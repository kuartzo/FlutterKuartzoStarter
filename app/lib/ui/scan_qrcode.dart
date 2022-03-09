import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';

class ScanQRCode extends StatelessWidget {
  const ScanQRCode({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue,
        title: const Text(
          'ScanQRCode',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('wip'),
            ],
          ),
        ),
      ),
    );
  }
}
