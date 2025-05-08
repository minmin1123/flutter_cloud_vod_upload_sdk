### 使用说明
参考[官方Flutter 上传 SDK](https://cloud.tencent.com/document/product/266/100979)先接入到Flutter项目中：

（1）将前面的源码复制到项目中，并在`pubspec.yaml`中引入，比如：

```
flutter_cloud_vod_upload_sdk:
  path: ../flutter_cloud_vod_upload_sdk
```

（2）申请上传签名：参考[官方指引](https://cloud.tencent.com/document/product/266/9221)

（3）创建任务`UploadTask`并上传，任务参数：

 - `taskId`：任务唯一id
 - `signature`：上传签名
 - `fileName`：视频文件名
 - `filePath`：视频本地路径
 - `coverPath`：封面本地路径

```
static Future<UploadTask> uploadVideo(
  UploadTaskController controller,
  String taskId,
  String signature,
  String fileName,
  String filePath,
  String coverPath, {
  ValueChanged<String>? onStart,
  UploadProgressCallBack? onProgress,
  ValueChanged<UploadTaskCompleteInfo>? onSuccess,
  ValueChanged<UploadTaskCompleteInfo>? onFail,
}) async {
  var task = UploadTask(
    taskId: taskId,
    signature: signature,
    fileName: fileName,
    filePath: filePath,
    coverPath: coverPath,
    onStart: onStart,
    onProgress: onProgress,
    onFail: onFail,
    onSuccess: onSuccess,
  );
  controller.addTask(task);
  return task;
}
```

（4）上传结果回调在`UploadTaskCompleteInfo`，包括：

- `videoId`：视频文件id
- `videoURL`：视频存储地址
- `coverURL`：封面存储地址
- `retCode`：错误码
- `descMsg`：错误描述信息