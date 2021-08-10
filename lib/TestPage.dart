import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TestPageState();

}

class TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: MaterialButton(
          child: Text("다운로드"),
          onPressed: () async {
            final status = await Permission.storage.status;
            if (status.isGranted) {
              final externalDir = await getExternalStorageDirectory();
              FlutterDownloader.enqueue(
                url: 'https://dl87.dlmate11.xyz/?file=M3R4SUNiN3JsOHJ6WWQ2a3NQS1Y5ZGlxVlZIOCtyZ1VsTlFqeXhrd0ZlQUpnNjlxajhEbGVwMEtDNFJLbEt2bk00b2ZzQnY3TkluY2RTNnE4NzBFQjFMWHNvNXA4bnJxMHNzQ0RJeFFkVlBkdWFQNnNuUlVxa3l3Vy9xSVRlMFRUeTgraG1JbWlnUFdsYW1SbkRlOWtpem8vbTdJUFdFdmtYNVRIN0NKMHRwdDlDenBQN0s4aDl0QWlBTGF1NzhNZzZEWWtTT3o0dVY3NEkwd2UyQXhLc1VZZ01Ldyt0R0poeDljb3NrampoWDB1YXlyRnNwekdxeVNmQWhnUHpZQnRLcTllZ0lSMmpFTCttbjdwSWtvL2pSTUk0WjNyVENTNEtEa1p5dWRNTUg1UXRySllmaXhwOXoxNitwMWdCRCt2L1NLektVV3ZUeWtIc1BBRW9sWW9RRXVzZmZGNHNrNW4zMkxuQW9Da3VrYndWLzFla2xnSDhFWmV5RmZjNVZPWDJnTG90Zm50UFZzcE1jZVBSNjZwYThuS3Vrci84OD0%3D',
                savedDir: externalDir!.path,
                fileName: "download.mp4",
                showNotification: true,
                openFileFromNotification: true,
              ).onError((error, stackTrace) {
                var i = 3;
              });
            } else {
              print('permission dineid');
            }
          },
        ),
      ),
    );
  }

}