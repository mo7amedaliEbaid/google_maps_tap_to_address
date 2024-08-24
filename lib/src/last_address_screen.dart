import 'package:flutter/material.dart';

class LastAddressScreen extends StatelessWidget {
  final String? address;

  const LastAddressScreen({Key? key, this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Last Saved Address'),
      ),
      body: Center(
        child: address != null
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            address!,
            style: const TextStyle(fontSize: 18),
          ),
        )
            : const Text('No address saved yet.',
            style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
