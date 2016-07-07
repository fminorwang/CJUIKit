//
//  NSString+CJUIKit.h
//  Pods
//
//  Created by fminor on 6/20/16.
//
//

#import <Foundation/Foundation.h>

@interface NSString (CJUIKit)

/*
 change url query to dictionary
 */
- (NSDictionary *)urlQueryParamDict;
+ (NSDictionary *)urlQueryParamDictFromString:(NSString *)aString;

@end

typedef NS_ENUM(NSInteger, CJFormat) {
    CJFormatDecimal         = 0,
    CJFormatHexadecimal,
    CJFormatOctal
};

@interface NSString (CJFormat)

- (int)intValueWithFormat:(CJFormat)format;
- (int)intValueWithHexadecimalFormat;
- (int)intValueWithDecimalFormat;
- (int)intValueWithOctalFormat;

@end
