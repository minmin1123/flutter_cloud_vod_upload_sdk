package com.sirius.cloud_vod_upload_sdk;

import android.content.Context;
import android.util.Log;

import com.sirius.cloud_vod_upload_sdk.util.Constant;
import com.sirius.cloud_vod_upload_sdk.videoupload.TXUGCPublish;
import com.sirius.cloud_vod_upload_sdk.videoupload.TXUGCPublishTypeDef;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Created by jackjcheng on 2022/5/18.
 */
public class VodPublisherManager {
    private static final String TAG = "SiriusVPManager";

    private static class SingletonHolder {
        private static final VodPublisherManager INSTANCE = new VodPublisherManager();
    }

    private VodPublisherManager() {
    }

    public static VodPublisherManager getInstance() {
        return SingletonHolder.INSTANCE;
    }

    private final LinkedHashMap<String, TXUGCPublish> publisherMap = new LinkedHashMap<String, TXUGCPublish>();
    private Context appContext;

    public void init(Context context) {
        if (null != context.getApplicationContext()) {
            this.appContext = context.getApplicationContext();
        } else {
            this.appContext = context;
        }
    }


    public void addPublisher(String key, TXUGCPublish publisher) {
        synchronized (this) {
            publisherMap.put(key, publisher);
        }
    }

    public void removePublisher(String key) {
        synchronized (this) {
            publisherMap.remove(key);
        }
    }

    public void cancelPublish(String key) {
        synchronized (this) {
            try {
                TXUGCPublish publisher = publisherMap.get(key);
                if (null != publisher) {
                    publisher.canclePublish();
                }
                publisherMap.remove(key);
            } catch (Throwable e) {
                Log.e(TAG, "cancelPublish e" + e);
            }
        }
    }

    public void setVideoPublishListener(String key, TXUGCPublish.TXVideoPublishListenerWrapper listener) {
        TXUGCPublish publisher = publisherMap.get(key);
        if (null != publisher) {
            publisher.setListenerWrapper(listener);
        }
    }

    public void uploadVideo(String key, TXUGCPublishTypeDef.TXPublishParam param, TXUGCPublish.TXVideoPublishListenerWrapper listener) {
        TXUGCPublish publisher = publisherMap.get(key);
        if (null == publisher) {
            if (null == appContext) {
                TXUGCPublishTypeDef.TXPublishResult result = new TXUGCPublishTypeDef.TXPublishResult();
                result.retCode = -1;
                result.descMsg = "appContext is empty";
                result.taskId = param.taskId;
                listener.onPublishComplete(result);
                return;
            }
            publisher = new TXUGCPublish(appContext, "independence_android");
        }
        addPublisher(key, publisher);
        publisher.setListenerWrapper(listener);
        int publishCode = publisher.publishVideo(param);
        if (publishCode != 0) {
            String sdkErrorInfo = publisher.getStatusInfo() != null
                    ? publisher.getStatusInfo().toString()
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
            TXUGCPublishTypeDef.TXPublishResult result = new TXUGCPublishTypeDef.TXPublishResult();
            result.retCode = publishCode;
            result.descMsg = sdkErrorInfo;
            result.taskId = param.taskId;
            listener.onPublishComplete(result);
        }
    }

}
