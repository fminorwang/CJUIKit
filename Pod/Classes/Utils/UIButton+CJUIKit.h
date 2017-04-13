//
//  UIButton+CJUIKit.h
//  Pods
//
//  Created by fminor on 23/03/2017.
//
//

#import <UIKit/UIKit.h>

@interface UIButton (CJUIKit)

- (void)addActionBlock:(void (^)(id sender))actionBlock forControlEvents:(UIControlEvents)controlEvents;
- (void)removeActionBlockForControlEvents:(UIControlEvents)controlEvents;

@end
