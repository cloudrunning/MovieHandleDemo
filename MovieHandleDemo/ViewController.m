//
//  ViewController.m
//  MovieHandleDemo
//
//  Created by caozhen@neusoft on 16/8/26.
//  Copyright © 2016年 Neusoft. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** iOS上传视频思路
    1.拿到视频资源，现转化为mp4
    2.写进沙盒
    3.上传到服务器
    4.上传成功后删除沙盒中的文件
 */


- (void)getMovieThenTranslateToMp4 {
    
    NSString *filePath = nil;
    NSURL *filePathURL = [NSURL URLWithString:filePath];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:filePathURL options:nil];
    // 给视频重命名
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"output-%@.mp4",[formatter stringFromDate:[NSDate date]]];
    
    NSString *outFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",fileName];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        exportSession.outputURL = [NSURL fileURLWithPath:outFilePath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                // 转换成功,将outPutFile下的文件上传到服务器
                //XTODO
                NSString *discription = nil;

                [self uploadNetworkWithParam:@{@"contenttype":@"application/octet-stream",@"discription":discription
                                            }];

            }else{
                NSLog(@"转换失败，值为:%li，可能的原因:%@",[exportSession status],[[exportSession error] localizedDescription]);
            }
        }];
    }
    


}

- (void)uploadNetworkWithParam:(NSDictionary *)dict {

    AFHTTPRequestSerializer *serializer = [[AFHTTPRequestSerializer alloc]init];

    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:@"上传服务器地址" parameters:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        // formData 拼接视频
        [formData appendPartWithFileURL:[NSURL URLWithString:@"视频路径"] name:@"视频名字" fileName:@"存储在服务器的名字" mimeType:@"application/octet-stream" error:nil];
        
        // formData 拼接视频缩略图
        [formData appendPartWithFileURL:[NSURL URLWithString:@"缩略图路径"] name:@"缩略图名字" fileName:@"存储在服务器的名字" mimeType:@"image/png" error:nil];
        
    } error:nil];
    
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
    }];
    [uploadTask resume];
}

-(void)ClearMovieFromDoucments{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        if ([filename isEqualToString:@"tmp.PNG"]) {
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            continue;
        }
        if ([[[filename pathExtension] lowercaseString] isEqualToString:@"mp4"]||
            [[[filename pathExtension] lowercaseString] isEqualToString:@"mov"]||
            [[[filename pathExtension] lowercaseString] isEqualToString:@"png"]) {
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}

@end



























