//
//  CJViewController.h
//  CJUIKit
//
//  Created by fminor on 01/08/2016.
//  Copyright (c) 2016 fminor. All rights reserved.
//

@import UIKit;

#import <CJUIKit/UIColor+CJUIKit.h>
#import <CJUIKit/UITableView+CJUpdator.h>

@interface CJViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    UITableView                     *_tableView;
}

@end
