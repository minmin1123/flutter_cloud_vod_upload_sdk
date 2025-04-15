//
//  TencentVodUploadManager.h
//  tencent_flutter_cloud_vod_upload_sdk
//
//  Created by chengjian on 2022/5/24.
//

#import <Foundation/Foundation.h>
#import "TXUGCPublish.h"
@class MediaUploader;
NS_ASSUME_NONNULL_BEGIN

@interface TencentFlutterVodUploadManager : NSObject
+ (instancetype)sharedInstance;
-(void)addUploader:(NSString *)taskId uploader:(MediaUploader *)uploader;
- (void)removeUploader:(NSString *)taskId;
- (void)cancelPublish:(NSString *)taskId;
- (void)setVideoPublishListener:(NSString *)taskId  listener:(nullable id<TXVideoPublishListener>)listener;
- (void)uploadVideo:(NSString *)taskId appId:(NSString *)appId sign:(NSString *)sign filePath:(NSString *)filePath fileName:(NSString *)fileName coverPath:(NSString *)coverPath listener:(id<TXVideoPublishListener>)listener;
@end

NS_ASSUME_NONNULL_END
