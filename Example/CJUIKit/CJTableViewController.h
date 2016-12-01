//
//  CJTableViewController.h
//  CJUIKit
//
//  Created by fminor on 30/11/2016.
//  Copyright © 2016 fminor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    UIScrollView                    *_container;
}

@end
