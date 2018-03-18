//
//  ViewController.m
//  Record
//
//  Created by 领琾 on 2018/1/12.
//  Copyright © 2018年 领琾. All rights reserved.
//

#import "ViewController.h"
#import "DeviceManager.h"
#import "HttpTool.h"

@interface ViewController ()

@property (nonatomic,copy) NSString *filePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *titleArray = @[@"录音",@"取消",@"完成",@"播放",@"停止播放",@"上传"];
    NSArray *selctors = @[@"record",@"cancel",@"done",@"play",@"stopPlaying",@"upload"];
    for (int i = 0; i < titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor greenColor]];
        button.frame = CGRectMake(100, 100 + 50 * i, 100, 40);
        [button addTarget:self action:NSSelectorFromString(selctors[i]) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
}

- (void)record {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    [[DeviceManagerBase sharedInstance] asyncStartRecordingWithFileName:str completion:^(NSError *error) {
        if (error) {
            NSLog(@"开启录音失败:%@",error.localizedDescription);
        }else {
            NSLog(@"开始录音");
        }
    }];
}

- (void)cancel {
    [[DeviceManagerBase sharedInstance] cancelCurrentRecording];
    NSLog(@"录音取消");
}

- (void)done {
    [[DeviceManagerBase sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (error) {
            NSLog(@"录音失败:%@",error.localizedDescription);
        }else {
            self.filePath = recordPath;
            NSLog(@"录音完成,录音路径:%@,录音时长:%tu",recordPath,aDuration);
        }
    }];
}

- (void)play {
    if (!self.filePath) {
        NSLog(@"请先录音");
        return;
    }
    if ([DeviceManagerBase sharedInstance].isPlaying) {
        [[DeviceManagerBase sharedInstance] stopPlaying];
    }
    [[DeviceManagerBase sharedInstance] asyncPlayingWithPath:self.filePath completion:^(NSError *error) {
        if (error) {
            NSLog(@"播放失败:%@",error.localizedDescription);
        }else {
            NSLog(@"开始播放");
        }
    }];
}

- (void)stopPlaying {
    if ([DeviceManagerBase sharedInstance].isPlaying) {
        [[DeviceManagerBase sharedInstance] stopPlaying];
    }
    NSLog(@"停止播放");
}

- (void)upload {
    NSURL *mp3Url =  [NSURL URLWithString:self.filePath];//本例子是将本地的 .caf 文件上传到服务器上面去
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"image/jpeg", nil];
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"action"] = @"999";
    [manager POST:@"http://push.hjourney.cn/api.php?c=Index2" parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        //              application/octer-stream   audio/mpeg video/mp4   application/octet-stream
        
        /* url      :  本地文件路径
         * name     :  与服务端约定的参数
         * fileName :  自己随便命名的
         * mimeType :  文件格式类型 [mp3 : application/octer-stream application/octet-stream] [mp4 : video/mp4]
         */
        [formData appendPartWithFileURL:mp3Url name:@"video" fileName:@"xxx.mp3" mimeType:@"application/octet-stream" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        float progress = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        NSLog(@"上传进度-----   %f",progress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"上传成功 %@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"上传失败 %@",error);
    }];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
