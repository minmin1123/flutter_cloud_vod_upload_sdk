import VideoUploadMgr from './VideoUploadMgr';
import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodResult,
  MethodChannel,
  AbilityAware,
  AbilityPluginBinding
} from '@ohos/flutter_ohos';
import { VideoUploadConstant } from './VideoUploadConstant';
import { Logger } from './Logger';

const TAG = "FlutterOhosCloudVodUploadSdkPlugin";
const CHANNEL_NAME = 'flutter_cloud_vod_upload_sdk';

export default class FlutterOhosCloudVodUploadSdkPlugin implements FlutterPlugin, AbilityAware, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private mgr: VideoUploadMgr | null = null

  getUniqueClassName(): string {
    return TAG;
  }

  onAttachedToAbility(binding: AbilityPluginBinding) {
    Logger.info(TAG, `onAttachedToAbility`);
  }

  onDetachedFromAbility() {
    Logger.info(TAG, `onDetachedFromAbility`);
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    Logger.info(TAG, `onAttachedToEngine`);
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
    this.mgr = new VideoUploadMgr(binding.getApplicationContext(), this.channel);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    Logger.info(TAG, `onDetachedFromEngine`);
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    let method: string = call.method;
    Logger.info(TAG, `onMethodCall received ${method} message,parmas: ${call}`);
    try {
      switch (method) {
        case VideoUploadConstant.METHOD_UPLOAD_VIDEO:
          const sign: string = call.argument(VideoUploadConstant.PARAM_SIGN);
          const filePath: string = call.argument(VideoUploadConstant.PARAM_SRC_PATH);
          const fileName: string = call.argument(VideoUploadConstant.PARAM_FILE_NAME);
          const coverPath: string = call.argument(VideoUploadConstant.PARAM_COVER);
          const taskId: string = call.argument(VideoUploadConstant.PARAM_TASK_ID);
          this.mgr?.uploadFile(sign, filePath, fileName, coverPath, taskId);
          break;
        default:
          break;
      }
    } catch (err) {
      Logger.error(TAG, `onMethodCall err: ${JSON.stringify(err)}`);
    }
  }
}
