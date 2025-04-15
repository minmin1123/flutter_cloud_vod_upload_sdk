#import "MediaUploader.h"
#import "TencentFlutterCloudVodUploadSdkPlugin.h"
#import "TXUGCPublishOptCenter.h"
#import "TencentFlutterVodUploadManager.h"

#define debug 1
#define ERROR_PARM_INVALID      @"ai_1001"
#define ERROR_CODE_PREX         @"sdk_"
static NSString *SafeString(id value) {
    if (!value) return nil;
    if ([value isKindOfClass:[NSNull class]]) return nil;
    return [value isKindOfClass:[NSString class]] ? value : [value description];
}
static BOOL _isFileExists(NSMutableString *descMsg, NSString *fieldName, NSString *path) {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [descMsg appendFormat:@"%@ = \"%@\"(Not Exists), ", fieldName, path];
        return NO;
    }
    return YES;
}
static BOOL _isEmptyText(NSMutableString *descMsg, NSString *fieldName, NSString *text) {
    if ([text length] == 0) {
        if (text == nil) {
            [descMsg appendFormat:@"%@ = null, ", fieldName];
        } else {
            [descMsg appendFormat:@"%@ = \"\", ", fieldName];
        }
        return YES;
    }
    return NO;
}

@implementation TencentFlutterCloudVodUploadSdkPlugin{
   MediaUploader *_mediaUploader;
    FlutterMethodChannel *_channel;
    NSString *_appId;
    NSString *_videoAppId;
  }
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_cloud_vod_upload_sdk"
            binaryMessenger:[registrar messenger]];
  TencentFlutterCloudVodUploadSdkPlugin* instance = [[TencentFlutterCloudVodUploadSdkPlugin alloc] initWithChannel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    if (self = [super init]) {
        _channel = channel;
    }
    return self;
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"initialize" isEqualToString:call.method]) {
        [self initialize:call.arguments];
        result(nil);
    } else if ([@"uploadVideoFile" isEqualToString:call.method]) {
        result([self uploadVideoFile:call.arguments]);
    } else if([@"cancelUploadVideoFile"  isEqualToString:call.method]){
        [self cancelUploadVideoFile];
        result(nil);
    } else if ([@"prepareUpload" isEqualToString:call.method]) {
        [self prepareUpload:(SafeString([call.arguments objectForKey:@"sign"]))];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}
- (NSDictionary *)resultWithCode:(NSString *)retCode descMsg:(NSString *)descMsg {
    return @{ @"retCode": retCode ?: [NSNull null], @"descMsg": descMsg ?: [NSNull null] };
}
- (NSDictionary *)resultWithSDKCode:(NSInteger)retCode descMsg:(NSString *)descMsg {
    return @{ @"retCode": [NSString stringWithFormat:ERROR_CODE_PREX @"%ld", retCode], @"descMsg": descMsg ?: [NSNull null] };
}
- (void)initialize:(NSDictionary *)arguments {
    _appId = SafeString([arguments objectForKey:@"qcloud-appid"]);
    _videoAppId = SafeString([arguments objectForKey:@"qcloud-video-appid"]);

}
- (id)uploadVideoFile:(NSDictionary *)arguments {
//    NSValue *onProgress = [arguments objectForKey:@"onProgress"];
//    NSValue *onSuccess = [arguments objectForKey:@"onSuccess"];
//    NSValue *onFail = [arguments objectForKey:@"onFail"];
    NSString *fileName = SafeString([arguments objectForKey:@"fileName"]);
    NSString *coverPath = SafeString([arguments objectForKey:@"cover"]);
    NSString *signature = SafeString([arguments objectForKey:@"sign"]);
    NSString *path = SafeString([arguments objectForKey:@"path"]);
    NSMutableString *descMsg = [NSMutableString string];

    NSString  * taskId =[arguments objectForKey:@"taskId"];

    if (_isEmptyText(descMsg, @"sign", signature) || !_isFileExists(descMsg, @"path", path)) {
        [self invokeMethod:@"onFail" callbackId:taskId arguments:[self resultWithCode:ERROR_PARM_INVALID descMsg:[NSString stringWithFormat:@"参数错误: %@", descMsg]]];
        return nil;
    } else {
        _mediaUploader = [[MediaUploader alloc] initWithSignature:signature taskId:taskId start:^(id value) {
            [self invokeMethod:@"onStart" callbackId:taskId arguments:value];
        } progress:^(id value) {
            [self invokeMethod:@"onProgress" callbackId:taskId arguments:value];
        } completion:^(id value) {
            [[TencentFlutterVodUploadManager sharedInstance] removeUploader:taskId];
            [self invokeMethod:@"onSuccess" callbackId:taskId arguments:value];
        } failed:^(NSDictionary *result) {
            [[TencentFlutterVodUploadManager sharedInstance] removeUploader:taskId];
            [self invokeMethod:@"onFail" callbackId:taskId arguments:[self resultFromSDK:result]];
        }];
        [[TencentFlutterVodUploadManager sharedInstance] addUploader:taskId uploader:_mediaUploader];
        //开始上传
        int retCode = [_mediaUploader uploadVideoFile:path fileName:fileName coverPath:coverPath appId:_videoAppId taskId:taskId];

        if (0 != retCode) {
            [self invokeMethod:@"onFail" callbackId:taskId arguments:[self resultWithSDKCode:retCode descMsg:@"参数错误"]];
        }
    }
    return nil;
}
- (void)cancelUploadVideoFile {
    [_mediaUploader cancel];
}

- (void)invokeMethod:(NSString *)method callbackId:(NSString *)callbackId arguments:(id)arguments {
    [self->_channel invokeMethod:method arguments:@{
        @"id": callbackId,
        @"data": arguments ?: [NSNull null]
    }];
}
- (NSDictionary *)resultFromSDK:(NSDictionary *)result {
    NSMutableDictionary *dict = [result mutableCopy];
    id retCode = [result objectForKey:@"retCode"];
    NSMutableString * str = [[NSMutableString alloc] init];
    if ([retCode isKindOfClass:[NSNumber class]]) {
        [str appendString:[NSString stringWithFormat:ERROR_CODE_PREX @"%@", retCode]];
    }

    id errorCode = [result objectForKey:@"errorCode"];

    if ([errorCode isKindOfClass:[NSNumber class]]) {
        [str appendString:[NSString stringWithFormat:@"_%@",errorCode]];
    }
    [dict setObject:str forKey:@"retCode"];
    return dict;
}

- (void) prepareUpload: (NSString *) signature {
    @try {
        if (signature == nil || [signature length] == 0)
            return;
        [[TXUGCPublishOptCenter shareInstance] prepareUpload:signature
                                       prepareUploadComplete:nil];
    } @catch(NSException *ex) {
        NSLog(@"meemo prepareUpload exception=%@", ex);
    } @finally{
    }
}
@end
