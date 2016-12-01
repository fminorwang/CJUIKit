//
//  CJPullUpdatorView.h
//  Pods
//
//  Created by fminor on 1/8/16.
//
//

#import <UIKit/UIKit.h>
#import "CJBasicPullUpdateAnimationView.h"
#import "CJUIKit.h"

typedef NS_ENUM(NSInteger, CJPullUpdatorViewState) {
    CJPullUpdatorViewStateNormal,
    CJPullUpdatorViewStateReadyToUpdate,
    CJPullUpdatorViewStateAnimating
};

typedef NS_ENUM(NSInteger, CJPullUpdatorViewStyle) {
    CJPullUpdatorViewStyleDefault           = 0,
    CJPullUpdatorViewStyleHorizontal        = 1,
    CJPullUpdatorViewStyleVertical          = CJPullUpdatorViewStyleDefault,
    CJPullUpdatorViewStyleNoText            = 2,
};

@interface CJPullUpdatorView : CJBasicPullUpdateAnimationView
{
    UIImageView                     *_pullImageView;
    UILabel                         *_descriptionLabel;
}

@property (nonatomic, assign) CJPullUpdatorViewStyle style;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat innerMargin;

@end
