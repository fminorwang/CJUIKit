//
//  CJPullUpdatorView.h
//  Pods
//
//  Created by fminor on 1/8/16.
//
//

#import <UIKit/UIKit.h>
#import "CJBasicPullUpdateAnimationView.h"

typedef NS_ENUM(NSInteger, CJPullUpdatorViewState) {
    CJPullUpdatorViewStateNormal,
    CJPullUpdatorViewStateReadyToRefresh,
    CJPullUpdatorViewStateAnimating
};

@interface CJPullUpdatorView : CJBasicPullUpdateAnimationView
{
    UIImageView                     *_pullImageView;
    UILabel                         *_descriptionLabel;
    
    void (^_updateAction)(void);
}

@property (nonatomic, readonly)     CJPullUpdatorViewState              pullState;
@property (nonatomic, strong)       void (^updateAction)();

- (void)reverseImage;
- (void)resetImage;

@end
