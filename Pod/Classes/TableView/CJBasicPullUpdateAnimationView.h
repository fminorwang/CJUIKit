//
//  CJBasicPullUpdateAnimationView.h
//  Pods
//
//  Created by fminor on 7/18/16.
//
//

#import <UIKit/UIKit.h>
#import "CJPullUpdateAnimationProtocol.h"

typedef NS_ENUM(NSInteger, CJPullUpdateState) {
    CJPullUpdateStateNormal             = 0,
    CJPullUpdateStateReadyToUpdate,
    CJPullUpdateStateUpdating
};

@interface CJBasicPullUpdateAnimationView : UIView<CJPullUpdateAnimationProtocol>

@property (nonatomic, assign) CJPullUpdateState state;

@end
