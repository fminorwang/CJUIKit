//
//  NSString+CJUIKit.m
//  Pods
//
//  Created by fminor on 6/20/16.
//
//

#import "NSString+CJUIKit.h"

@implementation NSString (CJUIKit)

- (NSDictionary *)urlQueryParamDict
{
    NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
    NSArray *_components = [self componentsSeparatedByString:@"&"];
    for ( NSString *_component in _components ) {
        NSArray *_keyAndValue = [_component componentsSeparatedByString:@"="];
        if ( [_keyAndValue count] != 2 ) continue;
        [_params setObject:_keyAndValue[1] forKey:_keyAndValue[0]];
    }
    return _params;
}

+ (NSDictionary *)urlQueryParamDictFromString:(NSString *)aString
{
    NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
    NSArray *_components = [aString componentsSeparatedByString:@"&"];
    for ( NSString *_component in _components ) {
        NSArray *_keyAndValue = [_component componentsSeparatedByString:@"="];
        if ( [_keyAndValue count] != 2 ) continue;
        [_params setObject:_keyAndValue[1] forKey:_keyAndValue[0]];
    }
    return _params;
}

@end
