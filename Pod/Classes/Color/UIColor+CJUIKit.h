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
 
 single color:
    #RRGGBB
    #RRGGBBAA
    #RRGGBB^0.1 ( alpha = 0.1 )
 
 gradient color:
    w(0->100),h(0->100) | #RRGGBB(0.0):#RRGGBB(1.0)             // 起点(0,0) 到终点 (100, 100) 的渐变色
    w(100) | #RRGGBB(0.0):#RRGGBB(1.0)                          // 宽度100的横向渐变色
    w(100) | #RRGGBB(0.0):#RRGGBB(0.5):#RRGGBB(1.0)             // 横向三种颜色的渐变色
    h(100) | #RRGGBB(0.0):#RRGGBB(1.0)                          // 高度100的纵向渐变色
 */
+ (nullable UIColor *)colorWithString:(nonnull NSString *)colorString;

@end
