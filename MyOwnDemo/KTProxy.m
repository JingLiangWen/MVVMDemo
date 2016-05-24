//
//  KTProxy.m
//  BaoTong
//
//  Created by  on 14-3-5.
//  Copyright (c) 2014年 LinChengyu. All rights reserved.
//

#import "KTProxy.h"
#import "UIDevice+Resolutions.h"

@implementation KTProxy

+ (KTProxy *)loadWithMethod:(NSString *)method andParams:(NSDictionary *)params
                   completed:(RequestCompletedHandleBlock)completeHandleBlock
                      failed:(RequestFailedHandleBlock)failedHandleBlock
{
    KTProxy *proxy = [[KTProxy alloc] init];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (params) {
        dict = [[NSMutableDictionary alloc] initWithDictionary:params];
    }
    if (TOKEN) {
        [dict setObject:TOKEN forKey:@"token"];
    }
    if (USER_ID) {
        [dict setObject:USER_ID forKey:@"userId"];
    }
    
    //基本参数
    [dict setObject:[[DeviceModel shareModel] device] forKey:@"device"];
    
    proxy.oper = [manager POST:[NSString stringWithFormat:@"%@%@",SERVER_HOST,method] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completeHandleBlock) {
            completeHandleBlock([operation responseString], [operation responseStringEncoding]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"==================================================");
        NSLog(@"加载数据失败，Error: %@", [error localizedDescription]);
        NSLog(@"Class:::%@", NSStringFromClass([self class]));
        NSLog(@"==================================================");
        
        if (failedHandleBlock) {
            failedHandleBlock(error);
        }
    }];
    
    return proxy;
}

- (void)start
{
    if (_oper && _oper.isReady) {
        [_oper start];
    }
}

- (void)stop{
    [_oper cancel];
}

- (BOOL)isLoading
{
    _loading = [_oper isExecuting];
    return _loading;
}

- (BOOL)isLoaded
{
    _loaded = [_oper isFinished];
    return _loaded;
}

@end
