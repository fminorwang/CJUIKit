//
//  CJActionBlockProxy.h
//  Pods
//
//  Created by fminor on 23/03/2017.
//
//

#import <Foundation/Foundation.h>

@interface CJActionBlockProxy : NSObject

/**
 Set block for UIControlEvents.
 
 @param block action block
 */
- (void)setBlock:(void (^)(id sender))block forControlEvents:(UIControlEvents)controlEvents;

/**
 Remove block for UIControlEvents.
 */
- (void)removeBlockForControlEvents:(UIControlEvents)controlEvents;

/**
 Enumerately remove blocks for all events.
 */
- (void)removeBlockForAllControlEvents;

/**
 Perform block for control events.
 */
- (void)performBlockForControlEvents:(UIControlEvents)controlEvents withSender:(id)sender;

@end
