//
//  UIColor+TingShuo.h
//  ZFTingShuo
//
//  Created by fminor on 6/15/15.
//  Copyright (c) 2015 fminor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CJUIKit)

/*
 color string format:
    #RRGGBB
    #RRGGBBAA
 */
+ (nullable UIColor *)colorWithString:(nonnull NSString *)colorString;

@end