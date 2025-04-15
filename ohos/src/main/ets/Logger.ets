import hilog from '@ohos.hilog';

const MODULE_TAG = '[VideoUpload]';

export class Logger {

  static debug(tag: string, message: string): void {
    Logger.log(hilog.LogLevel.DEBUG, tag, message);
  }

  static info(tag: string, message: string): void {
    Logger.log(hilog.LogLevel.INFO, tag, message);
  }

  static warn(tag: string, message: string): void {
    Logger.log(hilog.LogLevel.WARN, tag, message);
  }

  static error(tag: string, message: string): void {
    Logger.log(hilog.LogLevel.ERROR, tag, message);
  }

  private static log(level: hilog.LogLevel, tag: string, message: string): void {
    const fullMessage = `${MODULE_TAG} ${message}`;
    switch (level) {
      case hilog.LogLevel.DEBUG:
        hilog.debug(0xA001, tag, '%{public}s', fullMessage);
        break;
      case hilog.LogLevel.INFO:
        hilog.info(0xA002, tag, '%{public}s', fullMessage);
        break;
      case hilog.LogLevel.WARN:
        hilog.warn(0xA003, tag, '%{public}s', fullMessage);
        break;
      case hilog.LogLevel.ERROR:
        hilog.error(0xA004, tag, '%{public}s', fullMessage);
        break;
    }
  }
}