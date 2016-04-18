//
//  CJPullUpdatorView.m
//  Pods
//
//  Created by fminor on 1/8/16.
//
//

#import "CJPullUpdatorView.h"

@implementation CJPullUpdatorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        NSBundle *_podBundle = [NSBundle bundleForClass:[self class]];
        NSURL *_bundleUrl = [_podBundle URLForResource:@"CJUIKit" withExtension:@"bundle"];
        NSBundle *_cjBundle = [NSBundle bundleWithURL:_bundleUrl];
        UIImage *_image = [UIImage imageNamed:[_cjBundle pathForResource:@"pull-update-icon" ofType:@"png"]];
        
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
    [_pullImageView setFrame:CGRectMake(( self.bounds.size.width - self.bounds.size.height ) / 2,
                                        0,
                                        self.bounds.size.height,
                                        self.bounds.size.height)];
    [_pullImageView setContentMode:UIViewContentModeCenter];
}

- (void)reverseImage
{
    _pullState = CJPullUpdatorViewStateReady;
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

@end
