import common from '@ohos.app.ability.common';
import http from '@ohos.net.http';
import { MethodChannel } from '@ohos/flutter_ohos';
import {
  ApplyUploadUGCData,
  ApplyUploadUGCReply,
  CommitUploadUGCCData,
  CommitUploadUGCReply
} from './VideoUploadData';
import {
  CosXmlBaseService,
  CosXmlServiceConfig,
  HttpProgress,
  InitMultipartUploadRequest,
  PutObjectRequest,
  QCloudCredential,
  TransferConfig,
  UploadTask
} from '@tencentcloud/cos';
import VideoUploadUtils from './VideoUploadUtils';
import { HashMap } from '@kit.ArkTS';
import { VideoUploadConstant } from './VideoUploadConstant';
import { Logger } from './Logger';

const TAG = 'VideoUploadMgr';

export default class VideoUploadMgr {
  context: common.Context;
  channel: MethodChannel | null;
  private service: CosXmlBaseService | null = null;
  private credential: QCloudCredential | null = null;

  constructor(context: common.Context, channel: MethodChannel | null) {
    this.context = context;
    this.channel = channel;
  }

  /**
   * 视频上传接口
   * @param sign 签名
   * @param filePath 视频文件路径
   * @param fileName 视频文件名
   * @param coverPath 封面图文件路径
   * @param taskId 上传任务id
   */
  async uploadFile(sign: string, filePath: string, fileName: string, coverPath: string, taskId: string) {
    if (sign.length <= 0 || filePath.length <= 0 || fileName.length <= 0) {
      Logger.error(TAG,
        `uploadFile failed, because request params empty,sign=${sign} ,filePath=${filePath},fileName=${fileName}`);
      this.sendFailResult();
      return;
    }
    const hasVideo = await VideoUploadUtils.isFileExist(filePath);
    if (!hasVideo) {
      const descMsg = `uploadFile failed, because video file not exist`;
      Logger.error(TAG, descMsg);
      this.sendFailResult();
      return;
    }
    let data: ApplyUploadUGCData | null = await this.getApplyUploadUGCData(sign, filePath, fileName, coverPath);
    if (data != null) {
      this.initCosService(this.context, data);
      this.uploadVideo(data, sign, filePath, coverPath, taskId);
    } else {
      this.sendFailResult();
    }
  }

  private async getApplyUploadUGCData(sign: string, filePath: string,
    fileName: string, coverPath: string): Promise<ApplyUploadUGCData | null> {
    // 步骤1：获取上传票据
    let data: ApplyUploadUGCData | null = null;
    try {
      const fileSize: number = await VideoUploadUtils.getFileSize(filePath);
      const fileType: string = VideoUploadUtils.getFileExtension(fileName);
      const hasCover: boolean = await VideoUploadUtils.hasCover(coverPath);
      const coverName: string = hasCover ? VideoUploadUtils.getFileName(coverPath) : '';
      const coverSize: number = hasCover ? await VideoUploadUtils.getFileSize(coverPath) : 0;
      const coverType: string = hasCover ? VideoUploadUtils.getFileExtension(coverName) : '';
      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
        },
        extraData: {
          signature: sign,
          videoName: fileName,
          videoType: fileType,
          videoSize: fileSize,
          coverName: coverName,
          coverType: coverType,
          coverSize: coverSize,
          clientReportId: 'independence_android',
          clientVersion: '1.1.19.0',
        },
      };
      const url =
        `https://vod2.qcloud.com/v3/index.php?Action=ApplyUploadUGC`;
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, options);
      if (response.responseCode === http.ResponseCode.OK) {
        const result: string = response.result.toString();
        Logger.info(TAG, `getApplyUploadUGCData result: ${result}`);
        const reply: ApplyUploadUGCReply = JSON.parse(result);
        if (reply.code == 0) {
          data = reply.data;
        }
      } else {
        Logger.error(TAG, `getApplyUploadUGCData failed, errCode: ${response.responseCode}`);
      }
      httpRequest.destroy();
    } catch (error) {
      Logger.error(TAG, `getApplyUploadUGCData failed, err: ${error}`);
    }
    return data;
  }

  private initCosService(context: common.Context, data: ApplyUploadUGCData) {
    // 步骤2：初始化cos
    const credential: QCloudCredential = new QCloudCredential();
    credential.secretID = data.tempCertificate.secretId;
    credential.secretKey = data.tempCertificate.secretKey;
    credential.token = data.tempCertificate.token;
    credential.expirationDate = new Date(data.tempCertificate.expiredTime * 1000);
    this.credential = credential;

    const config = new CosXmlServiceConfig(data.storageRegionV5);
    config.retrySleep = 5 * 1000;
    this.service = new CosXmlBaseService(context, config);
  }

  private async uploadVideo(data: ApplyUploadUGCData, sign: string, filePath: string, coverPath: string,
    taskId: string) {
    // 步骤3：上传视频
    if (this.service == null || this.credential == null) {
      Logger.error(TAG, `uploadVideo error because service or credential null`);
      this.sendFailResult();
      return;
    }
    const bucket: string = `${data.storageBucket}-${data.storageAppId}`;
    const cosPath: string = data.video.storagePath.substring(1);
    const sliceSize: number = await VideoUploadUtils.getSliceSize(filePath);
    const config: TransferConfig = new TransferConfig();
    config.sliceLength = sliceSize;
    const putRequest = new PutObjectRequest(bucket, cosPath, filePath);
    putRequest.credential = this.credential;
    let uploadId = await this.getMultipartUploadId(this.service, this.credential, bucket, cosPath);
    if (uploadId == null) {
      Logger.error(TAG, `uploadVideo error because uploadId null`);
      this.sendFailResult();
      return;
    }
    const task: UploadTask = this.service.upload(putRequest, uploadId, config);
    task.onProgress = (progress: HttpProgress) => {
      this.sendProgressResult(progress.complete, progress.target);
      Logger.info(TAG, `uploadVideo progress: ${progress.complete}, total: ${progress.target}`);
    };
    task.onResult = {
      onSuccess: async (request, result) => {
        Logger.info(TAG, `uploadVideo success`);
        if (await VideoUploadUtils.hasCover(coverPath)) {
          this.uploadCover(data, sign, coverPath, taskId);
        } else {
          const uploadData = await this.getCommitUploadUGC(data, sign);
          if (uploadData != null) {
            this.sendSuccessResult(uploadData.video.url, taskId, uploadData.cover.url);
          } else {
            this.sendFailResult();
          }
        }
      },
      onFail: (request, error) => {
        Logger.error(TAG, `uploadVideo failed, error: ${VideoUploadUtils.printError(error)}`);
        this.sendFailResult();
      }
    }
    task.start();
  }

  private async getMultipartUploadId(service: CosXmlBaseService, credential: QCloudCredential, bucket: string,
    cosPath: string): Promise<string | null> {
    // 步骤4：获取分片上传id
    let uploadId: string | null = null;
    try {
      const putRequest = new InitMultipartUploadRequest(bucket, cosPath);
      putRequest.credential = credential;
      let multipart = await service.initMultipartUpload(putRequest);
      uploadId = multipart.initMultipartUpload?.uploadId ?? null;
      Logger.info(TAG, `getMultipartUploadId uploadId: ${uploadId}`);
    } catch (e) {
      Logger.error(TAG, `getMultipartUploadId failed, err: ${e}`);
    }
    return uploadId;
  }

  private uploadCover(data: ApplyUploadUGCData, sign: string, coverPath: string, taskId: string) {
    // 步骤5：上传封面图
    if (this.service == null || this.credential == null) {
      Logger.error(TAG, `uploadCover error because service or credential null`);
      this.sendFailResult();
      return;
    }
    const bucket: string = `${data.storageBucket}-${data.storageAppId}`;
    const cosPath: string = data.cover.storagePath.substring(1);
    const putRequest = new PutObjectRequest(bucket, cosPath, coverPath);
    putRequest.credential = this.credential;
    const task: UploadTask = this.service.upload(putRequest, taskId);
    task.onProgress = (progress: HttpProgress) => {
      Logger.info(TAG, `uploadCover progress: ${progress.complete}, total: ${progress.target}`);
    };
    task.onResult = {
      onSuccess: async (request, result) => {
        Logger.info(TAG, `uploadCover success`);
        const uploadData = await this.getCommitUploadUGC(data, sign);
        if (uploadData != null) {
          this.sendSuccessResult(uploadData.video.url, taskId, uploadData.cover.url);
        } else {
          this.sendFailResult();
        }
      },
      onFail: (request, error) => {
        Logger.error(TAG, `uploadCover failed, error:${VideoUploadUtils.printError(error)}`);
        this.sendFailResult();
      }
    }
    task.start();
  }

  private async getCommitUploadUGC(data: ApplyUploadUGCData, sign: string): Promise<CommitUploadUGCCData | null> {
    // 步骤6：获取上传结果
    let uploadData: CommitUploadUGCCData | null = null;
    try {
      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
        },
        extraData: {
          signature: sign,
          vodSessionKey: data.vodSessionKey,
          clientReportId: 'independence_android',
          clientVersion: '1.1.19.0',
        },
      };
      const url =
        `https://vod2.qcloud.com/v3/index.php?Action=CommitUploadUGC`;
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, options);
      if (response.responseCode === http.ResponseCode.OK) {
        const result: string = response.result.toString();
        Logger.info(TAG, `getCommitUploadUGC result: ${result}`);
        const reply: CommitUploadUGCReply = JSON.parse(result);
        if (reply.code == 0) {
          uploadData = reply.data;
        }
      } else {
        Logger.error(TAG, `getCommitUploadUGC failed, errCode: ${response.responseCode}`);
      }
      httpRequest.destroy();
    } catch (error) {
      Logger.error(TAG, `getCommitUploadUGC failed, err: ${error}`);
    }
    return uploadData;
  }


  private sendProgressResult(complete: number, total: number) {
    const result = new HashMap<string, number>();
    result.set("complete", complete);
    result.set("total", total);
    this.sendResult(VideoUploadConstant.PARAM_ON_PROGRESS, null, result);
  }

  private sendSuccessResult(videoURL: string, videoId: string, coverURL: string) {
    const result = new HashMap<string, string>();
    result.set("videoURL", videoURL);
    result.set("videoId", videoId);
    result.set("coverURL", coverURL);
    this.sendResult(VideoUploadConstant.PARAM_ON_SUCCESS, result);
  }

  private sendFailResult() {
    const result = new HashMap<string, string>();
    result.set("retCode", '');
    result.set("descMsg", '');
    this.sendResult(VideoUploadConstant.PARAM_ON_FAIL, result);
  }

  private sendResult(method: string, args1?: HashMap<string, string> | null, args2?: HashMap<string, number> | null) {
    const result = new HashMap<string, object>();
    if (args1 != null) {
      result.set("data", args1);
    } else if (args2 != null) {
      result.set("data", args2);
    }
    Logger.info(TAG, `sendResult method: ${method},result = ${result.toString()} `);
    this.channel?.invokeMethod(method, result);
  }
}