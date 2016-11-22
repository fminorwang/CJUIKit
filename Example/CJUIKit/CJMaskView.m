//
//  CJMaskView.m
//  CJUIKit
//
//  Created by fminor on 7/26/16.
//  Copyright © 2016 fminor. All rights reserved.
//

#import "CJMaskView.h"
#import <CJRunTime.h>
#import <objc/runtime.h>

@implementation CJMaskView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [CJRunTime listInstanceIvars:event];
    [CJRunTime listMethodNameForClass:[event class]];
    
    SEL _cloneSelector = NSSelectorFromString(@"_cloneEvent");
    NSMethodSignature *_signature = [[event class] instanceMethodSignatureForSelector:_cloneSelector];
    NSInvocation *_invocation = [NSInvocation invocationWithMethodSignature:_signature];
    _invocation.target = event;
    _invocation.selector = _cloneSelector;
    [_invocation invoke];
    UIEvent *_copyEvent = nil;
    [_invocation getReturnValue:&_copyEvent];
    
    UITouch *_touch = [touches anyObject];
    SEL _cloneTouchSelector = NSSelectorFromString(@"_clone");
    NSMethodSignature *_cloneTouchSignature = [[_touch class] instanceMethodSignatureForSelector:_cloneTouchSelector];
    NSInvocation *_cloneTouchInvocation = [NSInvocation invocationWithMethodSignature:_cloneTouchSignature];
    _cloneTouchInvocation.target = _touch;
    _cloneTouchInvocation.selector = _cloneTouchSelector;
    [_cloneTouchInvocation invoke];
    UITouch *_clonedTouch;
    [_cloneTouchInvocation getReturnValue:&_clonedTouch];
    
    [CJRunTime listClassMethodNameForClass:[_touch class]];
    [CJRunTime listClassMethodNameForClass:[UIEvent class]];
    
    Ivar _touchesIvar = class_getInstanceVariable([event class], "_touches");
    NSSet *_copiedTouches = [NSSet setWithObjects:_clonedTouch, nil];
    object_setIvar(_copyEvent, _touchesIvar, _copiedTouches);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

@end
