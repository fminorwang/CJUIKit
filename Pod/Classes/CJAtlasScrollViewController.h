//
//  CJAtlasScrollViewController.h
//  Pods
//
//  Created by fminor on 7/7/16.
//
//

#import <UIKit/UIKit.h>

@interface CJAtlasScrollViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, copy)     NSArray                 *imageUrlList;
@property (nonatomic, assign)   int                     currentDisplayIndex;
@property (nonatomic, assign)   CGRect                  atlasOriginLocation;                    // 原始图片相对于整个屏幕的 frame, 在 viewController 切换动画时使用到这个属性

@end
