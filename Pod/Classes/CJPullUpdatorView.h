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
    CJPullUpdatorViewStateReady,
    CJPullUpdatorViewStateAnimating
};

@interface CJPullUpdatorView : UIView
{
    UIImageView                     *_pullImageView;
    UILabel                         *_descriptionLabel;
}

@property (nonatomic, readonly) CJPullUpdatorViewState              pullState;

- (void)reverseImage;
- (void)resetImage;

- (void)beginAnimation;
- (void)stopAnimation;

@end
