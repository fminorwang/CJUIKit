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
    if ( ![colorString hasPrefix:@"#"] ) {
        return nil;
    }
    
    NSString *_capitalizedString = [[colorString uppercaseString] substringFromIndex:1];
    NSArray *_colorStringAndAlpha = [_capitalizedString componentsSeparatedByString:@"^"];
    NSString *_colorString = [_colorStringAndAlpha objectAtIndex:0];
    NSString *_alphaString = nil;
    if ( [_colorStringAndAlpha count] > 1 ) {
        _alphaString = [_colorStringAndAlpha objectAtIndex:1];
    }
    
    NSString *_rs = [_colorString substringWithRange:(NSRange){0, 2}];
    int _red = [_rs intValueWithHexadecimalFormat];
    
    NSString *_gs = [_colorString substringWithRange:(NSRange){2, 2}];
    int _green = [_gs intValueWithHexadecimalFormat];
    
    NSString *_bs = [_colorString substringWithRange:(NSRange){4, 2}];
    int _blue = [_bs intValueWithHexadecimalFormat];
    
    CGFloat _alpha = 1.f;
    if ( _alphaString != nil ) {
        _alpha = [_alphaString floatValue];
    } else if ( [_colorString length] > 6 ) {
        NSString *_alphas = [_colorString substringWithRange:(NSRange){6, 2}];
        _alpha = (CGFloat)[_alphas intValueWithHexadecimalFormat] / 0xFF;
    }
    
    UIColor *_color = [UIColor colorWithRed:(CGFloat)_red / 0xFF green:(CGFloat)_green / 0xFF blue:(CGFloat)_blue / 0xFF
                                      alpha:_alpha];
    return _color;
}

@end
