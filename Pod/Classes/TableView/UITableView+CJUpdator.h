//
//  UITableView+CJUpdator.h
//  Pods
//
//  Created by fminor on 1/8/16.
//
//

#import <UIKit/UIKit.h>
#import "CJBasicPullUpdateAnimationView.h"
#import "CJPullUpdatorView.h"

typedef NS_OPTIONS(NSUInteger, CJUpdatorStyle) {
    CJUpdatorStyleNone                      = 0,
    CJUpdatorStyleRefresh                   = 1 << 0,
    CJUpdatorStyleLoadmore                  = 1 << 1,
    CJUpdatorStyleRefreshAndLoadmore        = ( CJUpdatorStyleRefresh | CJUpdatorStyleLoadmore ),
    CJUpdatorStyleDefault                   = CJUpdatorStyleNone
};

@interface UITableView (CJUpdator) <UIGestureRecognizerDelegate>

// table updator style properties

- (void)setTableUpdatorStyle:(CJUpdatorStyle)style;
- (BOOL)isRefreshStyle;
- (BOOL)isLoadmoreStyle;

// update action settings

- (void)setRefreshBlock:(void (^)(void))block;
- (void)setLoadMoreBlock:(void (^)(void))block;

@property (nonatomic, strong) CJBasicPullUpdateAnimationView    *updateAnimationView;               // refresh view
@property (nonatomic, strong) CJBasicPullUpdateAnimationView    *loadmoreAnimationView;             // loadmore view

- (void)finishUpdate;                   // stop update animation & reset tableView to normal state

@property (nonatomic, assign) CGFloat       minimumRefreshDuration;             // 刷新动画的最短时间，在这段时间内，即使被调用了 finishUpdate，动画仍然会继续，直到 minimumRefreshDuration 时间到

// 样式
@property (nonatomic, assign) CJPullUpdatorViewStyle    refreshStyle;       // 使用默认的刷新控件的样式
@property (nonatomic, assign) CJPullUpdatorViewStyle    loadmoreStyle;      // 使用默认的加载等多控件的样式

@end
