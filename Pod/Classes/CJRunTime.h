//
//  CJRunTime.h
//  Pods
//
//  Created by fminor on 7/26/16.
//
//

#import <Foundation/Foundation.h>

void exchangeClassMethod(Class aCls, SEL aSel, Class bCls, SEL bSel);

void exchangeInstanceMethod(Class aCls, SEL aSel, Class bCls, SEL bSel);
void exchangeInstanceMethodObj(NSObject *aObj, SEL aSel, NSObject *bObj, SEL bSel);

@interface CJRunTime : NSObject

+ (NSArray *)listMethodNameForClass:(Class)cls;
+ (NSArray *)listClassMethodNameForClass:(Class)cls;
+ (NSArray *)listMemberNameForClass:(Class)cls;
+ (NSArray *)listInstanceIvars:(NSObject *)instance;

+ (void)printMethodsForClass:(Class)cls;

+ (void)exchangeWithInstance:(id)aInstance selector:(SEL)aSel andInstance:(id)bInstance selector:(SEL)bSel;
+ (void)exchangeWithClass:(Class)aClass selector:(SEL)aSel andClass:(Class)bClass selector:(SEL)bSel;

@end
