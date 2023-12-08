import 'dart:async';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_app_file/open_app_file.dart';


import '../../main.dart';

class UploaderPage extends StatefulWidget {
  const UploaderPage({Key? key}) : super(key: key);

  UploaderPageState createState() => UploaderPageState();
}

class UploaderPageState extends State<UploaderPage> {

  PlatformFile? file;
  String? size;

  Future<void> _uploadArchive() async {
    final completer = Completer<List<int>>();
    final reader = FileReader();

    try{
      reader.onLoad.listen((event) {
        final bytesData = reader.result as List<int>;
        completer.complete(bytesData);
      });

      final bytesData = await completer.future;
      final request = http.MultipartRequest("POST", Uri.parse('http://192.168.0.171:8080/api/gtfshandler/uploadArchive'));
      final headers = {
        "Authorization": "Bearer $jwtToken",
        "Content-Type": "multipart/form-data",
        "Content-Length": bytesData.length.toString(),
        "Accept": "*/*",
      };
      request.headers.addAll(headers);
      request.files.add(http.MultipartFile.fromBytes(
        'uploadedZip',
        bytesData,
        filename: file!.name,
      ));
      final response = await request.send();

      _showMyDialog(response.statusCode == 200);
    } on Exception catch (e){
      _showMyDialog(false);
      print(e);
      throw Exception(e);
    }

    _showMyDialog(false);
  }



  Future<void> _showMyDialog(bool isSuccessful) async {
    final L10n l10n = L10n.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.generalErrorMessage),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(isSuccessful ? l10n.uploadSuccessful : l10n.uploadFailed),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.okButton),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> pickSingleFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = result.files.first;
      file == null ? false : OpenAppFile.open(file!.bytes.toString());
      final kb = file!.size / 1024;
      final mb = kb / 1024;
      final size = (mb >= 1)
          ? '${mb.toStringAsFixed(2)} MB'
          : '${kb.toStringAsFixed(2)} KB';
      this.size = size;
      setState(() {});
    }
  }

  void _logout(){
    jwtToken = "";
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final L10n l10n = L10n.of(context)!;
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient:
                  LinearGradient(colors:
                    [Color.fromARGB(255, 49, 168, 215), Color.fromARGB(255, 58, 207, 100)]
                  )
              ),
            ),
            title: Text(
              l10n.filePickerTitle,
              style: const TextStyle(
                  color: Color.fromARGB(255, 59, 54, 54),
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            )
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 170,
                    ),
                    file == null
                        ? Text(l10n.fileNotFound)
                        : Column(
                      children: [
                        Text('${l10n.nameLabel} - ${file!.name}'),
                        Text('${l10n.sizeLabel} - ${size!}'),
                        Text('${l10n.extensionLabel} - ${file!.extension}')
                      ],
                    ),
                    const SizedBox(
                      height: 170,
                    ),
                    ElevatedButton.icon(
                        onPressed: pickSingleFile,
                        style: const ButtonStyle(
                            backgroundColor:
                            MaterialStatePropertyAll(Color.fromARGB
                              (255, 61, 186, 228)
                            )
                        ),
                        icon: const Icon(Icons.insert_drive_file_sharp),
                        label: Text(
                          l10n.pickFileLabel,
                          style: const TextStyle(fontSize: 25),
                        )
                    ),
                    ElevatedButton.icon(
                        onPressed: _uploadArchive,
                        style: const ButtonStyle(
                            backgroundColor:
                            MaterialStatePropertyAll(Color.fromARGB
                              (255, 61, 186, 228)
                            )
                        ),
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          l10n.uploadFileLabel,
                          style: const TextStyle(fontSize: 25),
                        )
                    ),
                    ElevatedButton.icon(
                        onPressed: _logout,
                        style: const ButtonStyle(
                            backgroundColor:
                            MaterialStatePropertyAll(Color.fromARGB
                              (255, 61, 186, 228)
                            )
                        ),
                        icon: const Icon(Icons.logout),
                        label: Text(
                          l10n.logout,
                          style: const TextStyle(fontSize: 25),
                        )
                    ),
                  ]
              )
          ),
        )
    );
  }
}