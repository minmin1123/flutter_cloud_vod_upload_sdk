import 'dart:collection';

class UploadTaskQueue<T> {
  UploadTaskQueue() : uploadQueue = Queue();
  final Queue<T> uploadQueue;
  bool addTask(T task) {
    if (task == null) {
      return false;
    }
    uploadQueue.addLast(task);
    return true;
  }

  bool removeTask(T task) {
    return uploadQueue.remove(task);
  }

  bool get isEmpty => uploadQueue.isEmpty;

  T? get task => uploadQueue.first;
}
