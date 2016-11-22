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

@end
