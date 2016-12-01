//
//  NSArray+CJUIKit.m
//  Pods
//
//  Created by fminor on 6/27/16.
//
//

#import "NSArray+CJUIKit.h"

@implementation NSArray (CJUIKit)

- (NSObject *)firstObjectWhere:(BOOL (^)(__kindof NSObject *))condition
{
    if ( [self count] == 0 ) return nil;
    if ( condition == nil ) {
        return [self firstObject];
    }
    for ( NSObject *_obj in self ) {
        if ( condition(_obj) ) {
            return _obj;
        }
    }
    return nil;
}

- (void)each:(void (^)(__kindof NSObject *))action
{
    if ( [self count] == 0 ) {
        return;
    }
    
    if ( action == nil ) {
        return;
    }
    
    for ( NSObject *_obj in self ) {
        action(_obj);
    }
}

- (void)each:(void (^)(__kindof NSObject *))action where:(BOOL (^)(__kindof NSObject *))condition
{
    if ( [self count] == 0 ) {
        return;
    }
    
    for ( NSObject *_obj in self ) {
        if ( condition != nil ) {
            if ( condition(_obj) == NO ) {
                continue;
            }
        }
        action(_obj);
    }
}

- (NSArray *)map:(__kindof NSObject *(^)(__kindof NSObject *))mapBlock
{
    if ( mapBlock == nil ) return nil;
    NSMutableArray *_result = [[NSMutableArray alloc] init];
    for ( NSObject *_obj in self ) {
        NSObject *_mapObj = mapBlock(_obj);
        [_result addObject:_mapObj];
    }
    return _result;
}

- (NSArray *)filter:(BOOL (^)(__kindof NSObject *))filterBlock
{
    if ( filterBlock == nil ) return [self copy];
    NSMutableArray *_result = [[NSMutableArray alloc] init];
    for ( NSObject *_obj in self ) {
        if ( filterBlock(_obj) == YES ) {
            [_result addObject:_obj];
        }
    }
    return _result;
}

#define REDUCE_IMPL(type, typeName)                                                                 \
- (type)reduce##typeName:(type (^)(__kindof NSObject *, type))reduceBlock initial:(type)initial     \
{                                                                                                   \
    if ( reduceBlock == nil ) {                                                                     \
        return initial;                                                                             \
    }                                                                                               \
    type _result = initial;                                                                         \
    for ( NSObject *_obj in self ) {                                                                \
        _result = reduceBlock(_obj, _result);                                                       \
    }                                                                                               \
    return _result;                                                                                 \
}

REDUCE_IMPL(int, Int)
REDUCE_IMPL(double, Double)
REDUCE_IMPL(BOOL, Bool)
- (NSObject *)reduceObject:(__kindof NSObject * _Nullable (^)(__kindof NSObject * _Nonnull, NSObject * _Nullable))reduceBlock initial:(NSObject *)initial
{
    if ( reduceBlock == nil ) return initial;
    NSObject *_result = initial;
    for ( NSObject *_obj in self ) _result = reduceBlock(_obj, _result);
    return _result;
}

@end
