import 'package:flutter_cloud_vod_upload_sdk/upload_plugin.dart';
import 'package:flutter_cloud_vod_upload_sdk/upload_task.dart';
import 'package:flutter_cloud_vod_upload_sdk/upload_task_queue.dart';

class UploadTaskController {
  static final UploadTaskController _singleton =
      UploadTaskController._internal();

  factory UploadTaskController() {
    return _singleton;
  }

  UploadTaskController._internal()
      : _failedTasks = [],
        _uploadTaskQueue = UploadTaskQueue<UploadTask?>();

  void _onStart(value) {
    if (_currentTask?.onStart != null)
      _currentTask?.onStart!(value['data']['taskId']);
  }

  void _onProgress(value) {
    if (_currentTask?.onProgress != null)
      _currentTask?.onProgress!(
          value['data']['total'], value['data']['complete']);
  }

  void _onFail(value) {
    if (_currentTask?.onFail != null) {
      final json = value?['data'];
      _currentTask?.onFail!(UploadTaskCompleteInfo(
          retCode: json?['retCode'], reason: json?['descMsg']));
    }
    _currentTask!.status = UploadTaskStatus.failed;
    _runNextTask();
  }

  void _onSuccess(value) {
    if (_currentTask?.onSuccess != null) {
      _currentTask?.onSuccess!(UploadTaskCompleteInfo(
          videoURL: value['data']['videoURL'],
          videoId: value['data']['videoId'],
          coverURL: value['data']['coverURL']));
    }
    _currentTask!.status = UploadTaskStatus.completed;
    _runNextTask();
  }

  UploadTaskQueue<UploadTask?> _uploadTaskQueue;
  late TencentVodVideoUpload _uploadPlugin;

  bool _isInitialize = false;

  ///上传失败的任务
  List<UploadTask?> _failedTasks;

  ///当前上传的任务
  UploadTask? _currentTask;

  Future<void> initialize(
      {required String appID, required String videoId}) async {
    if(_isInitialize)
      return;
    _isInitialize = true;
    _uploadTaskQueue = UploadTaskQueue<UploadTask?>();
    _uploadPlugin = TencentVodVideoUpload(onStart: _onStart,
        onProgress: _onProgress, onFail: _onFail, onSuccess: _onSuccess);
    _currentTask = null;
    await _uploadPlugin.initialize(appID: appID, videoId: videoId);
  }

  ///取消上传操作
  Future<void> cancelTask(UploadTask task) async {
    assert(_isInitialize, 'call initialize 完成初始化');

    if (_currentTask == task) {
      await _uploadPlugin.cancelUploadVideoFile();
      _currentTask!.status = UploadTaskStatus.cancelled;
      _runNextTask();
    } else {
      _uploadTaskQueue.removeTask(task);
      task.status = UploadTaskStatus.cancelled;
    }
  }

  ///增任务任务
  void addTask(UploadTask uploadTask) {
    assert(_isInitialize, 'call initialize 完成初始化');
    // assert(uploadTask.signature != null, 'signature is null');
    // assert(uploadTask.fileName != null, 'fileName is null');
    // assert(uploadTask.filePath != null, 'filePath is null');

    _uploadTaskQueue.addTask(uploadTask);
    if (_currentTask == null) {
      _currentTask = _uploadTaskQueue.task;
      _runTask();
    }
  }

  ///运行
  void _runTask() {
    _currentTask!.status = UploadTaskStatus.running;
//    print('_currentTask ${_currentTask.toString()}');
    _uploadVideo();
  }

  ///运行下一个task
  void _runNextTask() {
    if (_currentTask?.status == UploadTaskStatus.failed) {
      _failedTasks.add(_currentTask);
    }
    _uploadTaskQueue.removeTask(_currentTask);
    _currentTask = null;

    if (_uploadTaskQueue.isEmpty) {
      return;
    }
    _currentTask = _uploadTaskQueue.task;
    _runTask();
  }

  ///上传文件
  void _uploadVideo() async {
    await _uploadPlugin.uploadVideoFile(
        fileName: _currentTask!.fileName,
        videoPath: _currentTask!.filePath,
        coverPath: _currentTask!.coverPath,
        signature: _currentTask!.signature,
        taskId: _currentTask!.taskId);
  }

  void prepareUpload(String sign) {
    _uploadPlugin.prepareUpload(sign);
  }
}
