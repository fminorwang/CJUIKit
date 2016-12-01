//
//  CJPullRefreshView.m
//  Pods
//
//  Created by fminor on 01/12/2016.
//
//

#import "CJPullRefreshView.h"

@interface CJPullRefreshView ()
{
    NSArray *_titles;
}

@end

@implementation CJPullRefreshView

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        _titles = @[@"下拉刷新", @"释放刷新", @"刷新中..."];
        [self _renderLabel];
    }
    return self;
}

- (void)readyToUpdate
{
    [super readyToUpdate];
    [self _renderLabel];
}

- (void)changeToNormal
{
    [super changeToNormal];
    [self _renderLabel];
}

- (void)startUpdatingAnimation
{
    [super startUpdatingAnimation];
    [self _renderLabel];
}

- (void)stopUpdatingAnimation
{
    [super stopUpdatingAnimation];
    [self _renderLabel];
}

- (void)_renderLabel
{
    [_descriptionLabel setText:[_titles objectAtIndex:self.state]];
}

@end
