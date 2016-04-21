//
//  UITableView+CJUpdator.m
//  Pods
//
//  Created by fminor on 1/8/16.
//
//

#define DEFAULT_UPDATOR_HEIGHT                      44.f

#define REFRESH_CONTAINER_TAG                       1225
#define LOADMORE_CONTAINER_TAG                      9227

#define SCROLL_DURATION                             0.3f

#import "UITableView+CJUpdator.h"
#import "CJPullUpdatorView.h"
#import "CJTouchEndGestureRecognizer.h"
#import <objc/runtime.h>
#import <objc/message.h>

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
        CJTouchEndGestureRecognizer *_endGesture = [[CJTouchEndGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(_actionTouchesEnded:)];
        
        __strong UITableView *_sss = self;
        SEL _selector = @selector(setDelegate:);
        NSMethodSignature *_methodSig = [[CJTouchEndGestureRecognizer class] instanceMethodSignatureForSelector:_selector];
        NSInvocation *_invocation = [NSInvocation invocationWithMethodSignature:_methodSig];
        [_invocation setTarget:_endGesture];
        [_invocation setSelector:_selector];
        [_invocation setArgument:&_sss atIndex:2];
        [_invocation retainArguments];
        [_invocation invoke];
        
        [self addGestureRecognizer:_endGesture];
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
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
    if ( block == nil ) {
        return;
    }
    
    CJPullUpdatorView *_pullUpdatorView = [self _getPullUpdatorContainerForUpdatorStyle:CJUpdatorStyleRefresh];
    if ( _pullUpdatorView == nil ) {
        return;
    }
    
    [_pullUpdatorView setUpdateAction:block];
}

- (void)setLoadMoreBlock:(void (^)(void))block
{
    if ( block == nil ) {
        return;
    }
    
    CJPullUpdatorView *_pullUpdatorView = [self _getPullUpdatorContainerForUpdatorStyle:CJUpdatorStyleLoadmore];
    if ( _pullUpdatorView == nil ) {
        return;
    }
    
    [_pullUpdatorView setUpdateAction:block];
}

- (void)finishUpdate
{
    if ( [self isRefreshStyle] ) {
        CJPullUpdatorView *_refreshView = [self _getPullUpdatorContainerForUpdatorStyle:CJUpdatorStyleRefresh];
        [_refreshView stopAnimation];
        
        UIEdgeInsets _insets = self.contentInset;
        _insets.top -= _refreshView.bounds.size.height;
        [UIView animateWithDuration:SCROLL_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setContentInset:_insets];
        } completion:^(BOOL finished) {
            
        }];
    }
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
    for ( UIView *_subview in self.subviews ) {
        if ( _subview.tag == _tag ) {
            return (CJPullUpdatorView *)_subview;
        }
    }
    return nil;
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
                                         _isRefresh ? (-DEFAULT_UPDATOR_HEIGHT) : self.bounds.size.height,
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
    for ( UIView *_subview in self.subviews ) {
        if ( _subview.tag == _tag ) {
            return [_subview removeFromSuperview];
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ( ![keyPath isEqualToString:@"contentOffset"] ) {
        return;
    }
    
    CJPullUpdatorView *_refreshView = [self _refreshContainer];
    if (( self.contentOffset.y <= - DEFAULT_UPDATOR_HEIGHT - self.contentInset.top )
        && ( _refreshView.pullState == CJPullUpdatorViewStateNormal )) {
        CJPullUpdatorView *_pullUpdatorView = [self _refreshContainer];
        [_pullUpdatorView reverseImage];
    }
    
    if (( self.contentOffset.y > - DEFAULT_UPDATOR_HEIGHT - self.contentInset.top )
        && _refreshView.pullState == CJPullUpdatorViewStateReadyToRefresh ) {
        CJPullUpdatorView *_pullUpdatorView = [self _refreshContainer];
        [_pullUpdatorView resetImage];
    }
}

#pragma mark - touches ended

- (void)_actionTouchesEnded:(UIGestureRecognizer *)gesture
{
    if ( [self isRefreshStyle] ) {
        CJPullUpdatorView *_refreshView = [self _refreshContainer];
        UIEdgeInsets _insets = self.contentInset;
        _insets.top += _refreshView.bounds.size.height;
        [UIView animateWithDuration:SCROLL_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setContentInset:_insets];
        } completion:^(BOOL finished) {
            [_refreshView beginAnimation];
        }];
        
        if ( _refreshView.updateAction ) {
            _refreshView.updateAction();
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[CJTouchEndGestureRecognizer class]] ) {
        return YES;
    }
    
    return NO;
}

@end
