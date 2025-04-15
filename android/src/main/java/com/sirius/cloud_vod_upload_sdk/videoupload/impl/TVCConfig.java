package com.sirius.cloud_vod_upload_sdk.videoupload.impl;

public class TVCConfig {

    public String mCustomKey;

    public String mSignature;

    public boolean mEnableResume = true;

    public boolean mEnableHttps = false;

    public int mVodReqTimeOutInSec = 10;

    public long mSliceSize = 0;

    public int mConcurrentCount = -1;

    public boolean mIsDebuggable = true;

    public long mTrafficLimit = -1;

    public IUploadResumeController mUploadResumeController;
}
