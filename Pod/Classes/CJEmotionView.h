//
//  CJEmotionView.h
//  Pods
//
//  Created by fminor on 9/5/16.
//
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@protocol CJEmotionViewDelegate;

typedef NS_ENUM(NSInteger, CJEmotionAnimationType) {
    CJEmotionAnimationTypeMainType              = 0x000F << 0,
    
    CJEmotionAnimationTypeRain                  = 0,
    CJEmotionAnimationTypeNormal                = CJEmotionAnimationTypeRain,
    CJEmotionAnimationTypeHuge                  = 1,
    CJEmotionAnimationTypeRow                   = 2,
    CJEmotionAnimationTypeFireworks             = 3,
    
    CJEmotionAnimationTypeBasicTypeCount,
    
    CJEmotionAnimationTypeRotationType          = 0x000F << 4,
    
    CJEmotionAnimationTypeRotate                = 1 << 4,
    CJEmotionAnimationTypeSwing                 = 2 << 4,
};

@interface CJEmotionView : UIView<UIGestureRecognizerDelegate>
{
    CJEmotionAnimationType                      _animationType;
    
    NSMutableArray                              *_rainViews;
}

@property (nonatomic, assign) CJEmotionAnimationType    animationType;
@property (nonatomic, strong) UIImage                   *emotionImage;

@property (nonatomic, strong) NSArray                   *emotionImageArr;
@property (nonatomic, strong) NSArray                   *imageUrlArr;

// 动画参数
@property (nonatomic, assign) CGFloat                   rainMinDelay;               // default = 0
@property (nonatomic, assign) CGFloat                   rainMaxDelay;               // default = 4
@property (nonatomic, assign) CGFloat                   rainMinDuration;            // default = 1.5
@property (nonatomic, assign) CGFloat                   rainMaxDuration;            // default = 3.5
@property (nonatomic, assign) int                       rainTotalImageNumber;       // default = 50

// 一秒钟转的圈数
@property (nonatomic, assign) CGFloat                   rainMinRotateRate;          // default = 0.5
@property (nonatomic, assign) CGFloat                   rainMaxRotateRate;          // default = 10

// 注意: 和 UIView 不同，默认值是NO
@property (nonatomic, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

@property (nonatomic, weak) id<CJEmotionViewDelegate>   delegate;

@property (nonatomic, assign) BOOL                      spriteKitEnabled;           // 是否使用 SKNode 代替 CALayer, 默认 YES

- (void)displayInView:(UIView *)view;

@end

@protocol CJEmotionViewDelegate <NSObject>

- (void)userDidClickEmotionView:(UIView *)emotionView imageIndex:(int)index;

@end
