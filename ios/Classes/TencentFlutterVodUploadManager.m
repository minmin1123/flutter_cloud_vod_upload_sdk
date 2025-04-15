//
//  TencentVodUploadManager.m
//  tencent_flutter_cloud_vod_upload_sdk
//
//  Created by chengjian on 2022/5/24.
//

#import "TencentFlutterVodUploadManager.h"
#import "MediaUploader.h"
@implementation TencentFlutterVodUploadManager
{
    NSMutableDictionary *_publisherDic;
}
+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TencentFlutterVodUploadManager alloc] init];
    });
    return sharedInstance;
}

- (NSMutableDictionary *)publisherDic {
    if (_publisherDic == nil) {
        _publisherDic = [[NSMutableDictionary alloc] init];
    }
    return _publisherDic;
}

- (void)setVideoPublishListener:(NSString *)taskId listener:(id<TXVideoPublishListener>)listener{
    @try {
        @synchronized(self) {
            if (![TencentFlutterVodUploadManager isTaskIdValid:taskId]) {
                return;
            }
            MediaUploader *uploader = [[self publisherDic] objectForKey:taskId];
            if (nil != uploader && [uploader isKindOfClass:[MediaUploader class]]) {
                uploader.videoPublishListener = listener;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"meemo setVideoPublishListener exception=%@", exception);
    } @finally {
    }
}

- (void)addUploader:(NSString *)taskId uploader:(MediaUploader *)uploader {
    @try {
        @synchronized(self) {
            if (![TencentFlutterVodUploadManager isTaskIdValid:taskId]) {
                return;
            }
            if (uploader == nil) {
                return;
            }
            [[self publisherDic] setObject:uploader forKey:taskId];
        }
    } @catch (NSException *exception) {
        NSLog(@"meemo addUploader exception=%@", exception);
    } @finally {
    }
}

- (void)removeUploader:(NSString *)taskId {
    @try {
        @synchronized(self) {
            if (![TencentFlutterVodUploadManager isTaskIdValid:taskId]) {
                return;
            }
            [[self publisherDic] removeObjectForKey:taskId];
        }
    } @catch (NSException *exception) {
        NSLog(@"meemo removeUploader exception=%@", exception);
    } @finally {
    }
}

- (void)cancelPublish:(NSString *)taskId {
    @try {
        @synchronized(self) {
            if (![TencentFlutterVodUploadManager isTaskIdValid:taskId]) {
                return;
            }
            MediaUploader *uploader = [[self publisherDic] objectForKey:taskId];
            if (nil != uploader && [uploader isKindOfClass:[MediaUploader class]]) {
                [uploader cancel];
                [[self publisherDic] removeObjectForKey:taskId];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"meemo cancelPublish exception=%@", exception);
    } @finally {
    }
}

- (void)uploadVideo:(NSString *)taskId appId:(NSString *)appId sign:(NSString *)sign filePath:(NSString *)filePath fileName:(NSString *)fileName coverPath:(NSString *)coverPath listener:(id<TXVideoPublishListener>)listener{
    MediaUploader *uploader = [[self publisherDic] objectForKey:taskId];
    if (nil == uploader) {
        uploader = [[MediaUploader alloc] initWithSignature:sign taskId:taskId start:^(id value) {
        } progress:^(id value) {
        } completion:^(id value) {
            [[TencentFlutterVodUploadManager sharedInstance] removeUploader:taskId];
        } failed:^(NSDictionary *result) {
            [[TencentFlutterVodUploadManager sharedInstance] removeUploader:taskId];
        }];
    }
    [self addUploader:taskId uploader:uploader];
    uploader.videoPublishListener = listener;
    //开始上传
    int retCode = [uploader uploadVideoFile:filePath fileName:fileName coverPath:coverPath appId:appId taskId:taskId];
    if (0 != retCode && nil!=listener) {
        TXPublishResult *result = [[TXPublishResult alloc]init];
        result.retCode =retCode;
        result.descMsg = @"参数错误";
        [listener onPublishComplete:result];
    }
}

+ (BOOL)isTaskIdValid:(NSString *)taskId{
    if (taskId == nil || ![taskId isKindOfClass:[NSString class]]) {
        return false;
    }
    if ([taskId length] == 0) {
        return false;
    }
    return true;
}
@end
