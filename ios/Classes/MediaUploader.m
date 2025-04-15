//
//  MediaUploader.m
//  videoplayers
//
//  Created by 熊朝伟 on 2018/11/1.
//

#import "MediaUploader.h"
#import "TXUGCPublish.h"

@interface MediaUploader ()<TXVideoPublishListener>
@property (nonatomic) void (^ start)(id);
@property (nonatomic) void (^ completion)(id);
@property (nonatomic) void(^failed)(id);
@property (nonatomic) void(^progress)(id);

@end

@implementation MediaUploader {
    TXUGCPublish *_publish;
    NSString *_signature;
    NSString * _taskId;
}

- (instancetype)initWithSignature:(NSString *)signature
                           taskId:(NSString *)taskId
                            start:(void(^)(id))start
                         progress:(void(^)(id))progress
                       completion:(void(^)(id))completion
                           failed:(void(^)(id))failed {
    if ((self = [super init])) {
        _signature = signature;
        _start = start;
        _progress = progress;
        _completion = completion;
        _failed = failed;
        _taskId = taskId;
    }
    return self;
}

- (void)dealloc {
    if (_progress) { _progress = nil; }
    if (_completion) { _completion = nil; }
    if (_failed) { _failed = nil; }
}

- (int)uploadVideoFile:(NSString *)videoPath fileName:(NSString *)fileName coverPath:(NSString *)coverPath appId:(NSString *)appId taskId:(NSString *)taskId {
    _publish = [[TXUGCPublish alloc] initWithUserID:[NSBundle mainBundle].bundleIdentifier];
    _publish.appId = [appId intValue];
    _publish.delegate = self;
    
    TXPublishParam *params = [[TXPublishParam alloc] init];
    params.signature = _signature;
    params.videoPath = videoPath;
    params.coverPath = coverPath;
    params.fileName = fileName;
    CFRetain((__bridge CFTypeRef)self);
    int ret = [_publish publishVideo:params];
    //成功启动上传流程,回调开始上传
    if (ret == 0) {
        if (_start) {
            NSString *taskIdArg = nil != taskId ? taskId : @"";
            _start(@{@"taskId": taskIdArg});
        }
        if (self.videoPublishListener) {
            [self.videoPublishListener onPublishStart:taskId];
        }
    }
    return ret;
}

- (void)cancel {
    [_publish canclePublish];
}

- (void)onPublishProgress:(NSInteger)uploadBytes totalBytes:(NSInteger)totalBytes {
    if (self.videoPublishListener) {
        [self.videoPublishListener onPublishProgress:uploadBytes totalBytes:totalBytes];
    }
    if (_progress) {
        _progress(@{
            @"complete": @(uploadBytes),
            @"total": @(totalBytes),
        });
    }
}

- (void)onPublishComplete:(TXPublishResult *)result {
    if (self.videoPublishListener) {
        [self.videoPublishListener onPublishCompleteWithTaskId:result taskId:_taskId];
    }
    if (result && 0 == result.retCode) {
        if (_completion) {
            _completion(@{
                @"retCode": @(result.retCode),
                @"descMsg": result.descMsg ?: [NSNull null],
                @"videoId": result.videoId ?: [NSNull null],
                @"videoURL": result.videoURL ?: [NSNull null],
                @"coverURL": result.coverURL ?: [NSNull null]
            });
        }
    } else {
        if (_failed) {
            _failed(@{
                @"retCode": @(result.retCode),
//                @"errorCode":@(result.errorCode)?: [NSNull null],
                @"descMsg": result.descMsg ?: [NSNull null],
            });
        }
    }
    CFRelease((__bridge CFTypeRef)self);
}

- (void)onPublishEvent:(NSDictionary *)evt {
}

@end
