//
//  UIColor+CJUIKit.m
//
//  Created by fminor on 6/15/15.
//  Copyright (c) 2015 fminor. All rights reserved.
//

#import "UIColor+CJUIKit.h"
#import "NSString+CJUIKit.h"

@implementation UIColor (TingShuo)

+ (UIColor *)colorWithString:(NSString *)colorString
{
    int _length = [colorString length];
    if ( ![colorString hasPrefix:@"#"] ) {
        return nil;
    }
    
    NSString *_capitalizedString = [[colorString uppercaseString] substringFromIndex:1];
    
    NSString *_rs = [_capitalizedString substringWithRange:(NSRange){0, 2}];
    int _red = [_rs intValueWithHexadecimalFormat];
    
    NSString *_gs = [_capitalizedString substringWithRange:(NSRange){2, 2}];
    int _green = [_rs intValueWithHexadecimalFormat];
    
    NSString *_bs = [_capitalizedString substringWithRange:(NSRange){4, 2}];
    int _blue = [_rs intValueWithHexadecimalFormat];
    
    int _alpha = 0xFF;
    if ( [_capitalizedString length] > 6 ) {
        NSString *_alphas = [_capitalizedString substringWithRange:(NSRange){6, 2}];
        _alpha = [_alphas intValueWithHexadecimalFormat];
    }
    
    UIColor *_color = [UIColor colorWithRed:(CGFloat)_red / 0xFF green:(CGFloat)_green / 0xFF blue:(CGFloat)_blue / 0xFF
                                      alpha:(CGFloat)_alpha / 0xFF];
    return _color;
}

+ (int)_characterToInt:(char)ch
{
    if ( ch >= '0' && ch <= '9' ) {
        return ch - '0';
    }
    
    if ( ch >= 'A' && ch <= 'F' ) {
        return ch - 'A' + 10;
    }
    
    return 0;
}

// 16进制二位数转换10进制
+ (int)_stringToInt:(NSString *)aString
{
    if ( [aString length] != 2 ) return 0;
    
    NSString *_capitalizedString = [aString uppercaseString];
    char _ch1 = [_capitalizedString characterAtIndex:0];
    char _ch2 = [_capitalizedString characterAtIndex:1];
    int _decimalNumber = _ch1 * 16 + _ch2;
    return _decimalNumber;
}

@end
