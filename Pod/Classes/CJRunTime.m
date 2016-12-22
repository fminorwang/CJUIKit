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
    NSMutableArray *_results = [[NSMutableArray alloc] init];
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
        
        NSString *_result = [NSString stringWithFormat:@"- (%@)%@%@", _returnTypeStr, _methodNameStr, _argDesc];
        [_output appendFormat:@"\n%@", _result];
        [_results addObject:_result];
    }
    NSLog(@"%@", _output);
    return _results;
}

+ (NSArray *)listClassMethodNameForClass:(Class)cls
{
    unsigned int _methodCount = 0;
    Method *_methodPtr = class_copyMethodList(object_getClass(cls), &_methodCount);
    
    NSMutableString *_output = [[NSMutableString alloc] init];
    NSMutableArray *_results = [[NSMutableArray alloc] init];
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
        
        NSString *_result = [NSString stringWithFormat:@"+ (%@)%@%@", _returnTypeStr, _methodNameStr, _argDesc];
        [_output appendFormat:@"\n+ (%@)%@%@", _returnTypeStr, _methodNameStr, _argDesc];
        [_results addObject:_result];
    }
    NSLog(@"%@", _output);
    return _results;
}

+ (NSArray *)listMemberNameForClass:(Class)cls
{
    NSMutableString *_log = [[NSMutableString alloc] init];
    NSMutableArray *_results = [[NSMutableArray alloc] init];
    unsigned int _count;
    Ivar *_ivarPtr = class_copyIvarList(cls, &_count);
    for ( int i = 0 ; i < _count ; i++ ) {
        Ivar _ivar = _ivarPtr[i];
        const char *_name = ivar_getName(_ivar);
        const char *_type = ivar_getTypeEncoding(_ivar);
        NSString *_format = @"\n%@";
        NSString *_result = [NSString stringWithFormat:@"%@ : %@",
                             [NSString stringWithCString:_name encoding:NSUTF8StringEncoding],
                             [NSString stringWithCString:_type encoding:NSUTF8StringEncoding]];
        [_log appendFormat:_format, _result];
        [_results addObject:_result];
    }
    NSLog(@"%@", _log);
    return _results;
}

+ (NSArray *)listInstanceIvars:(NSObject *)instance
{
    NSMutableString *_log = [[NSMutableString alloc] init];
    NSMutableArray *_results = [[NSMutableArray alloc] init];
    Class _class = [instance class];
    unsigned int _ivarCount = 0;
    Ivar *_ivarPtr = class_copyIvarList(_class, &_ivarCount);
    for ( int i = 0 ; i < _ivarCount ; i++ ) {
        Ivar _ivar = _ivarPtr[i];
        const char *_name = ivar_getName(_ivar);
        const char *_type = ivar_getTypeEncoding(_ivar);
        id _value = object_getIvar(instance, _ivar);
        NSString *_result = [NSString stringWithFormat:@"%@ : %@ = %p",
                             [NSString stringWithCString:_name encoding:NSUTF8StringEncoding],
                             [NSString stringWithCString:_type encoding:NSUTF8StringEncoding],
                             _value];
        [_log appendFormat:@"\n%@", _result];
    }
    NSLog(@"%@", _log);
    return _results;
}

+ (void)exchangeWithClass:(Class)aClass selector:(SEL)aSel andClass:(Class)bClass selector:(SEL)bSel
{
    Method _methodA = class_getInstanceMethod(aClass, aSel);
    Method _methodB = class_getInstanceMethod(bClass, bSel);
    
    //交换实现
    method_exchangeImplementations(_methodA, _methodB);
}

+ (void)exchangeWithInstance:(NSObject *)aInstance selector:(SEL)aSel andInstance:(NSObject *)bInstance selector:(SEL)bSel
{
    Method _methodA = class_getInstanceMethod([aInstance class], aSel);
    Method _methodB = class_getInstanceMethod([bInstance class], bSel);
    if ( _methodB == NULL ) {
        Class _class = bInstance;
        _methodB = class_getClassMethod(_class, bSel);
    }
    method_exchangeImplementations(_methodA, _methodB);
}

@end
