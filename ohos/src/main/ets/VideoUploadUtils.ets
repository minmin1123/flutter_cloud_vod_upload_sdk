import fs from '@ohos.file.fs';
import { CosClientError, CosError, CosErrorType, CosServiceError } from '@tencentcloud/cos';
import { Logger } from './Logger';

const TAG = 'VideoUploadUtils';

export default class VideoUploadUtils {
  static readonly SLICE_SIZE_MIN: number = 1024 * 1024;
  static readonly SLICE_SIZE_MAX: number = 1024 * 1024 * 10;

  static async hasCover(coverPath: string): Promise<boolean> {
    if (coverPath.length <= 0) {
      return false;
    }
    return await VideoUploadUtils.isFileExist(coverPath);
  }

  static async isFileExist(filePath: string): Promise<boolean> {
    try {
      await fs.access(filePath);
      return true;
    } catch (err) {
      Logger.error(TAG, `isFileExist failed, err: ${JSON.stringify(err)}`);
    }
    return false;
  }

  static getFileName(filePath: string): string {
    const lastIndex = filePath.lastIndexOf('/');
    return lastIndex >= 0
      ? filePath.slice(lastIndex + 1)
      : filePath;
  }

  static async getFileSize(filePath: string): Promise<number> {
    try {
      let fd = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(fd.fd);
      return stat.size;
    } catch (err) {
      Logger.error(TAG, `getFileSize failed, err: ${JSON.stringify(err)}`);
    }
    return -1;
  }

  static getFileExtension(fileName: string): string {
    if (fileName.trim().length === 0) {
      return '';
    }
    // 步骤1：清理路径中的查询参数
    const queryIndex: number = fileName.indexOf('?');
    const cleanPath: string = queryIndex > 0 ? fileName.substring(0, queryIndex) : fileName;
    // 步骤2：获取最后一个有效点号位置
    const lastDotIndex = VideoUploadUtils.findLastValidDotIndex(cleanPath);
    // 无有效扩展名的情况
    if (lastDotIndex === -1 || lastDotIndex >= cleanPath.length - 1) {
      return '';
    }
    // 步骤3：提取并格式化扩展名
    return cleanPath.substring(lastDotIndex + 1).toLowerCase();
  }

  // 查找最后一个有效点号（排除隐藏文件）
  static findLastValidDotIndex(path: string): number {
    // 获取纯文件名（去除路径）
    const filename = path.substring(path.lastIndexOf('/') + 1);
    // 查找最后一个点号
    const dotIndex = filename.lastIndexOf('.');
    // 排除以下情况：
    // 1. 无点号（dotIndex = -1）
    // 2. 点号在开头（隐藏文件，如 ".gitignore"）
    // 3. 点号在末尾（如 "file."）
    return (dotIndex > 0 && dotIndex < filename.length - 1) ?
    path.lastIndexOf('.') : -1;
  }

  static async getSliceSize(filePath: string): Promise<number> {
    // let fileSize: number = await VideoUploadUtils.getFileSize(filePath);
    // let sliceSize = fileSize / 10;
    // if (sliceSize < VideoUploadUtils.SLICE_SIZE_MIN) {
    //   sliceSize = VideoUploadUtils.SLICE_SIZE_MIN;
    // } else if (sliceSize > VideoUploadUtils.SLICE_SIZE_MAX) {
    //   sliceSize = VideoUploadUtils.SLICE_SIZE_MAX;
    // }
    // return sliceSize;
    // todo 分片逻辑&断点续传有时间再继续做
    return 1024 * 1024 * 1024;
  }

  static printError(error: CosError): string{
    if(error.type == CosErrorType.Service){
      let serviceError = error as CosServiceError;
      return JSON.stringify(serviceError)
    } else {
      let clientError = error as CosClientError;
      let errString = `{
      "type": ${clientError.type},
      "code": ${clientError.cosErrorCode},
      "message": ${clientError.message},
      "detailErro": ${JSON.stringify(clientError.detail)},
    }`;
      return errString;
    }
  }
}