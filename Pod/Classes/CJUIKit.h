//
//  CJUIKit.h
//  Pods
//
//  Created by fminor on 01/12/2016.
//
//

#import "UIImage+CJUIKit.h"
#import "UIColor+CJUIKit.h"

#import "CJPullUpdatorView.h"

//#import "UIButton+CJUIKit.h"

#define CJ_X_FROM_LEFT_NEIGHBOUR(neighbour, margin)     ( neighbour.frame.origin.x + neighbour.bounds.size.width + margin )
#define CJ_Y_FROM_TOP_NEIGHBOUR(neighbour, margin)      ( neighbour.frame.origin.y + neighbour.bounds.size.height + margin )
