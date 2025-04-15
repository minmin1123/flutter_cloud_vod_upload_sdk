package com.sirius.cloud_vod_upload_sdk;

import static android.text.TextUtils.isEmpty;

import android.app.Activity;
import android.content.Context;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import com.sirius.cloud_vod_upload_sdk.videoupload.impl.TVCNetWorkStateReceiver;
import com.sirius.cloud_vod_upload_sdk.videoupload.impl.TXUGCPublishOptCenter;
import com.sirius.cloud_vod_upload_sdk.util.Constant;
import com.sirius.cloud_vod_upload_sdk.util.Util;
import com.sirius.cloud_vod_upload_sdk.videoupload.TXUGCPublish;
import com.sirius.cloud_vod_upload_sdk.videoupload.TXUGCPublishTypeDef;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

//import com.tencent.ugc.TXUGCBase;

/*
 * Create by Chivan on 2020/07/06
 * Copyright © 2018 Tencent
 *
 * Description:
 */

/**
 * TencentFlutterCloudVodUploadSdkPlugin
 */
public class FlutterCloudVodUploadSdkPlugin implements FlutterPlugin, MethodCallHandler,
        ActivityAware, TXUGCPublishTypeDef.ITXVideoPublishListener {

    private static final String TAG = "VodUploadSdkPlugin";

    private static final String CHANNEL_NAME = "flutter_cloud_vod_upload_sdk";

    private MethodChannel channel;
    private Activity mActivity;
    private final Object mActivityLock = new Object();

    private long beginUploadVideo;
    private TXUGCPublish mVideoPublish = null;
    private TVCNetWorkStateReceiver netWorkStateReceiver;
    private Context context;

    public static void registerWith(Registrar registrar) {
        FlutterCloudVodUploadSdkPlugin plugin = new FlutterCloudVodUploadSdkPlugin();
        plugin.setChannel(registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        setChannel(binding.getBinaryMessenger());

        try {
            context = binding.getApplicationContext();
            netWorkStateReceiver = new TVCNetWorkStateReceiver();
            IntentFilter intentFilter = new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION);
            context.registerReceiver(netWorkStateReceiver, intentFilter);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        tearDownChannel();
        try {
            if (context != null && netWorkStateReceiver != null) {
                context.unregisterReceiver(netWorkStateReceiver);
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    private void setChannel(BinaryMessenger messenger) {
        channel = new MethodChannel(messenger, CHANNEL_NAME);
        channel.setMethodCallHandler(this);
    }

    private void tearDownChannel() {
        channel.setMethodCallHandler(null);
        channel = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        synchronized (mActivityLock) {
            mActivity = binding.getActivity();
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        synchronized (mActivityLock) {
            mActivity = null;
        }
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        synchronized (mActivityLock) {
            mActivity = binding.getActivity();
        }
    }

    @Override
    public void onDetachedFromActivity() {
        synchronized (mActivityLock) {
            mActivity = null;
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case Constant.METHOD_INITIALIZE:
                // 腾讯云主帐号appId
                String appId = call.argument(Constant.PARAM_APID);
                // 腾讯云子账号subAppId
                String subAppId = call.argument(Constant.PARAM_VIDEO_APID);
                onInitializeCall(appId, subAppId);
                result.success("initialized success");
                break;
            case Constant.METHOD_UPLOAD_VIDEO:
                String taskId = call.argument(Constant.PARAM_TASK_ID);
                String sign = call.argument(Constant.PARAM_SIGN);
                String srcPath = call.argument(Constant.PARAM_SRC_PATH);
                String fileName = call.argument(Constant.PARAM_FILE_NAME);
                String cover = call.argument(Constant.PARAM_COVER);
                onUploadCall(sign, srcPath, fileName, cover, taskId);
                break;
            case Constant.METHOD_CANCEL_UPLOAD_VIDEO:
                onCancelUploadCall();
                break;
            case Constant.PREPARE_UPLOAD:
                prepareUpload((String)call.argument(Constant.PARAM_SIGN));
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * 初始化
     */
    private void onInitializeCall(String appId, String subAppId) {
        Log.i(TAG, String.format("初始化 params:%s,%s", appId, subAppId));
    }

    /**
     * 用户取消上传
     */
    private void onCancelUploadCall() {
        if (mVideoPublish != null) {
            mVideoPublish.canclePublish();
            Log.i(TAG, "取消上传视频");
        }
    }


    /**
     * 开始上传
     */
    private void onUploadCall(String sign, String srcPath, String fileName, String cover,String taskId) {
        Log.i(TAG, String.format("onUploadVideoCall:sign=%s, srcPath=%s, fileName=%s, cover=%s",
                sign, srcPath, fileName, cover));
        if (isEmpty(sign) || isEmpty(srcPath) || isEmpty(fileName)) {
            Log.e(TAG, String.format("视频上传失败, 请求参数不完善:sign=%s, srcPath=%s, fileName=%s, "
                    + "cover=%s", sign, srcPath, fileName, cover));
            final Map<String, Object> data_error = new HashMap<>();
            data_error.put("retCode", Constant.ERROR_PARM_INVALID);
            data_error.put("descMsg", String.format("请求参数不完善:%s,%s,%s,%s", isEmpty(sign),
                    isEmpty(srcPath), isEmpty(fileName), Util.isFileExist(srcPath)));
            Log.e(TAG, String.format("retCode=%s, descMsg=%s", Constant.ERROR_PARM_INVALID,
                    data_error.get("descMsg").toString()));
            sendResult(Constant.PARAM_ON_FAIL, data_error, taskId,true);
            return;
        }
        if (mVideoPublish == null && null != mActivity) {
            mVideoPublish = new TXUGCPublish(mActivity.getApplicationContext(), "independence_android");
            mVideoPublish.setListener(this);
        }
        VodPublisherManager.getInstance().addPublisher(taskId, mVideoPublish);
        TXUGCPublishTypeDef.TXPublishParam param = new TXUGCPublishTypeDef.TXPublishParam();
        // signature计算规则可参考 https://www.qcloud.com/document/product/266/9221
        param.signature = sign;
        param.videoPath = srcPath;
        param.fileName = fileName;
        param.taskId = taskId;
        if (!isEmpty(cover) && Util.isFileExist(cover)) {
            param.coverPath = cover;
        }
        int publishCode = mVideoPublish.publishVideo(param);
        if (publishCode != 0) {
            String sdkErrorInfo = mVideoPublish.getStatusInfo() != null
                    ? mVideoPublish.getStatusInfo().toString()
                    : "";
            final Map<String, Object> data = new HashMap<>();
            data.put("retCode", Constant.ERROR_CODE_PREX
                    + publishCode);
            data.put("descMsg", ""
                    + publishCode
                    + "，"
                    + sdkErrorInfo);
            Log.e(TAG, "视频上传失败，错误码："
                    + publishCode
                    + "，"
                    + sdkErrorInfo);
            sendResult(Constant.PARAM_ON_FAIL, data, taskId,true);
        } else {
            beginUploadVideo = System.currentTimeMillis();
        }
    }

    @Override
    public void onPublishStart(String taskId) {
        final Map<String, Object> data = new HashMap<>();
        data.put("taskId", taskId);
        sendResult(Constant.PARAM_ON_START, data, taskId,false);
    }

    /**
     * 上传进度回调
     */
    @Override
    public void onPublishProgress(String taskId, long uploadBytes, long totalBytes) {
        if (uploadBytes > 0 && totalBytes > 0) {
            Log.i(TAG, "视频上传进度："
                    + (int) (100 * uploadBytes / totalBytes)
                    + "%， taskId="
                    + taskId);
        }
        final Map<String, Object> data = new HashMap<>();
        data.put("complete", uploadBytes);
        data.put("total", totalBytes);
        sendResult(Constant.PARAM_ON_PROGRESS, data, taskId,false);
    }

    /**
     * 上传结束
     */
    @Override
    public void onPublishComplete(TXUGCPublishTypeDef.TXPublishResult result) {
        VodPublisherManager.getInstance().removePublisher(result.taskId);
        Log.i(TAG, "视频上传结束：code:"
                + result.retCode
                + ", Msg:"
                + (result.retCode == 0
                ? result.videoURL
                : result.descMsg));
        if (result.retCode == TXUGCPublishTypeDef.PUBLISH_RESULT_OK) {
            final Map<String, Object> data_success = new HashMap<>();
            data_success.put("retCode", result.retCode);
            data_success.put("descMsg", result.descMsg);
            data_success.put("videoURL", result.videoURL);
            data_success.put("videoId", result.videoId);
            data_success.put("coverURL", result.coverURL);
            long endTime = System.currentTimeMillis();
            Log.i(TAG, data_success.toString());
            String sdkErrorInfo = mVideoPublish.getStatusInfo() != null
                    ? mVideoPublish.getStatusInfo().toString()
                    : "";
            Log.i(TAG, "视频上传耗时："
                    + Util.formatTime((endTime - beginUploadVideo) / 1000)
                    + "，taskId"
                    + "="
                    + result.taskId
                    + "，"
                    + sdkErrorInfo);
            sendResult(Constant.PARAM_ON_SUCCESS, data_success, result.taskId, true);
        } else {
            String sdkErrorInfo = mVideoPublish.getStatusInfo() != null
                    ? mVideoPublish.getStatusInfo().toString()
                    : "";
            final Map<String, Object> data_error = new HashMap<>();
            data_error.put("retCode", Constant.ERROR_CODE_PREX + result.retCode);
            data_error.put("descMsg", result.descMsg
                    + "，"
                    + sdkErrorInfo);
            Log.e(TAG,
                    "视频上传失败：taskId = "
                            + result.taskId
                            + "，retCode="
                            + (Constant.ERROR_CODE_PREX
                            + result.retCode)
                            + ",descMsg="
                            + result.descMsg
                            + "，"
                            + sdkErrorInfo);
            sendResult(Constant.PARAM_ON_FAIL, data_error, result.taskId, true);
        }
    }

    private void sendResult(final String method, final Map<String, Object> data,String taskId,
                            boolean resetTaskId) {
        if (!TextUtils.isEmpty(taskId)) {
            final Map<String, Object> result = new HashMap<>();
            result.put("id", taskId);
            if (null != data) {
                result.put("data", data);
            }
            synchronized (mActivityLock) {
                if (null != mActivity) {
                    mActivity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            channel.invokeMethod(method, result);
                        }
                    });
                }
            }
            if (resetTaskId) {
                taskId = "";
            }
        }
    }

    /**
     * 预上传。
     * 包含：HTTPDNS 解析、获取建议上传地域、探测最优上传地域
     * 预上传模块会把<域名，IP>映射表和最优上传地域缓存在本地，监听到网络切换时，清空缓存并自动刷新
     * @param signature
     */
    private void prepareUpload(String signature) {
        if (!TextUtils.isEmpty(signature) && mActivity != null) {
            Context appContext = mActivity.getApplicationContext();
            //通过网络广播刷新最佳接入点由于国内权限收紧不可用，这里放到预上传实现
            TXUGCPublishOptCenter.getInstance().prepareUpload((null != appContext) ? appContext : mActivity, signature, null);
        }
    }
}
