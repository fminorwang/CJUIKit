//
//  CJPullUpdateAnimationView.h
//  Pods
//
//  Created by fminor on 7/18/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CJPullUpdateAnimationView <NSObject>

@required
- (void)setCurrentPullPercent:(CGFloat)percent;         // 设置当前下拉或上拉百分比，在这个方法中，实现此 protocal 的控件需要对 UI 进行重绘. percent 的取值范围 [0.0, 1.0]

- (void)startUpdatingAnimation;                         // 开始刷新或加载动画
- (void)stopUpdatingAnimation;                          // 停止刷新或加载动画

@end