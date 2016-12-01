//
//  CJPullLoadmoreView.m
//  Pods
//
//  Created by fminor on 01/12/2016.
//
//

#import "CJPullLoadmoreView.h"

@interface CJPullLoadmoreView ()
{
    NSArray *_titles;
}

@end

@implementation CJPullLoadmoreView

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        _titles = @[@"上拉加载更多", @"释放加载更多", @"加载中..."];
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
