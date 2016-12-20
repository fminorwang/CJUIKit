//
//  CJRunTime.h
//  Pods
//
//  Created by fminor on 7/26/16.
//
//

#import <Foundation/Foundation.h>

@interface CJRunTime : NSObject

+ (NSArray *)listMethodNameForClass:(Class)cls;
+ (NSArray *)listClassMethodNameForClass:(Class)cls;
+ (NSArray *)listMemberNameForClass:(Class)cls;
+ (NSArray *)listInstanceIvars:(NSObject *)instance;

+ (void)exchangeWithInstance:(id)aInstance selector:(SEL)aSel andInstance:(id)bInstance selector:(SEL)bSel;
+ (void)exchangeWithClass:(Class)aClass selector:(SEL)aSel andClass:(Class)bClass selector:(SEL)bSel;

@end
