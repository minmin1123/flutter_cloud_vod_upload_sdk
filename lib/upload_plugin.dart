import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class TencentVodVideoUpload {
  static const MethodChannel _channel = const MethodChannel('flutter_cloud_vod_upload_sdk');

  ///视频上传开始回调
  final ValueChanged? onStart;
  final ValueChanged? onProgress;
  final ValueChanged? onSuccess;
  final ValueChanged? onFail;

  TencentVodVideoUpload(
      {this.onStart, this.onProgress, this.onSuccess, this.onFail});

  ///初始化接口
  Future<void> initialize({required String appID, required String videoId, ValueChanged? onProgress, ValueChanged? onSuccess, ValueChanged? onFail}) async {
    _channel.setMethodCallHandler(_onMethodCall);
    await _channel.invokeMethod('initialize', {'qcloud-appid': appID, 'qcloud-video-appid': videoId});
  }

  Future<void> _onMethodCall(MethodCall call) async {
//    print('_onMethodCall ${call.toString()}');
    switch (call.method) {
      case 'onStart':
        if (onStart != null) {
          onStart!(call.arguments);
        }
        break;
      case 'onProgress':
        if (onProgress != null) {
          onProgress!(call.arguments);
        }
        break;
      case 'onSuccess':
        if (onSuccess != null) {
          onSuccess!(call.arguments);
        }
        break;
      case 'onFail':
        if (onFail != null) {
          onFail!(call.arguments);
        }

        break;
    }
  }

  ///开始上传
  /// * fileName  文件名
  /// * videoPath 文件路径
  /// * signature 签名信息
  /// * coverPath 封面信息
  Future<bool> uploadVideoFile({String? fileName, String? videoPath, String?
  coverPath, String? signature, String taskId=""}) async {
    if (taskId.isEmpty) {
      taskId = DateTime.now().millisecondsSinceEpoch.toString();
    }
    print('uploadVideoFile');
    if (signature == null || signature.isEmpty || fileName == null || fileName.isEmpty || videoPath == null || videoPath.isEmpty) {
      return false;
    }
//    if (!(await (File(videoPath).exists()))) {
//      ///视频文件不存在
//      return false;
//    }
    print('uploadVideoFile');
    await _channel
        .invokeMethod('uploadVideoFile', {'fileName': fileName, 'sign': signature, 'path': videoPath, 'cover': coverPath, 'coverFile': null, 'taskId': taskId});
    return true;
  }

  ///取消上传
  Future<void> cancelUploadVideoFile() async {
    await _channel.invokeMethod('cancelUploadVideoFile', {});
  }

  Future<void> prepareUpload(String sign) async {
    await _channel.invokeMethod('prepareUpload', {'sign': sign});
  }
}
