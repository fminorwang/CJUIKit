//
//  NSString+CJUIKit.h
//  Pods
//
//  Created by fminor on 6/20/16.
//
//

#import <Foundation/Foundation.h>

@interface NSString (CJUIKit)

- (NSDictionary *)urlQueryParamDict;

+ (NSDictionary *)urlQueryParamDictFromString:(NSString *)aString;

@end
