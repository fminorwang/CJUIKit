//
//  UIColor+CJUIKit.m
//
//  Created by fminor on 6/15/15.
//  Copyright (c) 2015 fminor. All rights reserved.
//

#import "UIColor+CJUIKit.h"

@implementation UIColor (TingShuo)

+ (UIColor *)colorWithString:(NSString *)colorString
{
    if ( [colorString length] != 7 ) {
        return nil;
    }
    
    if ( ![colorString hasPrefix:@"#"] ) {
        return nil;
    }
    
    NSString *_capitalizedString = [[colorString uppercaseString] substringFromIndex:1];
    
    char _ch1 = [_capitalizedString characterAtIndex:0];
    char _ch2 = [_capitalizedString characterAtIndex:1];
    int _red = [UIColor _characterToInt:_ch1] * 16 + [UIColor _characterToInt:_ch2];
    
    char _ch3 = [_capitalizedString characterAtIndex:2];
    char _ch4 = [_capitalizedString characterAtIndex:3];
    int _green = [UIColor _characterToInt:_ch3] * 16 + [UIColor _characterToInt:_ch4];

    char _ch5 = [_capitalizedString characterAtIndex:4];
    char _ch6 = [_capitalizedString characterAtIndex:5];
    int _blue = [UIColor _characterToInt:_ch5] * 16 + [UIColor _characterToInt:_ch6];
    
    UIColor *_color = [UIColor colorWithRed:(CGFloat)_red / 0xFF green:(CGFloat)_green / 0xFF blue:(CGFloat)_blue / 0xFF alpha:1.0];
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

@end
