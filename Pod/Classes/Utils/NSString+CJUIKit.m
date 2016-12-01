//
//  NSString+CJUIKit.m
//  Pods
//
//  Created by fminor on 6/20/16.
//
//

#import "NSString+CJUIKit.h"
#import "UIColor+CJUIKit.h"

@implementation NSString (CJUIKit)

- (NSDictionary *)urlQueryParamDict
{
    NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
    NSArray *_components = [self componentsSeparatedByString:@"&"];
    for ( NSString *_component in _components ) {
        NSArray *_keyAndValue = [_component componentsSeparatedByString:@"="];
        if ( [_keyAndValue count] != 2 ) continue;
        [_params setObject:_keyAndValue[1] forKey:_keyAndValue[0]];
    }
    return _params;
}

+ (NSDictionary *)urlQueryParamDictFromString:(NSString *)aString
{
    NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
    NSArray *_components = [aString componentsSeparatedByString:@"&"];
    for ( NSString *_component in _components ) {
        NSArray *_keyAndValue = [_component componentsSeparatedByString:@"="];
        if ( [_keyAndValue count] != 2 ) continue;
        [_params setObject:_keyAndValue[1] forKey:_keyAndValue[0]];
    }
    return _params;
}

@end

@implementation NSString (CJFormat)

- (int)intValueWithFormat:(CJFormat)format
{
    switch ( format ) {
        case CJFormatDecimal: {
            return [self _intValueWithMutiplier:10];
            break;
        }
            
        case CJFormatHexadecimal: {
            return [self _intValueWithMutiplier:16];
            break;
        }
            
        case CJFormatOctal: {
            return [self _intValueWithMutiplier:8];
            break;
        }
            
        default:
            break;
    }
    return 0;
}

- (int)intValueWithHexadecimalFormat
{
    return [self intValueWithFormat:CJFormatHexadecimal];
}

- (int)intValueWithDecimalFormat
{
    return [self intValueWithFormat:CJFormatDecimal];
}

- (int)intValueWithOctalFormat
{
    return [self intValueWithFormat:CJFormatOctal];
}

+ (int)_intValueFromChar:(char)ch
{
    if ( ch >= '0' && ch <= '9' ) {
        return ch - '0';
    }
    
    if ( ch >= 'A' && ch <= 'F' ) {
        return ch - 'A' + 10;
    }
    
    if ( ch >= 'a' && ch <= 'f' ) {
        return ch - 'a' + 10;
    }
    
    return -1;
}

- (int)_intValueWithMutiplier:(int)multiplier
{
    int _result = 0;
    for ( int i = 0 ; i < [self length] ; i++ ) {
        char _ch = [self characterAtIndex:i];
        int _num = [NSString _intValueFromChar:_ch];
        if ( _num < 0 ) {
            // illegal
            return -1;
        }
        _result = _result * multiplier + _num;
    }
    return _result;
}

@end

typedef NS_ENUM(NSUInteger, CJMLAttributeType) {
    CJMLAttributeTypeNormal     = 0,
    CJMLAttributeTypeSkillName,
};

typedef NS_ENUM(NSUInteger, CJMLLexerState) {
    CJMLLexerStateStart,
    CJMLLexerStateNormal,
    CJMLLexerStateRecognizeMarkedLabelBegin,
    CJMLLexerStateMarkedText,
    CJMLLexerStateRecognizeMarkedLabelEnd,
};

static NSMutableDictionary *_gCJMLAttributesCache;

@implementation NSString (CJMarkedLanguage)

+ (void)registerAttributes:(NSDictionary *)attributes forAttributeName:(NSString *)attributeName
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gCJMLAttributesCache = [[NSMutableDictionary alloc] init];
    });
    [_gCJMLAttributesCache setObject:attributes forKey:attributeName];
}

- (NSAttributedString *)markedAttributedStringWithNormalAttributes:(NSDictionary *)attributes
{
    return [self markedAttributedStringWithNormalAttributes:attributes baseFont:[UIFont systemFontOfSize:15.f]];
}

- (NSAttributedString *)markedAttributedStringWithNormalAttributes:(NSDictionary *)normalAttribute baseFont:(UIFont *)baseFont
{
    if ( [self length] == 0 ) {
        return nil;
    }
    
    // process normal attribute
    NSMutableDictionary *_normalAttributes = [NSMutableDictionary dictionaryWithDictionary:normalAttribute];
    if ( baseFont != nil ) {
        [_normalAttributes setObject:baseFont forKey:NSFontAttributeName];
    }
    
    // lexer
    CJMLLexerState _currentState = CJMLLexerStateStart;
    NSUInteger _currentLetterIndex = 0;
    NSMutableAttributedString *_result = [[NSMutableAttributedString alloc] init];
    
    NSMutableString *_tempTextStr;
    NSMutableString *_tempAttributeName;
    NSMutableString *_tempAttributeEndName;
    NSMutableString *_tempPossibleAttributedStr;
    
    while ( _currentLetterIndex < [self length] ) {
        unichar _ch = [self characterAtIndex:_currentLetterIndex];
        switch ( _currentState ) {
            case CJMLLexerStateStart: {
                if ( _ch == '<' ) {
                    _currentState = CJMLLexerStateRecognizeMarkedLabelBegin;
                    _tempAttributeName = [[NSMutableString alloc] init];
                } else {
                    _currentState = CJMLLexerStateNormal;
                    _tempTextStr = [[NSMutableString alloc] init];
                    [_tempTextStr appendFormat:@"%C", _ch];
                }
                break;
            }
                
            case CJMLLexerStateNormal: {
                if ( _ch == '<' ) {
                    _currentState = CJMLLexerStateRecognizeMarkedLabelBegin;
                    _tempAttributeName = [[NSMutableString alloc] init];
                } else {
                    [_tempTextStr appendFormat:@"%C", _ch];
                }
                break;
            }
                
            case CJMLLexerStateMarkedText: {
                if ( _ch == '<' ) {
                    _currentState = CJMLLexerStateRecognizeMarkedLabelEnd;
                    _tempAttributeEndName = [[NSMutableString alloc] init];
                } else {
                    [_tempPossibleAttributedStr appendFormat:@"%C", _ch];
                }
                break;
            }
                
            case CJMLLexerStateRecognizeMarkedLabelBegin: {
                if ( _ch == '>' ) {
                    _currentState = CJMLLexerStateMarkedText;
                    _tempPossibleAttributedStr = [[NSMutableString alloc] init];
                } else {
                    [_tempAttributeName appendFormat:@"%C", _ch];
                }
                break;
            }
                
            case CJMLLexerStateRecognizeMarkedLabelEnd: {
                if ( _ch == '>' ) {
                    _currentState = CJMLLexerStateStart;
                    
                    // tempTextStr
                    if ( [_tempTextStr length] > 0 ) {
                        NSAttributedString *_attrText = [[NSAttributedString alloc]
                                                         initWithString:_tempTextStr attributes:_normalAttributes];
                        [_result appendAttributedString:_attrText];
                        _tempTextStr = nil;
                    }
                    
                    // attrText
                    NSAttributedString *_attrText = [[NSAttributedString alloc]
                                                     initWithString:_tempPossibleAttributedStr
                                                     attributes:[self _attributesForMLTypeName:_tempAttributeName baseFont:baseFont]];
                    [_result appendAttributedString:_attrText];
                    _tempPossibleAttributedStr = nil;
                    _tempAttributeName = nil;
                    _tempAttributeEndName = nil;
                    
                } else {
                    [_tempAttributeEndName appendFormat:@"%C", _ch];
                }
                break;
            }
                
            default:
                break;
        }
        _currentLetterIndex++;
    }
    
    NSMutableString *_finalStr = [[NSMutableString alloc] init];
    if ( [_tempTextStr length] > 0 ) {
        [_finalStr appendString:_tempTextStr];
    }
    if ( [_tempAttributeName length] > 0 ) {
        [_finalStr appendFormat:@"<%@>", _tempAttributeName];
    }
    if ( [_tempPossibleAttributedStr length] > 0 ) {
        [_finalStr appendFormat:@"%@", _tempPossibleAttributedStr];
    }
    if ( [_tempAttributeEndName length] > 0 ) {
        [_finalStr appendFormat:@"<%@>", _tempPossibleAttributedStr];
    }
    NSAttributedString *_finalAttrText = [[NSAttributedString alloc]
                                          initWithString:_finalStr attributes:_normalAttributes];
    [_result appendAttributedString:_finalAttrText];
    return _result;
}

- (NSDictionary *)_attributesForMLTypeName:(NSString *)attributeName
{
    return [_gCJMLAttributesCache objectForKey:attributeName];
}

- (NSDictionary *)_attributesForMLTypeName:(NSString *)attributeName baseFont:(UIFont *)baseFont
{
    NSDictionary *_attribuetesInCache = [_gCJMLAttributesCache objectForKey:attributeName];
    if ( baseFont == nil ) {
        return _attribuetesInCache;
    }
    NSMutableDictionary *_result = [NSMutableDictionary dictionaryWithDictionary:_attribuetesInCache];
    [_result setObject:baseFont forKey:NSFontAttributeName];
    return _result;
}

@end
