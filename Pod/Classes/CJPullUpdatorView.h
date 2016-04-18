//
//  CJPullUpdatorView.h
//  Pods
//
//  Created by fminor on 1/8/16.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CJPullUpdatorViewState) {
    CJPullUpdatorViewStateNormal,
    CJPullUpdatorViewStateReadyToRefresh,
    CJPullUpdatorViewStateAnimating
};

@interface CJPullUpdatorView : UIView
{
    UIImageView                     *_pullImageView;
    UILabel                         *_descriptionLabel;
    
    void (^_updateAction)(void);
}

@property (nonatomic, readonly)     CJPullUpdatorViewState              pullState;
@property (nonatomic, strong)       void (^updateAction)();

- (void)reverseImage;
- (void)resetImage;

- (void)beginAnimation;
- (void)stopAnimation;

@end
