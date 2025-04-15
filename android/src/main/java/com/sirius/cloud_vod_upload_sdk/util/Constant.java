package com.sirius.cloud_vod_upload_sdk.util;

/*
 * Create by Chivan on 2020/07/06
 * Copyright © 2018 Tencent
 *
 * Description:
 */
public class Constant {

    // request methods
    public static final String METHOD_INITIALIZE = "initialize";
    public static final  String METHOD_UPLOAD_VIDEO = "uploadVideoFile";
    public static final String METHOD_CANCEL_UPLOAD_VIDEO = "cancelUploadVideoFile";
    public static final String PREPARE_UPLOAD= "prepareUpload";

    // request params
    public static final String PARAM_TASK_ID = "taskId";
    public static final String PARAM_SIGN = "sign";
    public static final String PARAM_APID = "qcloud-appid";
    public static final String PARAM_VIDEO_APID = "qcloud-video-appid";
    public static final String PARAM_REGION = "qcloud-region";
    public static final String PARAM_LICENCE_URL = "qcloud-licenceUrl";
    public static final String PARAM_LICENCE_KEY = "qcloud-licenceKey";
    public static final String PARAM_FILE_NAME = "fileName";
    public static final String PARAM_COVER = "cover";
    public static final String PARAM_SRC_PATH = "path";

    // response methods
    public static final String PARAM_ON_SUCCESS = "onSuccess";
    public static final String PARAM_ON_PROGRESS = "onProgress";
    public static final String PARAM_ON_START= "onStart";
    public static final String PARAM_ON_FAIL = "onFail";

    // error codes
    public static final String ERROR_CODE_PREX = "sdk_";
    public static final String ERROR_FILE_NOT_EXIST = "ai_1000";
    public static final String ERROR_PARM_INVALID = "ai_1001";

}
