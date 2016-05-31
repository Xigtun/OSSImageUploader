//
//  OSSImageUploader.m
//  OSSImsgeUpload
//
//  Created by cysu on 5/31/16.
//  Copyright © 2016 cysu. All rights reserved.
//

#import "OSSImageUploader.h"
#import <AliyunOSSiOS/OSSService.h>

@implementation OSSImageUploader
static NSString *const AccessKey = @"your-key";
static NSString *const SecretKey = @"your-secret";
static NSString *const BucketName = @"your-bucket";
static NSString *const AliYunHost = @"http://oss-cn-shenzhen.aliyuncs.com/";

static NSString *kTempFolder = @"temp";


+ (void)asyncUploadImage:(UIImage *)image complete:(void(^)(NSArray<NSString *> *names,UploadImageState state))complete
{
    [self uploadImages:@[image] isAsync:YES complete:complete];
}

+ (void)syncUploadImage:(UIImage *)image complete:(void(^)(NSArray<NSString *> *names,UploadImageState state))complete
{
    [self uploadImages:@[image] isAsync:NO complete:complete];
}

+ (void)asyncUploadImages:(NSArray<UIImage *> *)images complete:(void(^)(NSArray<NSString *> *names, UploadImageState state))complete
{
    [self uploadImages:images isAsync:YES complete:complete];
}

+ (void)syncUploadImages:(NSArray<UIImage *> *)images complete:(void(^)(NSArray<NSString *> *names, UploadImageState state))complete
{
    [self uploadImages:images isAsync:NO complete:complete];
}

+ (void)uploadImages:(NSArray<UIImage *> *)images isAsync:(BOOL)isAsync complete:(void(^)(NSArray<NSString *> *names, UploadImageState state))complete
{
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AccessKey                                                                                                            secretKey:SecretKey];
    
    OSSClient *client = [[OSSClient alloc] initWithEndpoint:AliYunHost credentialProvider:credential];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = images.count;
    
    NSMutableArray *callBackNames = [NSMutableArray array];
    int i = 0;
    for (UIImage *image in images) {
        if (image) {
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                //任务执行
                OSSPutObjectRequest * put = [OSSPutObjectRequest new];
                put.bucketName = BucketName;
                NSString *imageName = [kTempFolder stringByAppendingPathComponent:[[NSUUID UUID].UUIDString stringByAppendingString:@".jpg"]];
                put.objectKey = imageName;
                [callBackNames addObject:imageName];
                NSData *data = UIImageJPEGRepresentation(image, 0.3);
                put.uploadingData = data;
                
                OSSTask * putTask = [client putObject:put];
                [putTask waitUntilFinished]; // 阻塞直到上传完成
                if (!putTask.error) {
                    NSLog(@"upload object success!");
                } else {
                    NSLog(@"upload object failed, error: %@" , putTask.error);
                }
                if (isAsync) {
                    if (image == images.lastObject) {
                        NSLog(@"upload object finished!");
                        if (complete) {
                            complete([NSArray arrayWithArray:callBackNames] ,UploadImageSuccess);
                        }
                    }
                }
            }];
            if (queue.operations.count != 0) {
                [operation addDependency:queue.operations.lastObject];
            }
            [queue addOperation:operation];
        }
        i++;
    }
    if (!isAsync) {
        [queue waitUntilAllOperationsAreFinished];
        NSLog(@"haha");
        if (complete) {
            if (complete) {
                complete([NSArray arrayWithArray:callBackNames], UploadImageSuccess);
            }
        }
    }
}


@end
