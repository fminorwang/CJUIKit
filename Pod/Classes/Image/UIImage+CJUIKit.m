//
//  UIImage+CJUIKit.m
//  Pods
//
//  Created by fminor on 8/23/16.
//
//

#import "UIImage+CJUIKit.h"

@implementation UIImage (CJUIKit)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [UIImage imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect _rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(_rect.size);
    CGContextRef _context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(_context, [color CGColor]);
    CGContextFillRect(_context, _rect);
    
    UIImage *_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return _image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius
{
    CGRect _rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(_rect.size);
    CGContextRef _context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(_context, [color CGColor]);
    CGContextFillRect(_context, _rect);
    
    UIImage *_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return _image;
}

- (UIImage *)imageWithSize:(CGSize)size
{
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (width <= size.width && height <= size.height){
        return self;
    }
    
    if (width == 0 || height == 0){
        return self;
    }
    
    CGFloat widthFactor = size.width / width;
    CGFloat heightFactor = size.height / height;
    CGFloat scaleFactor = MIN(widthFactor, heightFactor);
    CGFloat scaledWidth = width * scaleFactor;
    CGFloat scaledHeight = height * scaleFactor;
    CGSize targetSize = CGSizeMake(scaledWidth,scaledHeight);
    UIGraphicsBeginImageContext(targetSize);
    [self drawInRect:CGRectMake(0,0,scaledWidth,scaledHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)_scaleFromImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // to do
    return nil;
}


@end
