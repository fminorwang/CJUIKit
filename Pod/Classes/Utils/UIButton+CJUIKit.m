//
//  UIButton+CJUIKit.m
//  Pods
//
//  Created by fminor on 23/03/2017.
//
//

#import "UIButton+CJUIKit.h"
#import "CJActionBlockProxy.h"
#import <objc/runtime.h>

#define kCJActionBlockProxy             "kCJActionBlockProxy"
#define CJ_CALLBACK_SEL_PREFIX          @"_cj_action_receive_"

@implementation UIButton (CJUIKit)

- (void)addActionBlock:(void (^)(id))actionBlock forControlEvents:(UIControlEvents)controlEvents
{
    CJActionBlockProxy *_proxy = [self cj_actionBlockProxy];
    [_proxy setBlock:actionBlock forControlEvents:controlEvents];
    [self cj_setActionBlockProxy:_proxy];
    NSString *_selectorName = [NSString stringWithFormat:@"%@%d", CJ_CALLBACK_SEL_PREFIX, controlEvents];
    SEL _sel = NSSelectorFromString(_selectorName);
    [self addTarget:self action:_sel forControlEvents:controlEvents];
}

- (void)removeActionBlockForControlEvents:(UIControlEvents)controlEvents
{
    CJActionBlockProxy *_proxy = [self cj_actionBlockProxy];
    [_proxy removeBlockForControlEvents:controlEvents];
    [self cj_setActionBlockProxy:_proxy];
}

- (void)_actionReceiveControlEvents:(UIControlEvents)controlEvents
{
    CJActionBlockProxy *_proxy = [self cj_actionBlockProxy];
    [_proxy performBlockForControlEvents:controlEvents withSender:self];
}

- (CJActionBlockProxy *)cj_actionBlockProxy
{
    CJActionBlockProxy *_proxy = objc_getAssociatedObject(self, kCJActionBlockProxy);
    if ( _proxy == nil ) {
        _proxy = [[CJActionBlockProxy alloc] init];
    }
    return _proxy;
}

- (void)cj_setActionBlockProxy:(CJActionBlockProxy *)proxy
{
    if ( proxy == nil ) {
        return;
    }
    objc_setAssociatedObject(self, kCJActionBlockProxy, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *_sig = [super methodSignatureForSelector:aSelector];
    if ( _sig != nil ) {
        return _sig;
    }
    NSString *_selStr = NSStringFromSelector(aSelector);
    if ( [_selStr hasPrefix:CJ_CALLBACK_SEL_PREFIX] ) {
        return [super methodSignatureForSelector:@selector(_actionReceiveControlEvents:)];
    }
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL _sel = [anInvocation selector];
    NSString *_selectorStr = NSStringFromSelector(_sel);
    if ( ![_selectorStr hasPrefix:CJ_CALLBACK_SEL_PREFIX] ) {
        [anInvocation invoke];
        return;
    }
    NSString *_event = [_selectorStr substringFromIndex:CJ_CALLBACK_SEL_PREFIX.length];
    UIControlEvents _events = [_event integerValue];
    [self _actionReceiveControlEvents:_events];
}

@end
