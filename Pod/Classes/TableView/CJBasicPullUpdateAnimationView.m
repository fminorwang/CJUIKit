//
//  CJBasicPullUpdateAnimationView.m
//  Pods
//
//  Created by fminor on 7/18/16.
//
//

#import "CJBasicPullUpdateAnimationView.h"

@implementation CJBasicPullUpdateAnimationView

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setCurrentPullPercent:(CGFloat)percent
{
    // override by subclass
}

- (void)readyToUpdate
{
    self.state = CJPullUpdateStateReadyToUpdate;
    
    // override by subclass
}

- (void)changeToNormal
{
    self.state = CJPullUpdateStateNormal;
    
    // override by subclass
}

- (void)startUpdatingAnimation
{
    self.state = CJPullUpdateStateUpdating;
    
    // override by subclass
}

- (void)stopUpdatingAnimation
{
    self.state = CJPullUpdateStateNormal;
    
    // override by subclass
}

@end
