//
//  UIColor+CJUIKit.m
//
//  Created by fminor on 6/15/15.
//  Copyright (c) 2015 fminor. All rights reserved.
//

#import "UIColor+CJUIKit.h"
#import "NSString+CJUIKit.h"
#import <CoreGraphics/CoreGraphics.h>

#define kSizeColorSeparator                 @"|"
#define kWidthHeightSeparator               @","
#define kAtomColorSeparator                 @":"

#define CJ_DEFAULT_COLOR                    [UIColor clearColor]

typedef NS_OPTIONS(NSUInteger, CJGradientColorType) {
    CJGradientColorTypeNone                 = 0,
    CJGradientColorTypeHorizotal            = 1,
    CJGradientColorTypeVertical             = 1 << 1,
    CJGradientColorTypeBoth                 = CJGradientColorTypeHorizotal | CJGradientColorTypeVertical
};

void _fillOmittedLocation(CGFloat *locations, int locationCount);

void _parseGradientAtomColor(NSString *colorParam,
                             CGFloat colors[4],
                             CGFloat *location)
{
    if ( ![colorParam hasPrefix:@"#"] ) {
        return;
    }
    
    // parse location
    CGFloat _location = -1.0;
    NSRange _leftBracketRange = [colorParam rangeOfString:@"("];
    NSRange _rightBracketRange = [colorParam rangeOfString:@")"];
    if ( _leftBracketRange.location != NSNotFound && _rightBracketRange.location != NSNotFound ) {
        if ( _rightBracketRange.location > _leftBracketRange.location + 1 ) {
            NSString *_locationParam = [colorParam substringWithRange:NSMakeRange(_leftBracketRange.location + 1,
                                                                                  _rightBracketRange.location - _leftBracketRange.location - 1)];
            _location = [_locationParam floatValue];
        }
    }
    *location = _location;
    
    // parse color
    NSString *_colorParam = colorParam;
    if ( _leftBracketRange.location != NSNotFound ) {
        _colorParam = [colorParam substringToIndex:_leftBracketRange.location];
    }
    
    NSString *_capitalizedString = [[_colorParam uppercaseString] substringFromIndex:1];
    NSArray *_colorStringAndAlpha = [_capitalizedString componentsSeparatedByString:@"^"];
    NSString *_colorString = [_colorStringAndAlpha objectAtIndex:0];
    NSString *_alphaString = nil;
    if ( [_colorStringAndAlpha count] > 1 ) {
        _alphaString = [_colorStringAndAlpha objectAtIndex:1];
    }
    
    NSString *_rs = [_colorString substringWithRange:(NSRange){0, 2}];
    int _red = [_rs intValueWithHexadecimalFormat];
    colors[0] = (CGFloat)_red / 0xFF;
    
    NSString *_gs = [_colorString substringWithRange:(NSRange){2, 2}];
    int _green = [_gs intValueWithHexadecimalFormat];
    colors[1] = (CGFloat)_green / 0xFF;
    
    NSString *_bs = [_colorString substringWithRange:(NSRange){4, 2}];
    int _blue = [_bs intValueWithHexadecimalFormat];
    colors[2] = (CGFloat)_blue / 0xFF;
    
    CGFloat _alpha = 1.f;
    if ( _alphaString != nil ) {
        _alpha = [_alphaString floatValue];
    } else if ( [_colorString length] > 6 ) {
        NSString *_alphas = [_colorString substringWithRange:(NSRange){6, 2}];
        _alpha = (CGFloat)[_alphas intValueWithHexadecimalFormat] / 0xFF;
    }
    colors[3] = _alpha;
}

void _parseGradientColorCombination(NSString *colorCombination,
                                    CGFloat *colors, CGFloat *locations, int *colorCount, int *locationCount)
{
    NSArray *_colors = [colorCombination componentsSeparatedByString:kAtomColorSeparator];
    int _colorCount = (int)(_colors.count * 4);
    int _locationCount = (int)(_colors.count);
    
    int _colorPtr = 0;
    int _locationPtr = 0;
    for ( NSString *_atomColorParam in _colors ) {
        CGFloat _tempColors[4] = {0.0};
        CGFloat _tempLocation = 0.0;
        _parseGradientAtomColor(_atomColorParam, _tempColors, &_tempLocation);
        
        for ( int i = 0 ; i < 4 ; i++ ) {
            colors[_colorPtr++] = _tempColors[i];
        }
        locations[_locationPtr++] = _tempLocation;
    }
    
    // 处理 location 缺省
    _fillOmittedLocation(locations, _locationCount);
    *locationCount = _locationCount;
    *colorCount = _colorCount;
}

void _fillOmittedLocation(CGFloat *locations, int locationCount)
{
    if ( locationCount <= 0 ) return;
    
    int _startPtr = -1;
    int _curPtr = 0;
    int _endPtr = -1;
    
    if ( locations[0] < 0 ) {
        locations[0] = 0.0;
    }
    
    if ( locations[locationCount - 1] < 0 ) {
        locations[locationCount - 1] = 1.0;
    }
    
    while ( _curPtr < locationCount ) {
        if ( locations[_curPtr] >= 0.f ) {
            _curPtr++;
            continue;
        }
        
        if ( _curPtr == 0 ) {
            locations[_curPtr] = 0.0;
            _curPtr++;
            continue;
        }
        
        if ( _curPtr == locationCount - 1 ) {
            locations[_curPtr] = 1.0;
            _curPtr++;
            continue;
        }
        
        _startPtr = _curPtr - 1;
        CGFloat _start = locations[_startPtr];
        
        _endPtr = _curPtr + 1;
        CGFloat _end = locations[_endPtr];
        while ( _end < 0.0 ) {
            _endPtr++;
            _end = locations[_endPtr];
        }
        
        CGFloat _step = ( _end - _start ) / ( _endPtr - _startPtr );
        while ( _curPtr < _endPtr ) {
            locations[_curPtr] = locations[_curPtr - 1] + _step;
            _curPtr++;
        }
        
        _curPtr++;
    }
}

@implementation UIColor (TingShuo)

+ (UIColor *)colorWithString:(NSString *)colorString
{
    NSString *_colorString = [colorString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ( [_colorString rangeOfString:kSizeColorSeparator].location == NSNotFound ) {
        return [self _colorWithAtomColorString:_colorString];
    }
    
    NSArray *_components = [_colorString componentsSeparatedByString:@"|"];
    if ( [_components count] != 2 ) {
        return CJ_DEFAULT_COLOR;
    }
    
    NSString *_sizeParams = _components[0];
    NSString *_colorCombination = _components[1];
    
    // parse grometry info
    CJGradientColorType _colorType = CJGradientColorTypeNone;
    CGPoint _startPoint = CGPointZero;
    CGPoint _endPoint = CGPointZero;
    CGSize _size = [UIColor _parseSizeParams:_sizeParams gradientColorType:&_colorType
                                  startPoint:&_startPoint endPoint:&_endPoint];
    
    // parse gradient info
    CGFloat *_locations = malloc(sizeof(CGFloat) * 10);
    CGFloat *_colors = malloc(sizeof(CGFloat) * 10 * 4);
    int _locationCount = 0;
    int _colorCount = 0;
    _parseGradientColorCombination(_colorCombination, _colors, _locations, &_colorCount, &_locationCount);
    
    CGGradientRef _gradient;
    CGColorSpaceRef _colorSpace;
    
    _colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    _gradient = CGGradientCreateWithColorComponents(_colorSpace, _colors, _locations, _locationCount);
    
    UIGraphicsBeginImageContext(_size);
    CGContextRef _context = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(_context, _gradient, _startPoint, _endPoint, 0);
    
    UIImage *_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIColor *_color = [UIColor colorWithPatternImage:_image];
    return _color;
}

+ (UIColor *)_colorWithAtomColorString:(NSString *)colorString
{
    if ( ![colorString hasPrefix:@"#"] ) {
        return CJ_DEFAULT_COLOR;
    }
    
    NSString *_capitalizedString = [[colorString uppercaseString] substringFromIndex:1];
    NSArray *_colorStringAndAlpha = [_capitalizedString componentsSeparatedByString:@"^"];
    NSString *_colorString = [_colorStringAndAlpha objectAtIndex:0];
    NSString *_alphaString = nil;
    if ( [_colorStringAndAlpha count] > 1 ) {
        _alphaString = [_colorStringAndAlpha objectAtIndex:1];
    }
    
    NSString *_rs = [_colorString substringWithRange:(NSRange){0, 2}];
    int _red = [_rs intValueWithHexadecimalFormat];
    
    NSString *_gs = [_colorString substringWithRange:(NSRange){2, 2}];
    int _green = [_gs intValueWithHexadecimalFormat];
    
    NSString *_bs = [_colorString substringWithRange:(NSRange){4, 2}];
    int _blue = [_bs intValueWithHexadecimalFormat];
    
    CGFloat _alpha = 1.f;
    if ( _alphaString != nil ) {
        _alpha = [_alphaString floatValue];
    } else if ( [_colorString length] > 6 ) {
        NSString *_alphas = [_colorString substringWithRange:(NSRange){6, 2}];
        _alpha = (CGFloat)[_alphas intValueWithHexadecimalFormat] / 0xFF;
    }
    
    UIColor *_color = [UIColor colorWithRed:(CGFloat)_red / 0xFF green:(CGFloat)_green / 0xFF blue:(CGFloat)_blue / 0xFF
                                      alpha:_alpha];
    return _color;
}

#pragma mark - utils

+ (CGSize)_parseSizeParams:(NSString *)sizeParams gradientColorType:(CJGradientColorType *)gradientColorType startPoint:(CGPoint *)startPoint endPoint:(CGPoint *)endPoint;
{
    __block CGSize _result = CGSizeMake(1, 1);
    *startPoint = CGPointMake(0, 0);
    *endPoint = CGPointMake(0, 0);
    *gradientColorType = CJGradientColorTypeNone;
    
    NSError *_error;
    NSRegularExpression *_expression = [NSRegularExpression regularExpressionWithPattern:@"(h|w)\\((([0-9.]+)->)?([0-9.]+)\\)" options:0 error:&_error];
    if ( _error ) {
        return _result;
    }
    
    [_expression enumerateMatchesInString:sizeParams options:0 range:NSMakeRange(0, sizeParams.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        char _ch = [sizeParams characterAtIndex:result.range.location];
        NSRange _valuesRange = NSMakeRange(result.range.location + 2, result.range.length - 3);
        NSString *_values = [sizeParams substringWithRange:_valuesRange];
        NSArray *_components = [_values componentsSeparatedByString:@"->"];
        
        CGFloat _fromValue = 0;
        CGFloat _toValue = 0;
        
        if ( [_components count] == 1 ) {
            _toValue = [_components[0] floatValue];
            _fromValue = 0.0;
        } else if ( [_components count] == 2) {
            _fromValue = [_components[0] floatValue];
            _toValue = [_components[1] floatValue];
        }
        
        if ( _ch == 'w' ) {
            *gradientColorType = *gradientColorType | CJGradientColorTypeHorizotal;
            startPoint->x = _fromValue;
            endPoint->x = _toValue;
            _result.width = MAX(_fromValue, _toValue);
        } else if ( _ch == 'h' ) {
            *gradientColorType = *gradientColorType | CJGradientColorTypeVertical;
            startPoint->y = _fromValue;
            endPoint->y = _toValue;
            _result.height = MAX(_fromValue, _toValue);
        }
    }];
    return _result;
}

@end
