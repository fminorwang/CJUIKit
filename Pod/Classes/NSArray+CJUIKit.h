//
//  NSArray+CJUIKit.h
//  Pods
//
//  Created by fminor on 6/27/16.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (CJUIKit)

- (nullable __kindof NSObject *)firstObjectWhere:(nullable BOOL (^)(__kindof NSObject * obj))condition;           // if condition is nil, then default condition always returns YES

- (void)each:(void (^)(__kindof NSObject *obj))action;
- (void)each:(void (^)(__kindof NSObject *obj))action where:(BOOL (^)(__kindof NSObject *obj))condition;            // if condition is nil, then default condition always returns YES

- (NSArray *)map:(__kindof NSObject *(^)(__kindof NSObject *obj))mapBlock;              // map
- (NSArray *)filter:(BOOL (^)(__kindof NSObject *obj))filterBlock;                      // filter

// reduce method.
- (int)reduceInt:(int (^)(__kindof NSObject *obj, int current))reduceBlock initial:(int)initial;
- (double)reduceDouble:(double (^)(__kindof NSObject *obj, double current))reduceBlock initial:(double)initial;
- (BOOL)reduceBool:(BOOL (^)(__kindof NSObject *obj, BOOL current))reduceBlock initial:(BOOL)initial;
- (__kindof NSObject *)reduceObject:(__kindof NSObject *(^)(__kindof NSObject *obj, NSObject *current))reduceBlock
                            initial:(NSObject *)initial;

@end
