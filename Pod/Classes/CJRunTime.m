//
//  CJRunTime.m
//  Pods
//
//  Created by fminor on 7/26/16.
//
//

#import "CJRunTime.h"
#import <objc/runtime.h>

@implementation CJRunTime

+ (NSArray *)listMethodNameForClass:(Class)cls
{
    unsigned int _methodCount = 0;
    Method *_methodPtr = class_copyMethodList(cls, &_methodCount);
    
    NSMutableString *_output = [[NSMutableString alloc] init];
    for ( int i = 0 ; i < _methodCount ; i++ ) {
        Method _method = _methodPtr[i];
        
        SEL _methodName = method_getName(_method);
        NSString *_methodNameStr = NSStringFromSelector(_methodName);
        NSRange _range = [_methodNameStr rangeOfString:@":"];
        if ( _range.location != NSNotFound ) {
            _methodNameStr = [_methodNameStr substringToIndex:_range.location];
        }
        
        unsigned int _argNum = method_getNumberOfArguments(_method);
        NSMutableString *_argDesc = [[NSMutableString alloc] init];
        for ( int j = 2 ; j < _argNum ; j++ ) {
            char _arg[100];
            size_t _argLen = 100;
            method_getArgumentType(_method, j, _arg, _argLen);
            NSString *_argStr = [[NSString alloc] initWithCString:_arg encoding:NSUTF8StringEncoding];
            [_argDesc appendFormat:@":(%@) ", _argStr];
        }
        
        char _returnType[100];
        size_t _returnTypeSize = 100;
        method_getReturnType(_method, _returnType, _returnTypeSize);
        NSString *_returnTypeStr = [[NSString alloc] initWithCString:_returnType encoding:NSUTF8StringEncoding];
        
        [_output appendFormat:@"\n- (%@)%@%@", _returnTypeStr, _methodNameStr, _argDesc];
    }
    NSLog(@"%@", _output);
    return nil;
}

+ (NSArray *)listClassMethodNameForClass:(Class)cls
{
    unsigned int _methodCount = 0;
    Method *_methodPtr = class_copyMethodList(object_getClass(cls), &_methodCount);
    
    NSMutableString *_output = [[NSMutableString alloc] init];
    for ( int i = 0 ; i < _methodCount ; i++ ) {
        Method _method = _methodPtr[i];
        
        SEL _methodName = method_getName(_method);
        NSString *_methodNameStr = NSStringFromSelector(_methodName);
        NSRange _range = [_methodNameStr rangeOfString:@":"];
        if ( _range.location != NSNotFound ) {
            _methodNameStr = [_methodNameStr substringToIndex:_range.location];
        }
        
        unsigned int _argNum = method_getNumberOfArguments(_method);
        NSMutableString *_argDesc = [[NSMutableString alloc] init];
        for ( int j = 2 ; j < _argNum ; j++ ) {
            char _arg[100];
            size_t _argLen = 100;
            method_getArgumentType(_method, j, _arg, _argLen);
            NSString *_argStr = [[NSString alloc] initWithCString:_arg encoding:NSUTF8StringEncoding];
            [_argDesc appendFormat:@":(%@) ", _argStr];
        }
        
        char _returnType[100];
        size_t _returnTypeSize = 100;
        method_getReturnType(_method, _returnType, _returnTypeSize);
        NSString *_returnTypeStr = [[NSString alloc] initWithCString:_returnType encoding:NSUTF8StringEncoding];
        
        [_output appendFormat:@"\n+ (%@)%@%@", _returnTypeStr, _methodNameStr, _argDesc];
    }
    NSLog(@"%@", _output);
    return nil;
}

+ (NSArray *)listMemberNameForClass:(Class)cls
{
    NSMutableString *_log = [[NSMutableString alloc] init];
    unsigned int _count;
    Ivar *_ivarPtr = class_copyIvarList(cls, &_count);
    for ( int i = 0 ; i < _count ; i++ ) {
        Ivar _ivar = _ivarPtr[i];
        const char *_name = ivar_getName(_ivar);
        const char *_type = ivar_getTypeEncoding(_ivar);
        NSString *_format = @"\n%@ : %@";
        [_log appendFormat:
         _format,
         [NSString stringWithCString:_name encoding:NSUTF8StringEncoding],
         [NSString stringWithCString:_type encoding:NSUTF8StringEncoding]];
    }
    NSLog((NSString *)_log);
    return nil;
}

+ (NSArray *)listInstanceIvars:(NSObject *)instance
{
    NSMutableString *_log = [[NSMutableString alloc] init];
    Class _class = [instance class];
    unsigned int _ivarCount = 0;
    Ivar *_ivarPtr = class_copyIvarList(_class, &_ivarCount);
    for ( int i = 0 ; i < _ivarCount ; i++ ) {
        Ivar _ivar = _ivarPtr[i];
        const char *_name = ivar_getName(_ivar);
        const char *_type = ivar_getTypeEncoding(_ivar);
        id _value = object_getIvar(instance, _ivar);
        [_log appendFormat:@"\n%@ : %@ = %p",
         [NSString stringWithCString:_name encoding:NSUTF8StringEncoding],
         [NSString stringWithCString:_type encoding:NSUTF8StringEncoding],
         _value];
    }
    NSLog((NSString *)_log);
    return nil;
}

@end
