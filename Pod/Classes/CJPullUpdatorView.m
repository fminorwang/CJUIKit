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

#define ICON_WH                                 30.f

@implementation CJPullUpdatorView

@synthesize updateAction = _updateAction;

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        NSBundle *_podBundle = [NSBundle bundleForClass:[self class]];
        NSURL *_bundleUrl = [_podBundle URLForResource:@"CJUIKit" withExtension:@"bundle"];
        NSBundle *_cjBundle = [NSBundle bundleWithURL:_bundleUrl];
        UIImage *_image = [UIImage imageNamed:[_cjBundle pathForResource:UPDATE_ICON_NAME ofType:@"png"]];
        
        _pullImageView = [[UIImageView alloc] init];
        [_pullImageView setImage:_image];
        [_pullImageView setContentMode:UIViewContentModeCenter];
        [self addSubview:_pullImageView];
        
        _pullState = CJPullUpdatorViewStateNormal;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [_pullImageView setFrame:CGRectMake(( self.bounds.size.width - ICON_WH ) / 2,
                                        ( self.bounds.size.height - ICON_WH ) / 2,
                                        ICON_WH,
                                        ICON_WH)];
    [_pullImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)reverseImage
{
    _pullState = CJPullUpdatorViewStateReadyToRefresh;
    [UIView animateWithDuration:0.35f animations:^{
        [_pullImageView setTransform:CGAffineTransformMakeRotation(M_PI)];
    }];
}

- (void)resetImage
{
    _pullState = CJPullUpdatorViewStateNormal;
    [UIView animateWithDuration:0.35f animations:^{
        [_pullImageView setTransform:CGAffineTransformIdentity];
    }];
}

- (void)beginAnimation
{
    _pullState = CJPullUpdatorViewStateAnimating;
    
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

- (void)stopAnimation
{
    _pullState = CJPullUpdatorViewStateNormal;
    
    [_pullImageView.layer removeAnimationForKey:@"rotate"];
    
    NSBundle *_podBundle = [NSBundle bundleForClass:[self class]];
    NSURL *_bundleUrl = [_podBundle URLForResource:@"CJUIKit" withExtension:@"bundle"];
    NSBundle *_cjBundle = [NSBundle bundleWithURL:_bundleUrl];
    UIImage *_image = [UIImage imageNamed:[_cjBundle pathForResource:UPDATE_ICON_NAME ofType:@"png"]];
    [_pullImageView setImage:_image];
}

@end
