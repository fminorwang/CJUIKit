//
//  CJViewController.m
//  CJUIKit
//
//  Created by fminor on 01/08/2016.
//  Copyright (c) 2016 fminor. All rights reserved.
//

#import "CJViewController.h"

#import "CJUIKit-Prefix.pch"

@interface CJViewController ()

@end

@implementation CJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] init];
    [_tableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    [_tableView setTableUpdatorStyle:CJUpdatorStyleRefreshAndLoadmore];
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
