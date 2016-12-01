//
//  NSArray+CJUIKit.h
//  Pods
//
//  Created by fminor on 6/27/16.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (CJUIKit)

- (nullable __kindof NSObject *)firstObjectWhere:(nullable BOOL (^)(__kindof NSObject * _Nonnull obj))condition;    // if condition is nil, then default condition always returns YES

- (void)each:(nullable void (^)(__kindof NSObject * _Nonnull obj))action;
- (void)each:(nullable void (^)(__kindof NSObject * _Nonnull obj))action where:(nullable BOOL (^)(__kindof NSObject * _Nonnull obj))condition;            // if condition is nil, then default condition always returns YES

- (nullable NSArray *)map:(nullable __kindof NSObject * _Nonnull(^)(__kindof NSObject * _Nonnull obj))mapBlock;     // map
- (nullable NSArray *)filter:(nullable BOOL (^)(__kindof NSObject * _Nonnull obj))filterBlock;                      // filter

// reduce method.
- (int)reduceInt:(nullable int (^)(__kindof NSObject * _Nonnull obj, int current))reduceBlock initial:(int)initial;
- (double)reduceDouble:(nullable double (^)(__kindof NSObject * _Nonnull obj, double current))reduceBlock initial:(double)initial;
- (BOOL)reduceBool:(nullable BOOL (^)(__kindof NSObject * _Nonnull obj, BOOL current))reduceBlock initial:(BOOL)initial;
- (nullable __kindof NSObject *)reduceObject:(nullable __kindof NSObject * _Nullable(^)(__kindof NSObject * _Nonnull obj, NSObject * _Nullable current))reduceBlock initial:(nullable NSObject *)initial;

@end
