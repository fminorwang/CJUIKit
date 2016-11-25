//
//  UITableView+CJUpdator.m
//  Pods
//
//  Created by fminor on 1/8/16.
//
//

#import "UITableView+CJUpdator.h"
#import "CJPullUpdatorView.h"
#import "NSArray+CJUIKit.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "CJTouchEndGestureRecognizer.h"

#define DEFAULT_UPDATOR_HEIGHT                      44.f

#define REFRESH_CONTAINER_TAG                       1225
#define LOADMORE_CONTAINER_TAG                      9227

#define SCROLL_DURATION                             0.3f

#define pUpdateAnimationView                        "pUpdateAnimationView"
#define pLoadmoreAnimationView                      "pLoadmoreAnimationView"
#define pRefreshBlock                               "pRefreshBlock"
#define pLoadmoreBlock                              "pLoadmoreBlock"
#define pMinimumRefreshDuration                     "pMinimumRefreshDuration"
#define pRefreshTimer                               "pRefreshTimer"
#define pNeedsFinishUpdate                          "pNeedsFinishUpdate"

@implementation UITableView (CJUpdator)

- (void)setTableUpdatorStyle:(CJUpdatorStyle)style
{
    switch ( style ) {
        case CJUpdatorStyleRefresh:
            [self _removeLoadmoreContainer];
            [self _createRefreshContainer];
            break;
            
        case CJUpdatorStyleLoadmore:
            [self _removeRefreshContainer];
            [self _createLoadmoreContainer];
            break;
            
        case CJUpdatorStyleRefreshAndLoadmore:
            [self _createRefreshContainer];
            [self _createLoadmoreContainer];
            break;
            
        case CJUpdatorStyleNone:
            [self _removeRefreshContainer];
            [self _removeLoadmoreContainer];
            break;
            
        default:
            [self _removeRefreshContainer];
            [self _removeLoadmoreContainer];
            break;
    }
    
    if ( style != CJUpdatorStyleNone ) {        
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        [self.panGestureRecognizer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    } else {
    }
}

- (BOOL)isRefreshStyle
{
    return ( [self _getPullUpdatorContainerForUpdatorStyle:CJUpdatorStyleRefresh] != nil );
}

- (BOOL)isLoadmoreStyle
{
    return ( [self _getPullUpdatorContainerForUpdatorStyle:CJUpdatorStyleLoadmore] != nil );
}

- (void)setRefreshBlock:(void (^)(void))block
{
    objc_setAssociatedObject(self, pRefreshBlock, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setLoadMoreBlock:(void (^)(void))block
{
    objc_setAssociatedObject(self, pLoadmoreBlock, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)finishUpdate
{
    if ( [self isRefreshStyle] ) {
        if ( [self _refreshTimer] ) {
            [self _setNeedsFinishUpdate];
            return;
        }
        
        CJPullUpdatorView *_refreshView = [self _getPullUpdatorContainerForUpdatorStyle:CJUpdatorStyleRefresh];
        CJPullUpdatorView *_loadmoreView = [self _getPullUpdatorContainerForUpdatorStyle:CJUpdatorStyleLoadmore];
        
        UIEdgeInsets _insets = self.contentInset;
        if ( _refreshView && ( _refreshView.pullState == CJPullUpdatorViewStateAnimating )) {
            [_refreshView stopAnimation];
            _insets.top -= _refreshView.bounds.size.height;
        }
        if ( _loadmoreView && ( _loadmoreView.pullState == CJPullUpdatorViewStateAnimating )) {
            [_loadmoreView stopAnimation];
            _insets.bottom -= _loadmoreView.bounds.size.height;
        }

        [UIView animateWithDuration:SCROLL_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setContentInset:_insets];
        } completion:^(BOOL finished) {
            
        }];
        
        if ( self.updateAnimationView != nil ) {
            [self.updateAnimationView stopUpdatingAnimation];
        }
    }
}

#pragma mark - properties

- (void)setMinimumRefreshDuration:(CGFloat)minimumRefreshDuration
{
    objc_setAssociatedObject(self, pMinimumRefreshDuration, [NSNumber numberWithFloat:minimumRefreshDuration], OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)minimumRefreshDuration
{
    NSNumber *_duration = objc_getAssociatedObject(self, pMinimumRefreshDuration);
    if ( _duration == nil ) {
        return 0.f;
    }
    return [_duration floatValue];
}

#pragma mark - pull container init & dealloc

- (CJPullUpdatorView *)_refreshContainer
{
    return [self _getPullUpdatorContainerForUpdatorStyle:CJUpdatorStyleRefresh];
}

- (CJPullUpdatorView *)_loadmoreContainer
{
    return [self _getPullUpdatorContainerForUpdatorStyle:CJUpdatorStyleLoadmore];
}

- (CJPullUpdatorView *)_getPullUpdatorContainerForUpdatorStyle:(CJUpdatorStyle)style
{
    BOOL _isRefresh = ( style == CJUpdatorStyleRefresh );
    NSInteger _tag = _isRefresh ? REFRESH_CONTAINER_TAG : LOADMORE_CONTAINER_TAG;
    return [self.subviews firstObjectWhere:^BOOL(UIView *obj) {
        return obj.tag == _tag;
    }];
}

- (void)_createRefreshContainer
{
    return [self _createPullUpdatorContainerForUpdatorStyle:CJUpdatorStyleRefresh];
}

- (void)_createLoadmoreContainer
{
    return [self _createPullUpdatorContainerForUpdatorStyle:CJUpdatorStyleLoadmore];
}

- (void)_createPullUpdatorContainerForUpdatorStyle:(CJUpdatorStyle)style
{
    BOOL _isRefresh = ( style == CJUpdatorStyleRefresh );
    NSInteger _tag = ( style == CJUpdatorStyleRefresh ) ? REFRESH_CONTAINER_TAG : LOADMORE_CONTAINER_TAG;
    for ( UIView *_subview in self.subviews ) {
        if ( _subview.tag == _tag ) {
            return;
        }
    }
    
    CJPullUpdatorView *_pullUpdatorContainer = [[CJPullUpdatorView alloc] init];
    CGRect _container_frame = CGRectMake(0,
                                         _isRefresh ? (-DEFAULT_UPDATOR_HEIGHT) : self.contentSize.height,
                                         self.bounds.size.width,
                                         DEFAULT_UPDATOR_HEIGHT);
    [_pullUpdatorContainer setFrame:_container_frame];
    [_pullUpdatorContainer setTag:_tag];
    
    [self addSubview:_pullUpdatorContainer];
}

- (void)_removeRefreshContainer
{
    [self _removePullUpdatorContainerForUpdatorStyle:CJUpdatorStyleRefresh];
}

- (void)_removeLoadmoreContainer
{
    [self _removePullUpdatorContainerForUpdatorStyle:CJUpdatorStyleLoadmore];
}

- (void)_removePullUpdatorContainerForUpdatorStyle:(CJUpdatorStyle)style
{
    BOOL _isRefresh = ( style == CJUpdatorStyleRefresh );
    NSInteger _tag = _isRefresh ? REFRESH_CONTAINER_TAG : LOADMORE_CONTAINER_TAG;
    UIView *_updatorView = [self.subviews firstObjectWhere:^BOOL(UIView *subview) {
        return subview.tag == _tag;
    }];
    [_updatorView removeFromSuperview];
}

#pragma mark - animationView

- (void)setUpdateAnimationView:(CJBasicPullUpdateAnimationView *)updateAnimationView
{
    objc_setAssociatedObject(self, pUpdateAnimationView, updateAnimationView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    BOOL _isAnimateView = ( updateAnimationView != nil );
    [[self _refreshContainer] setHidden:_isAnimateView];
    
    if ( _isAnimateView ) {
        CGRect _animate_view_frame = updateAnimationView.frame;
        _animate_view_frame.origin.y = self.contentInset.top;
        [updateAnimationView setFrame:_animate_view_frame];
        
        if ( self.backgroundView ) {
            [self.backgroundView addSubview:updateAnimationView];
        } else {
            UIView *_backgroundView = [[UIView alloc] init];
            [_backgroundView setFrame:self.bounds];
            [_backgroundView setClipsToBounds:NO];
            [_backgroundView addSubview:updateAnimationView];
            [self setBackgroundView:_backgroundView];
        }
    }
}

- (void)setLoadmoreAnimationView:(CJBasicPullUpdateAnimationView *)loadmoreAnimationView
{
    objc_setAssociatedObject(self, pLoadmoreAnimationView, loadmoreAnimationView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    BOOL _isAnimateView = ( loadmoreAnimationView != nil );
    [[self _loadmoreContainer] setHidden:_isAnimateView];
    
    if ( loadmoreAnimationView ) {
        CGRect _loadmore_frame = loadmoreAnimationView.frame;
        _loadmore_frame.origin.y = self.bounds.size.height - _loadmore_frame.size.height - self.contentInset.bottom;
        [loadmoreAnimationView setFrame:_loadmore_frame];
        
        if ( self.backgroundView ) {
            [self.backgroundView addSubview:loadmoreAnimationView];
        } else {
            UIView *_backgroundView = [[UIView alloc] init];
            [_backgroundView setFrame:self.bounds];
            [_backgroundView setClipsToBounds:NO];
            [_backgroundView addSubview:loadmoreAnimationView];
            [self setBackgroundView:_backgroundView];
        }
    }
}

- (CJBasicPullUpdateAnimationView *)updateAnimationView
{
    return objc_getAssociatedObject(self, pUpdateAnimationView);
}

- (CJBasicPullUpdateAnimationView *)loadmoreAnimationView
{
    return objc_getAssociatedObject(self, pLoadmoreAnimationView);
}

#pragma mark - internal

- (void)_setRefreshTimer:(CGFloat)interval
{
    if ( fabs(interval) < 0.000001 ) {
        [self _clearRefreshTimer];
        return;
    }
    
    [self _clearRefreshTimer];
    NSTimer *_timer = [NSTimer timerWithTimeInterval:interval
                                              target:self
                                            selector:@selector(_actionTriggerRefreshTimer)
                                            userInfo:nil
                                             repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    objc_setAssociatedObject(self, pRefreshTimer, _timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimer *)_refreshTimer
{
    return objc_getAssociatedObject(self, pRefreshTimer);
}

- (void)_clearRefreshTimer
{
    NSTimer *_timer = [self _refreshTimer];
    if ( _timer != nil ) {
        [_timer invalidate];
        objc_setAssociatedObject(self, pRefreshTimer, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)_actionTriggerRefreshTimer
{
    [self _clearRefreshTimer];
    if ( [self _needsFinishUpdate] ) {
        [self finishUpdate];
        objc_setAssociatedObject(self, pNeedsFinishUpdate, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)_setNeedsFinishUpdate
{
    objc_setAssociatedObject(self, pNeedsFinishUpdate, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)_needsFinishUpdate
{
    NSNumber *_needsFinishUpdate = objc_getAssociatedObject(self, pNeedsFinishUpdate);
    if ( _needsFinishUpdate == nil ) return NO;
    return [_needsFinishUpdate boolValue];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ( object == self ) {
        if ( [keyPath isEqualToString:@"contentSize"] ) {
            [self _actionContentSizeChanged];
        }
        
        if ( [keyPath isEqualToString:@"contentOffset"] ) {
            [self _actionContentOffsetChanged];
        }
    }
    
    if ( object == self.panGestureRecognizer ) {
        if ( self.panGestureRecognizer.state == UIGestureRecognizerStateEnded ) {
            [self _actionTouchesEnded:self.panGestureRecognizer];
        }
    }
}

- (void)_actionContentSizeChanged
{
    CJPullUpdatorView *_loadmoreView = [self _loadmoreContainer];
    if ( _loadmoreView == nil ) {
        return;
    }
    
    if ( self.contentSize.height < self.bounds.size.height ) {
        [self _removeLoadmoreContainer];
        return;
    }
    
    [_loadmoreView setFrame:CGRectMake(0, self.contentSize.height,
                                       self.bounds.size.width, DEFAULT_UPDATOR_HEIGHT)];
}

- (void)_actionContentOffsetChanged
{
    // 刷新
    CJPullUpdatorView *_refreshView = [self _refreshContainer];
    if ( _refreshView != nil ) {
        if (( self.contentOffset.y <= - DEFAULT_UPDATOR_HEIGHT - self.contentInset.top )
            && ( _refreshView.pullState == CJPullUpdatorViewStateNormal )) {
            [_refreshView reverseImage];
        }
        
        if (( self.contentOffset.y > - DEFAULT_UPDATOR_HEIGHT - self.contentInset.top )
            && _refreshView.pullState == CJPullUpdatorViewStateReadyToRefresh ) {
            [_refreshView resetImage];
        }
        
        CJBasicPullUpdateAnimationView *_updateAnimationView = [self updateAnimationView];
        if ( _updateAnimationView ) {
            CGFloat _current = -self.contentOffset.y - self.contentInset.top;
            CGFloat _total = DEFAULT_UPDATOR_HEIGHT;
            CGFloat _percent = _current / _total;
            _percent = MIN(_percent, 1.0f);
            _percent = MAX(0.f, _percent);
            [_updateAnimationView setCurrentPullPercent:_percent];
        }
    }
    
    // 加载更多
    CJPullUpdatorView *_loadmoreView = [self _loadmoreContainer];
    if ( _loadmoreView != nil ) {
        if (( self.contentOffset.y + self.bounds.size.height >= self.contentSize.height + DEFAULT_UPDATOR_HEIGHT + self.contentInset.bottom ) && _loadmoreView.pullState == CJPullUpdatorViewStateNormal ) {
            [_loadmoreView reverseImage];
        }
        
        if (( self.contentOffset.y + self.bounds.size.height < self.contentSize.height + DEFAULT_UPDATOR_HEIGHT + self.contentInset.bottom ) && _loadmoreView.pullState == CJPullUpdatorViewStateReadyToRefresh ) {
            [_loadmoreView resetImage];
        }
    }
}

#pragma mark - touches ended

- (void)_actionTouchesEnded:(UIGestureRecognizer *)gesture
{
    if ( [self isRefreshStyle] ) {
        CJPullUpdatorView *_refreshView = [self _refreshContainer];
        if ( _refreshView.pullState == CJPullUpdatorViewStateReadyToRefresh ) {
            UIEdgeInsets _insets = self.contentInset;
            _insets.top += _refreshView.bounds.size.height;
            [UIView animateWithDuration:SCROLL_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self setContentInset:_insets];
            } completion:^(BOOL finished) {
                if ( self.updateAnimationView ) {
                    [self.updateAnimationView setCurrentPullPercent:0.f];
                }
            }];
            
            // 设置最短刷新时间
            CGFloat _minimumRefreshDuration = [self minimumRefreshDuration];
            if ( [self minimumRefreshDuration] > 0 ) {
                [self _setRefreshTimer:_minimumRefreshDuration];
            }
            
            // 开始刷新动画
            if ( self.updateAnimationView != nil ) {
                [self.updateAnimationView startUpdatingAnimation];
            }
            [_refreshView beginAnimation];
            
            // 刷新回调
            void (^_refreshBlock)() = objc_getAssociatedObject(self, pRefreshBlock);
            if ( _refreshBlock ) {
                _refreshBlock();
            }
        }
    }
    
    if ( [self isLoadmoreStyle] ) {
        CJPullUpdatorView *_loadmoreView = [self _loadmoreContainer];
        if ( _loadmoreView.pullState == CJPullUpdatorViewStateReadyToRefresh ) {
            UIEdgeInsets _insets = self.contentInset;
            _insets.bottom += _loadmoreView.bounds.size.height;
            [UIView animateWithDuration:SCROLL_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self setContentInset:_insets];
            } completion:^(BOOL finished) {
            }];
            
            [_loadmoreView beginAnimation];
            void (^_loadmoreBlock)() = objc_getAssociatedObject(self, pLoadmoreBlock);
            if ( _loadmoreBlock ) {
                _loadmoreBlock();
            }
        }
    }
}

//
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//    if ( [touch.view isKindOfClass:[UIControl class]] ) {
//        return NO;
//    }
    return YES;
}

@end
