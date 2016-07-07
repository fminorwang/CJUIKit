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

@implementation NSString (CJFormat)

- (int)intValueWithFormat:(CJFormat)format
{
    switch ( format ) {
        case CJFormatDecimal: {
            return [self _intValueWithMutiplier:10];
            break;
        }
            
        case CJFormatHexadecimal: {
            return [self _intValueWithMutiplier:16];
            break;
        }
            
        case CJFormatOctal: {
            return [self _intValueWithMutiplier:8];
            break;
        }
            
        default:
            break;
    }
    return 0;
}

- (int)intValueWithHexadecimalFormat
{
    return [self intValueWithFormat:CJFormatHexadecimal];
}

- (int)intValueWithDecimalFormat
{
    return [self intValueWithFormat:CJFormatDecimal];
}

- (int)intValueWithOctalFormat
{
    return [self intValueWithFormat:CJFormatOctal];
}

+ (int)_intValueFromChar:(char)ch
{
    if ( ch >= '0' && ch <= '9' ) {
        return ch - '0';
    }
    
    if ( ch >= 'A' && ch <= 'F' ) {
        return ch - 'A' + 10;
    }
    
    if ( ch >= 'a' && ch <= 'f' ) {
        return ch - 'a' + 10;
    }
    
    return -1;
}

- (int)_intValueWithMutiplier:(int)multiplier
{
    int _result = 0;
    for ( int i = 0 ; i < [self length] ; i++ ) {
        char _ch = [self characterAtIndex:i];
        int _num = [NSString _intValueFromChar:_ch];
        if ( _num < 0 ) {
            // illegal
            return -1;
        }
        _result = _result * multiplier + _num;
    }
    return _result;
}

@end
