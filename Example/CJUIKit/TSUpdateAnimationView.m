//
//  TSUpdateAnimationView.m
//  ZFTingShuo
//
//  Created by fminor on 7/18/16.
//  Copyright © 2016 fminor. All rights reserved.
//

#import "TSUpdateAnimationView.h"

@interface TSUpdateAnimationView ()
{
    CGFloat                 _percent;
    
    // 第一条弧
    CGPoint                 _startPt;
    CGPoint                 _arcPt1;
    CGPoint                 _arcCntPt1;
    CGFloat                 _radius1;
    double                  _length_arc1;
    
    // 直线1
    CGPoint                 _arcPt2;
    double                  _length_line1;
    
    // 圆角1
    double                  _cnt2_radius;
    CGPoint                 _cnt2;
    CGPoint                 _arcPt2_end;
    double                  _length_cr1;
    
    // 直线2
    double                  _cnt3_radius;
    CGPoint                 _arcPt3_start;
    double                  _length_line2;
    
    // 圆角2
    CGPoint                 _cnt3;
    double                  _length_cr2;
    
    // 直线3
    double                  _length_line3;
    
    // 圆弧2
    CGPoint                 _arc_q_cnt;
    double                  _arc_q_radius;
    CGFloat                 _arc_q_angle;
    double                  _length_arc_q;
    
    // U
    CGPoint                 _u_pt1;
    CGPoint                 _u_pt2;
    double                  _length_u1;
    
    CGPoint                 _u_cnt;
    double                  _u_radius;
    double                  _length_u2;
    
    CGPoint                 _u_pt3;
    CGPoint                 _u_pt4;
    double                  _length_u3;
    
    double                  _length_total;
    
    double                  _eye_length;
    CGPoint                 _left_eye_pt;
    CGPoint                 _right_eye_pt;
    
    struct {
        BOOL                _isRefreshing;
    } _flags;
    
    CALayer                 *_leftEye;
    CALayer                 *_rightEye;
}

@end

@implementation TSUpdateAnimationView

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        _percent = 0.f;
        _flags._isRefreshing = NO;
        
        UIColor *_eyeColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        _leftEye = [[CALayer alloc] init];
        [_leftEye setBackgroundColor:_eyeColor.CGColor];
        [_leftEye setOpacity:0];
        [self.layer addSublayer:_leftEye];
        
        _rightEye = [[CALayer alloc] init];
        [_rightEye setBackgroundColor:_eyeColor.CGColor];
        [_rightEye setOpacity:0];
        [self.layer addSublayer:_rightEye];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _computeTotalLength:self.frame];
}

#pragma mark - pull update animation view

- (void)setCurrentPullPercent:(CGFloat)percent
{
    if ( _flags._isRefreshing ) {
        return;
    }
    _percent = percent;
    [self setNeedsDisplay];
}

- (void)startUpdatingAnimation
{
    _flags._isRefreshing = YES;
    _percent = 1.0f;
    
    [self setNeedsDisplay];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_leftEye setOpacity:1.f];
    [_rightEye setOpacity:1.f];
    [CATransaction commit];
    
    CAKeyframeAnimation *_animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    [_animation setKeyTimes:@[@0, @0.25, @0.5, @0.75, @1.0]];
    [_animation setValues:@[@0, @(-_eye_length / 2), @0, @(_eye_length / 2), @0]];
    [_animation setDuration:0.6f];
    [_animation setRepeatCount:INT_MAX];
    
    [_leftEye addAnimation:_animation forKey:@"left_eye_anim"];
    [_rightEye addAnimation:_animation forKey:@"right_eye_anim"];
}

- (void)stopUpdatingAnimation
{
    _flags._isRefreshing = NO;
    [_leftEye removeAllAnimations];
    [_rightEye removeAllAnimations];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_leftEye setOpacity:0.f];
    [_rightEye setOpacity:0.f];
    [CATransaction commit];
}

#pragma mark - redraw

- (void)drawRect:(CGRect)rect
{
    CGFloat _current = _percent;
    
    CGContextRef _ref = UIGraphicsGetCurrentContext();
    
    while ( YES ) {
        if ( _percent <= 0 ) {
            break;
        }
        
        // 第一条弧
        CGContextMoveToPoint(_ref, _startPt.x, _startPt.y);
        CGFloat _ratio = _length_arc1 / _length_total;
        if ( _current < _ratio ) {
            CGContextAddArc(_ref, _arcCntPt1.x, _arcCntPt1.y, _radius1, 0, M_PI * _current / _ratio, 0);
            break;
        }
        _current -= _ratio;
        CGContextAddArc(_ref, _arcCntPt1.x, _arcCntPt1.y, _radius1, 0, M_PI, 0);
        
        // 直线1
        _ratio = _length_line1 / _length_total;
        if ( _current < _ratio ) {
            CGContextAddLineToPoint(_ref,
                                    _arcPt1.x + _current / _ratio * ( _arcPt2.x - _arcPt1.x),
                                    _arcPt1.y + _current / _ratio * ( _arcPt2.y - _arcPt1.y));
            break;
        }
        _current -= _ratio;
        CGContextAddLineToPoint(_ref, _arcPt2.x, _arcPt2.y);
        
        // 圆角1
        _ratio = _length_cr1 / _length_total;
        if ( _current < _ratio ) {
            CGContextAddArc(_ref, _cnt2.x, _cnt2.y, _cnt2_radius, M_PI, M_PI * ( 1 + 0.5 * _current / _ratio ), 0);
            break;
        }
        _current -= _ratio;
        CGContextAddArc(_ref, _cnt2.x, _cnt2.y, _cnt2_radius, M_PI, M_PI * 1.5 , 0);
        
        // 直线2
        _ratio = _length_line2 / _length_total;
        if ( _current < _ratio ) {
            CGContextAddLineToPoint(_ref,
                                    _arcPt2_end.x + _current / _ratio * ( _arcPt3_start.x - _arcPt2_end.x),
                                    _arcPt2_end.y + _current / _ratio * ( _arcPt3_start.y - _arcPt2_end.y));

            break;
        }
        _current -= _ratio;
        CGContextAddLineToPoint(_ref, _arcPt3_start.x, _arcPt3_start.y);
        
        // 圆角2
        _ratio = _length_cr2 / _length_total;
        if ( _current < _ratio ) {
            CGContextAddArc(_ref, _cnt3.x, _cnt3.y, _cnt3_radius, M_PI * 1.5, M_PI * ( 1.5 + 0.5 * _current / _ratio ), 0);
            break;
        }
        _current -= _ratio;
        CGContextAddArc(_ref, _cnt3.x, _cnt3.y, _cnt3_radius, M_PI * 1.5, M_PI * 2, 0);
        
        // 直线3
        _ratio = _length_line3 / _length_total;
        if ( _current < _ratio ) {
            CGContextAddLineToPoint(_ref,
                                    _startPt.x,
                                    _arcPt2.y + _current / _ratio * ( _startPt.y - _arcPt2.y));
            
            break;
        }
        _current -= _ratio;
        CGContextAddLineToPoint(_ref, _startPt.x, _startPt.y);
        
        // 园弧2
        _ratio = _length_arc_q / _length_total;
        if ( _current < _ratio ) {
            CGContextAddArc(_ref, _arc_q_cnt.x, _arc_q_cnt.y, _arc_q_radius, M_PI, M_PI + ( _current / _ratio ) * ( _arc_q_angle - M_PI), 1);
            break;
        }
        _current -= _ratio;
        CGContextAddArc(_ref, _arc_q_cnt.x, _arc_q_cnt.y, _arc_q_radius, M_PI, _arc_q_angle, 1);
        
        // u1
        CGContextMoveToPoint(_ref, _u_pt1.x, _u_pt1.y);
        _ratio = _length_u1 / _length_total;
        if ( _current < _ratio ) {
            CGContextAddLineToPoint(_ref,
                                    _u_pt1.x + _current / _ratio * ( _u_pt2.x - _u_pt1.x),
                                    _u_pt1.y + _current / _ratio * ( _u_pt2.y - _u_pt1.y));
            
            break;
        }
        _current -= _ratio;
        CGContextAddLineToPoint(_ref, _u_pt2.x, _u_pt2.y);
        
        // u2
        _ratio = _length_u2 / _length_total;
        if ( _current < _ratio ) {
            CGContextAddArc(_ref, _u_cnt.x, _u_cnt.y, _u_radius, M_PI, M_PI * ( 1 - _current / _ratio ), 1);
            break;
        }
        _current -= _ratio;
        CGContextAddArc(_ref, _u_cnt.x, _u_cnt.y, _u_radius, M_PI, 0, 1);
        
        // u3
        _ratio = _length_u3 / _length_total;
        if ( _current < _ratio ) {
            CGContextAddLineToPoint(_ref,
                                    _u_pt3.x + _current / _ratio * ( _u_pt4.x - _u_pt3.x),
                                    _u_pt3.y + _current / _ratio * ( _u_pt4.y - _u_pt3.y));
            
            break;
        }
        _current -= _ratio;
        CGContextAddLineToPoint(_ref, _u_pt4.x, _u_pt4.y);
        
        if ( _flags._isRefreshing ) {
            break;
        }
        
        // left eye
        CGContextMoveToPoint(_ref, _left_eye_pt.x, _left_eye_pt.y);
        _ratio = _eye_length / _length_total;
        if ( _current < _ratio ) {
            CGContextAddLineToPoint(_ref,
                                    _left_eye_pt.x + _eye_length * ( _current / _ratio ),
                                    _left_eye_pt.y);
            break;
        }
        _current -= _ratio;
        CGContextAddLineToPoint(_ref, _left_eye_pt.x + _eye_length, _left_eye_pt.y);
        
        // right eye
        CGContextMoveToPoint(_ref, _right_eye_pt.x, _right_eye_pt.y);
        _ratio = _eye_length / _length_total;
        if ( _current < _ratio ) {
            CGContextAddLineToPoint(_ref,
                                    _right_eye_pt.x + _eye_length * ( _current / _ratio ),
                                    _right_eye_pt.y);
            break;
        }
        _current -= _ratio;
        CGContextAddLineToPoint(_ref, _right_eye_pt.x + _eye_length, _right_eye_pt.y);
        break;
    }
    
    CGContextSetLineWidth(_ref, 1);
    CGContextSetRGBStrokeColor(_ref, 0.5, 0.5, 0.5, 1.0);
    CGContextStrokePath(_ref);
}

- (void)_computeTotalLength:(CGRect)rect
{
    CGFloat _width = rect.size.width;
    CGFloat _height = rect.size.height;
    
    CGFloat _length = _height;
    CGPoint _origin = CGPointMake(( _width - _length ) / 2,
                                  ( _height - _length ) / 2);
    
    double _realWidth = 180.f;
    double _realHeight = 180.f;
    double _ratio_x = _length / _realWidth;
    double _ratio_y = _length / _realHeight;
    
    // 第一条弧
    _startPt = CGPointMake(_origin.x + 92.f * _ratio_x,
                           _origin.y + 124.f * _ratio_y);
    _arcPt1 = CGPointMake(_origin.x + 32.f *_ratio_x,
                          _origin.y + 124.f * _ratio_y);
    _arcCntPt1 = CGPointMake(( _startPt.x + _arcPt1.x ) / 2,
                             ( _startPt.y + _arcPt1.y ) / 2);
    _radius1 = _arcCntPt1.x - _arcPt1.x;
    _length_arc1 = _radius1 * M_PI;
    
    // 直线1
    _arcPt2 = CGPointMake(_origin.x + 32.f * _ratio_x,
                          _origin.y + 46.f * _ratio_y);
    _length_line1 = ( _arcPt1.y - _arcPt2.y );
    
    // 圆角1
    _cnt2_radius = 10.f * _ratio_x;
    _cnt2 = CGPointMake(_arcPt2.x + _cnt2_radius, _arcPt2.y);
    _arcPt2_end = CGPointMake(_arcPt2.x + _cnt2_radius, _arcPt2.y - _cnt2_radius);
    _length_cr1 = _cnt2_radius * M_PI / 2;
    
    // 直线2
    _cnt3_radius = 10.f * _ratio_x;
    _arcPt3_start = CGPointMake(_startPt.x - _cnt3_radius, _arcPt2_end.y);
    _length_line2 = ( _arcPt3_start.x - _arcPt2_end.x );
    
    // 圆角2
    _cnt3 = CGPointMake(_arcPt3_start.x, _arcPt3_start.y + _cnt3_radius);
    _length_cr2 = _cnt3_radius * M_PI / 2;
    
    // 直线3
    _length_line3 = _length_line2;
    
    // 圆弧2
    _arc_q_radius = 40.f * _ratio_x;
    _arc_q_cnt = CGPointMake(_startPt.x + _arc_q_radius, _startPt.y);
    _arc_q_angle = M_PI * 0.76;
    _length_arc_q = ( M_PI - _arc_q_angle ) * _arc_q_radius;
    
    // u
    _u_pt1 = CGPointMake(_origin.x + 116.f * _ratio_x, _origin.y + 110.f * _ratio_x);
    _u_pt2 = CGPointMake(_u_pt1.x, _origin.y + 134.f * _ratio_x);
    _length_u1 = _u_pt2.y - _u_pt1.y;
    
    _u_pt3 = CGPointMake(_origin.x + 148.f * _ratio_x, _u_pt2.y);
    _u_cnt = CGPointMake((_u_pt3.x + _u_pt2.x ) / 2, ( _u_pt3.y + _u_pt2.y ) / 2);
    _u_radius = ( _u_pt3.x - _u_pt2.x ) / 2;
    _length_u2 = M_PI * _u_radius;
    
    _u_pt4 = CGPointMake(_u_pt3.x, _u_pt1.y);
    _length_u3 = _u_pt3.y - _u_pt4.y;
    
    // eye
    _eye_length = 10.f * _ratio_x;
    _left_eye_pt = CGPointMake(_arcPt1.x + 20.f * _ratio_x - _eye_length / 2, _arcPt2_end.y + 30.f * _ratio_y);
    _right_eye_pt = CGPointMake(_arcPt1.x + 40.f * _ratio_x - _eye_length / 2, _left_eye_pt.y);
    
    [_leftEye setFrame:CGRectMake(_left_eye_pt.x, _left_eye_pt.y, _eye_length, 1)];
    [_rightEye setFrame:CGRectMake(_right_eye_pt.x, _right_eye_pt.y, _eye_length, 1)];
    
    // total
    _length_total = _length_arc1 + _length_line1 + _length_cr1 + _length_line2 + _length_cr2 + _length_line3 + _length_arc_q + _length_u1 + _length_u2 + _length_u3 + _eye_length * 2;
}

@end
