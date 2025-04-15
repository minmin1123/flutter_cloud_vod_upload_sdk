import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_cloud_vod_upload_sdk/flutter_cloud_vod_upload_sdk.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PickedFile _pickedFile;
  Dio dio;
  String _signature;
  UploadTask _uploadTask;
  @override
  void initState() {
    dio = Dio();
    dio.options.connectTimeout = 10000;
    dio.options.receiveTimeout = 10000;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                await UploadTaskController().initialize(appID: 'aa', videoId: 'bb');
              },
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5)),
                height: 40.0,
                child: Center(
                  child: Text('init'),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                _pickedFile = await ImagePicker().getVideo(source: ImageSource.gallery);
                print('_pickedFile ${_pickedFile.toString()}');
                setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5)),
                height: 40.0,
                child: Center(
                  child: Text('相册'),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                print('获取签名信息');
                try {
                  Response response = await dio.get('http://demo.vod2.myqcloud.com/shortvideo/api/v1/misc/upload/signature');
                  _signature = response.data['data']['signature'];
                  setState(() {
                    print('_signature = $_signature');
                  });
                } catch (e) {
                  print(e);
                }
              },
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5)),
                height: 40.0,
                child: Center(
                  child: Text('签名'),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                print('上传');
                _uploadTask = UploadTask(
                    fileName: 'aa',
                    signature: _signature,
                    filePath: _pickedFile?.path,
                    coverPath: '',
                    onProgress: (total, progress) {
//                      print('onProgress total = $total progress= $progress');
                    },
                    onSuccess: (value) {
                      print('onSuccess ${_pickedFile?.path}  ${value.toString()}');
                    });
                setState(() {});
                UploadTaskController().addTask(_uploadTask);
              },
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5)),
                height: 40.0,
                child: Center(
                  child: Text('上传'),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                print('取消上传');
                await UploadTaskController().cancelTask(_uploadTask);
              },
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5)),
                height: 40.0,
                child: Center(
                  child: Text('取消上传'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
