//
//  UITableView+CJUpdator.h
//  Pods
//
//  Created by fminor on 1/8/16.
//
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, CJUpdatorStyle) {
    CJUpdatorStyleNone                      = 0,
    CJUpdatorStyleRefresh                   = 1 << 0,
    CJUpdatorStyleLoadmore                  = 1 << 1,
    CJUpdatorStyleRefreshAndLoadmore        = ( CJUpdatorStyleRefresh | CJUpdatorStyleLoadmore ),
    CJUpdatorStyleDefault                   = CJUpdatorStyleNone
};

@interface UITableView (CJUpdator)

- (void)setTableUpdatorStyle:(CJUpdatorStyle)style;

@end
