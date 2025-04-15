//
//  TEMediaUploader.h
//  videoplayers
//
//  Created by 熊朝伟 on 2018/11/1.
//

#import <Foundation/Foundation.h>
#import "TXUGCPublish.h"
NS_ASSUME_NONNULL_BEGIN

@interface MediaUploader : NSObject
//meemo add start
@property (nonatomic, weak) id<TXVideoPublishListener> videoPublishListener;
//meemo add end
- (instancetype)initWithSignature:(NSString *)signature
                           taskId:(NSString *)taskId
                            start:(void(^)(id))start
                         progress:(void(^)(id))progress
                       completion:(void(^)(id))completion
                           failed:(void(^)(id))failed;

- (int)uploadVideoFile:(NSString *)videoPath
              fileName:(NSString *)fileName
             coverPath:(NSString *)coverPath
                 appId:(NSString *)appId taskId:(NSString *)taskId;

- (void)cancel;


@end

NS_ASSUME_NONNULL_END
