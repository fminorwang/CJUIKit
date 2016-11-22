//
//  CJURLProtocol.h
//  CJUIKit
//
//  Created by fminor on 7/25/16.
//  Copyright © 2016 fminor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJURLProtocol : NSURLProtocol<NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong)   NSURLSession            *session;
@property (nonatomic, strong)   NSURLSessionTask        *task;

@end
