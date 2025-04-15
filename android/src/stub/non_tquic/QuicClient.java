package com.sirius.cloud_vod_upload_sdk.videoupload.impl;

import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.text.TextUtils;

import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * quic process class
 * quic处理类
 */
public class QuicClient {
    public static final int PORT = 443;

    private final Handler mHandler;


    public QuicClient(Context context) {
        mHandler = new Handler(context.getMainLooper());
    }



    public static void setTnetConfig() {
        //empty impl
//        QuicClientImpl.setTnetConfig(new TnetConfig.Builder()
//                .setIsCustom(false)
//                .setTotalTimeoutMillis(TVCConstants.UPLOAD_TIME_OUT_SEC * 1000)
//                .setConnectTimeoutMillis(TVCConstants.UPLOAD_CONNECT_TIME_OUT_MILL)
//                .build());
    }


    /**
     * Check if the QUIC link is connected
     * <p>1. Whether the URL supports QUIC</p>
     * <p>2. Whether the current network environment supports QUIC/UDP links</p>
     * <h1>3. Need to run in a sub-thread</h1>
     *
     * 查询quic链路是否连通
     * <p>1、url是否支持quic</p>
     * <p>2、当前网络环境是否支持quic/udp链路</p>
     * <h1>3、需要在子线程运行</h1>
     */
    public void detectQuic(final String domain, final QuicDetectListener listener) {
        listener.onQuicDetectDone(false, -1, -1);// not support
    }

    public interface QuicDetectListener {
        void onQuicDetectDone(boolean isQuic, long requestTime, int errorCode);
    }

    public static void setupQuic() {
        
    }

}
