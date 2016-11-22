//
//  CJURLProtocol.m
//  CJUIKit
//
//  Created by fminor on 7/25/16.
//  Copyright © 2016 fminor. All rights reserved.
//

#import "CJURLProtocol.h"

@implementation CJURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSLog(@"Can init request: %@", request.URL.absoluteString);
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    NSMutableDictionary *_proxyDict = [[NSMutableDictionary alloc] init];
//    [_proxyDict setObject:@1 forKey:@"HTTPEnable"];
//    [_proxyDict setObject:@"45.63.127.24" forKey:(NSString *)kCFStreamPropertyHTTPProxyHost];
//    [_proxyDict setObject:@47 forKey:(NSString *)kCFStreamPropertyHTTPProxyPort];
//    
//    [_proxyDict setObject:@1 forKey:@"HTTPSEnable"];
//    [_proxyDict setObject:@"45.63.127.24" forKey:(NSString *)kCFStreamPropertyHTTPSProxyHost];
//    [_proxyDict setObject:@47 forKey:(NSString *)kCFStreamPropertyHTTPSProxyPort];
    
    [_proxyDict setObject:@1 forKey:@"HTTPEnable"];
    [_proxyDict setObject:@"192.168.30.149" forKey:(NSString *)kCFStreamPropertyHTTPProxyHost];
    [_proxyDict setObject:@8888 forKey:(NSString *)kCFStreamPropertyHTTPProxyPort];
    
    [_proxyDict setObject:@1 forKey:@"HTTPSEnable"];
    [_proxyDict setObject:@"192.168.30.149" forKey:(NSString *)kCFStreamPropertyHTTPSProxyHost];
    [_proxyDict setObject:@8888 forKey:(NSString *)kCFStreamPropertyHTTPSProxyPort];
    
    NSURLSessionConfiguration *_conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    _conf.connectionProxyDictionary = _proxyDict;
    
    _session = [NSURLSession sessionWithConfiguration:_conf delegate:self delegateQueue:nil];
//    _task = [_session dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"666");
//    }];
    _task = [_session dataTaskWithRequest:self.request];
    [_task resume];
}

- (void)stopLoading
{

}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    //1. 判断服务器返回的证书是否是服务器信任的
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        //2. 根据服务器返回的受保护空间中的信任，创建一个挑战凭证
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        //3. 完成挑战
        completionHandler(NSURLSessionAuthChallengeUseCredential , credential);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

@end
