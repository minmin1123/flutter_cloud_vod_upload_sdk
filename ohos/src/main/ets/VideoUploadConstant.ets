export class VideoUploadConstant {
  // request methods
  public static readonly METHOD_INITIALIZE = "initialize";
  public static readonly METHOD_UPLOAD_VIDEO = "uploadVideoFile";
  public static readonly METHOD_CANCEL_UPLOAD_VIDEO = "cancelUploadVideoFile";
  public static readonly PREPARE_UPLOAD = "prepareUpload";
  // request params
  public static readonly PARAM_TASK_ID = "taskId";
  public static readonly PARAM_SIGN = "sign";
  public static readonly PARAM_FILE_NAME = "fileName";
  public static readonly PARAM_COVER = "cover";
  public static readonly PARAM_SRC_PATH = "path";
  // response methods
  public static readonly PARAM_ON_SUCCESS = "onSuccess";
  public static readonly PARAM_ON_PROGRESS = "onProgress";
  public static readonly PARAM_ON_START= "onStart";
  public static readonly PARAM_ON_FAIL = "onFail";
}