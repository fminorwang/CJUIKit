//
//  CJPullUpdatorView.m
//  Pods
//
//  Created by fminor on 1/8/16.
//
//

#import "CJPullUpdatorView.h"

#define UPDATE_ICON_NAME                        @"pull-update-icon"
#define UPDATING_ICON_NAME                      @"pull-updating-icon"

#define ICON_WH                                 20.f
#define VERTICAL_INNER_MARGIN                   4.f

@interface CJPullUpdatorView ()
{
    UIColor             *_iColor;
    UIFont              *_iFont;
    CGFloat             _iInnerMargin;
    CGFloat             _iIconWH;
}

@end

@implementation CJPullUpdatorView

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        _iFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _iColor = [UIColor grayColor];
        _iInnerMargin = VERTICAL_INNER_MARGIN;
        _iIconWH = ICON_WH;
        
        NSBundle *_podBundle = [NSBundle bundleForClass:[self class]];
        NSURL *_bundleUrl = [_podBundle URLForResource:@"CJUIKit" withExtension:@"bundle"];
        NSBundle *_cjBundle = [NSBundle bundleWithURL:_bundleUrl];
        UIImage *_image = [UIImage imageNamed:[_cjBundle pathForResource:UPDATE_ICON_NAME ofType:@"png"]];
        
        _pullImageView = [[UIImageView alloc] init];
        [_pullImageView setImage:_image];
        [_pullImageView setContentMode:UIViewContentModeCenter];
        [_pullImageView setFrame:CGRectMake(0, 0, ICON_WH, ICON_WH)];
        [_pullImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_pullImageView];
        
        _descriptionLabel = [[UILabel alloc] init];
        [_descriptionLabel setFont:_iFont];
        [_descriptionLabel setTextColor:_iColor];
        [self addSubview:_descriptionLabel];
        
        [self setStyle:CJPullUpdatorViewStyleDefault];
    }
    return self;
}

- (void)setStyle:(CJPullUpdatorViewStyle)style
{
    _style = style;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch ( self.style ) {
        case CJPullUpdatorViewStyleVertical: {
            CGFloat _margin = ( self.bounds.size.height - _iIconWH - _iFont.lineHeight - _iInnerMargin ) / 2;
            [_pullImageView setFrame:CGRectMake(( self.bounds.size.width - _iIconWH ) / 2,
                                                _margin,
                                                _iIconWH, _iIconWH)];
            [_descriptionLabel setFrame:CGRectMake(0, CJ_Y_FROM_TOP_NEIGHBOUR(_pullImageView, VERTICAL_INNER_MARGIN),
                                                   self.bounds.size.width, _iFont.pointSize)];
            [_descriptionLabel setTextAlignment:NSTextAlignmentCenter];
            break;
        }
            
        case CJPullUpdatorViewStyleHorizontal: {
            NSString *_estimatedString = @"加载加载";
            CGFloat _estimatedLabelWidth = [_estimatedString sizeWithAttributes:@{ NSFontAttributeName : _iFont }].width;
            CGFloat _margin = ( self.bounds.size.width - _iIconWH - _estimatedLabelWidth - _iInnerMargin ) / 2;
            [_pullImageView setFrame:CGRectMake(_margin, ( self.bounds.size.height - _iIconWH ) / 2,
                                                _iIconWH, _iIconWH)];
            [_descriptionLabel setFrame:CGRectMake(CJ_X_FROM_LEFT_NEIGHBOUR(_pullImageView, _iInnerMargin),
                                                   0, self.bounds.size.width, self.bounds.size.height)];
            [_descriptionLabel setTextAlignment:NSTextAlignmentLeft];
            break;
        }
            
        default:
            break;
    }
}

- (void)readyToUpdate
{
    [super readyToUpdate];
    [self _reverseImage];
}

- (void)changeToNormal
{
    [super changeToNormal];
    [self _resetImage];
}

- (void)startUpdatingAnimation
{
    [super startUpdatingAnimation];
    [self _beginAnimation];
}

- (void)stopUpdatingAnimation
{
    [super stopUpdatingAnimation];
    [self _stopAnimation];
}

- (void)_reverseImage
{
    [UIView animateWithDuration:0.35f animations:^{
        [_pullImageView setTransform:CGAffineTransformMakeRotation(M_PI)];
    }];
}

- (void)_resetImage
{
    [UIView animateWithDuration:0.35f animations:^{
        [_pullImageView setTransform:CGAffineTransformIdentity];
    }];
}

- (void)_beginAnimation
{
    NSBundle *_podBundle = [NSBundle bundleForClass:[self class]];
    NSURL *_bundleUrl = [_podBundle URLForResource:@"CJUIKit" withExtension:@"bundle"];
    NSBundle *_cjBundle = [NSBundle bundleWithURL:_bundleUrl];
    UIImage *_image = [UIImage imageNamed:[_cjBundle pathForResource:UPDATING_ICON_NAME ofType:@"png"]];
    [_pullImageView setImage:_image];
    
    CABasicAnimation *_rotateAnimate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [_rotateAnimate setFromValue:@0];
    [_rotateAnimate setToValue:@(M_PI * 2)];
    [_rotateAnimate setRepeatCount:INT16_MAX];
    [_rotateAnimate setDuration:1.f];
    
    [_pullImageView.layer addAnimation:_rotateAnimate forKey:@"rotate"];
}

- (void)_stopAnimation
{
    [_pullImageView.layer removeAnimationForKey:@"rotate"];
    
    NSBundle *_podBundle = [NSBundle bundleForClass:[self class]];
    NSURL *_bundleUrl = [_podBundle URLForResource:@"CJUIKit" withExtension:@"bundle"];
    NSBundle *_cjBundle = [NSBundle bundleWithURL:_bundleUrl];
    UIImage *_image = [UIImage imageNamed:[_cjBundle pathForResource:UPDATE_ICON_NAME ofType:@"png"]];
    [_pullImageView setImage:_image];
}

@end
