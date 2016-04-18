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

#import "UITableView+CJUpdator.h"
#import "CJPullUpdatorView.h"

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
    } else {
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
    if ( self.contentOffset.y <= - DEFAULT_UPDATOR_HEIGHT && _refreshView.pullState == CJPullUpdatorViewStateNormal ) {
        CJPullUpdatorView *_pullUpdatorView = [self _refreshContainer];
        [_pullUpdatorView reverseImage];
    }
    
    if ( self.contentOffset.y > - DEFAULT_UPDATOR_HEIGHT && _refreshView.pullState == CJPullUpdatorViewStateReady ) {
        CJPullUpdatorView *_pullUpdatorView = [self _refreshContainer];
        [_pullUpdatorView resetImage];
    }
}

@end
