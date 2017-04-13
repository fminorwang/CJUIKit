//
//  CJActionBlockProxy.m
//  Pods
//
//  Created by fminor on 23/03/2017.
//
//

#import "CJActionBlockProxy.h"

@interface CJActionBlockProxy ()
{
    NSMutableDictionary     *_eventActionDict;
}

@end

@implementation CJActionBlockProxy

- (void)setBlock:(void (^)(id))block forControlEvents:(UIControlEvents)controlEvents
{
    [self _checkEventActionDict];
    [_eventActionDict setObject:block forKey:@(controlEvents)];
}

- (void)removeBlockForControlEvents:(UIControlEvents)controlEvents
{
    [_eventActionDict removeObjectForKey:@(controlEvents)];
}

- (void)removeBlockForAllControlEvents
{
    [_eventActionDict removeAllObjects];
}

- (void)performBlockForControlEvents:(UIControlEvents)controlEvents withSender:(id)sender
{
    [self _checkEventActionDict];
    void (^_action)(id) = [_eventActionDict objectForKey:@(controlEvents)];
    if ( _action ) {
        _action(sender);
    }
}

- (void)_checkEventActionDict
{
    if ( _eventActionDict == nil ) {
        _eventActionDict = [[NSMutableDictionary alloc] init];
    }
}

@end
