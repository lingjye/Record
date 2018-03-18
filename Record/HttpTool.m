//
//  HttpTool.m
//  Record
//
//  Created by 领琾 on 2018/1/15.
//  Copyright © 2018年 领琾. All rights reserved.
//

#import "HttpTool.h"

@implementation HttpTool

+(HttpTool*)shareInstance{
    static HttpTool *request = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        request = [[HttpTool alloc] init];
        
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer.timeoutInterval = 20.0f;
        request.manager = manager;
        request.operationQueue = request.manager.operationQueue;
    });
    
    return request;
}

+ (NSURLSessionDataTask *)uploadImageWithUrl:(NSString *)url image:(UIImage *)image parameters:(NSDictionary *)dict completion:(HttpToolsBlock)block{
    //    manager.securityPolicy=[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    //    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    //    [manager.requestSerializer setValue:@"JPG/PNG"forHTTPHeaderField:@"fileType"];
    AFHTTPSessionManager *manager = [HttpTool shareInstance].manager;
    NSURLSessionDataTask *op = [manager POST:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData* imageData = UIImageJPEGRepresentation(image, 1);
        if (imageData.length/1000 > 50) {
            imageData = UIImageJPEGRepresentation(image, 0.1);
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        //         上传图片，以文件流的格式
        //        [formData appendPartWithHeaders:nil body:imageData];
        [formData appendPartWithFileData:imageData name:@"img" fileName:fileName mimeType:@"image/jpeg/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil,error);
    }];
    return op;
}


@end
