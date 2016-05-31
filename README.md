# OSSImageUploader

图片上传的基本思路：

1、选择图片

2、将图片保存在本地，同时返回图片路径、并生成缩略图用于 UI 显示。

3、上传图片，成功后将步骤 2 中的图片名传给服务器。

单张图片上传的例子官方的 demo 中已经有了，这里直接上多图上传。

具体实现是结合 NSOperationQueue，设置 operation 间的依赖来实现多图上传。

这里省略步骤 1、2 ，直接上传图片：



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


![Screen Shot 2016-05-31 at 10.09.02 PM.png](http://upload-images.jianshu.io/upload_images/715434-9765eee1b2a5ab48.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


根据返回的地址可以 bucketName + aliYunHost + 地址 在浏览器中直接访问了。
例如 bucketName = "my-bucket"; aliYunHost = "http://oss-cn-shenzhen.aliyuncs.com/"; 返回图片地址 = "temp/69058506-679B-432C-AD11-61A34C067235.jpg";

那么可以通过 “my-bucket.oss-cn-shenzhen.aliyuncs.com/temp/69058506-679B-432C-AD11-61A34C067235.jpg” 直接在浏览器中进行访问
