//
//  UIImage+CJUIKit.h
//  Pods
//
//  Created by fminor on 8/23/16.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (CJUIKit)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

- (UIImage *)imageWithSize:(CGSize)size;

@end
