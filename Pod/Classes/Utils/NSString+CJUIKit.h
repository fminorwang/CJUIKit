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

@interface NSString (Codec)

- (NSString *)MD5String;

@end

// 标记语言 CJML
// 没有嵌套关系的简单 HTML
@interface NSString (CJMarkedLanguage)

+ (void)registerAttributes:(NSDictionary *)attributes forAttributeName:(NSString *)attributeName;

- (NSAttributedString *)markedAttributedStringWithNormalAttributes:(NSDictionary *)attributes;
- (NSAttributedString *)markedAttributedStringWithNormalAttributes:(NSDictionary *)attributes baseFont:(UIFont *)baseFont;

@end
