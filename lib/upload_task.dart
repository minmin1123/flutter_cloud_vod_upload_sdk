import 'package:flutter/cupertino.dart';

typedef UploadProgressCallBack = Function(int? total, int? progress);

class UploadTask {
  UploadTask(
      {taskId,
      UploadTaskStatus? status,
      required this.signature,
      required this.filePath,
      required this.fileName,
      required this.coverPath,
      this.onProgress,
      this.onStart,
      this.onFail,
      this.onSuccess})
      : taskId = taskId ?? (globalTaskId++).toString(),
        status = status ?? UploadTaskStatus.unStart;

  final String taskId;
  UploadTaskStatus status;
  final String signature;
  final String filePath;
  final String coverPath;
  final String fileName;
  static int globalTaskId = 1;

//  ///上传的回调
  final ValueChanged<UploadTaskCompleteInfo>? onSuccess;
  final ValueChanged<UploadTaskCompleteInfo>? onFail;
  final UploadProgressCallBack? onProgress;
  final ValueChanged<String>? onStart;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadTask &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          status == other.status &&
          signature == other.signature &&
          filePath == other.filePath &&
          coverPath == other.coverPath &&
          fileName == other.fileName &&
          onSuccess == other.onSuccess &&
          onFail == other.onFail &&
          onProgress == other.onProgress &&
          onStart == other.onStart;

  @override
  int get hashCode =>
      taskId.hashCode ^
      status.hashCode ^
      signature.hashCode ^
      filePath.hashCode ^
      coverPath.hashCode ^
      fileName.hashCode ^
      onSuccess.hashCode ^
      onFail.hashCode ^
      onProgress.hashCode ^
      onStart.hashCode;

  @override
  String toString() {
    return 'UploadTask{taskId: $taskId, status: $status, signature: $signature, filePath: $filePath, coverPath: $coverPath, fileName: $fileName, onSuccess: $onSuccess, onFail: $onFail, onProgress: $onProgress}';
  }

//  UploadTask copyWith({UploadTaskStatus status, String cosPath, int total, int progress, UploadTaskCompleteInfo completeInfo}) {
//    return UploadTask(
//        taskId: this.taskId,
//        signature: this.signature,
//        filePath: this.filePath,
//        cosPath: cosPath ?? this.cosPath,
//        status: status ?? this.status,
//        onSuccess: this.onSuccess,
//        onFail: this.onFail,
//        onProgress: this.onProgress);
//  }

}

class UploadTaskCompleteInfo {
  UploadTaskCompleteInfo({this.videoURL, this.videoId, this.coverURL, this.retCode, this.reason});

  final String? videoURL;
  final String? videoId;
  final String? coverURL;
  final String? retCode;
  final String? reason;

  @override
  String toString() {
    return 'UploadTaskCompleteInfo{videoURL: $videoURL, videoId: $videoId, coverURL: $coverURL}';
  }
}

enum UploadTaskStatus { unStart, running, completed, failed, cancelled }
