//
//  HttpTool.h
//  Record
//
//  Created by 领琾 on 2018/1/15.
//  Copyright © 2018年 领琾. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void (^HttpToolsBlock) (id result, NSError* error);

@interface HttpTool : NSObject

@property(nonatomic,strong)AFHTTPSessionManager *manager;
/**
 *当前的请求operation队列
 */
@property (nonatomic, strong) NSOperationQueue* operationQueue;
+(HttpTool*)shareInstance;

+ (NSURLSessionDataTask *)uploadImageWithUrl:(NSString *)url image:(UIImage *)image parameters:(NSDictionary *)dict completion:(HttpToolsBlock)block;

@end
