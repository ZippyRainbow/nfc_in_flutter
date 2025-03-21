import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'dart:async';
import 'dart:io';

class RecordEditor {
  TextEditingController mediaTypeController = TextEditingController();
  TextEditingController payloadController = TextEditingController();

  /*RecordEditor() {
    mediaTypeController = TextEditingController();
    payloadController = TextEditingController();
  }*/
}

class WriteExampleScreen extends StatefulWidget {
  const WriteExampleScreen({Key? key}) : super(key: key);

  @override
  _WriteExampleScreenState createState() => _WriteExampleScreenState();
}

class _WriteExampleScreenState extends State<WriteExampleScreen> {
  StreamSubscription<NDEFMessage>? _stream;
  final List<RecordEditor> _records = [];
  bool _hasClosedWriteDialog = false;

  void _addRecord() {
    setState(() {
      _records.add(RecordEditor());
    });
  }

  void _write(BuildContext context) async {
    List<NDEFRecord> records = _records.map((record) {
      return NDEFRecord.type(
        record.mediaTypeController.text,
        record.payloadController.text,
      );
    }).toList();
    NDEFMessage message = NDEFMessage.withRecords(records);

    // Show dialog on Android (iOS has it's own one)
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Scan the tag you want to write to"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                _hasClosedWriteDialog = true;
                _stream?.cancel();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    // Write to the first tag scanned
    await NFC.writeNDEF(message).first;
    if (!_hasClosedWriteDialog) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write NFC example"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Center(
            child: OutlinedButton(
              child: const Text("Add record"),
              onPressed: _addRecord,
            ),
          ),
          for (var record in _records)
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Record", style: Theme.of(context).textTheme.bodyMedium),
                  TextFormField(
                    controller: record.mediaTypeController,
                    decoration: const InputDecoration(
                      hintText: "Media type",
                    ),
                  ),
                  TextFormField(
                    controller: record.payloadController,
                    decoration: const InputDecoration(
                      hintText: "Payload",
                    ),
                  )
                ],
              ),
            ),
          Center(
            child: ElevatedButton(
              child: const Text("Write to tag"),
              onPressed: _records.isNotEmpty ? () => _write(context) : null,
            ),
          ),
        ],
      ),
    );
  }
}
