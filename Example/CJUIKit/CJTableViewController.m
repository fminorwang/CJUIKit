//
//  CJTableViewController.m
//  CJUIKit
//
//  Created by fminor on 30/11/2016.
//  Copyright © 2016 fminor. All rights reserved.
//

#import "CJTableViewController.h"
#import <UITableView+CJUpdator.h>

@interface CJTableViewController ()

@end

@implementation CJTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    _tableView = [[UITableView alloc] init];
    [_tableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView setTableUpdatorStyle:CJUpdatorStyleRefreshAndLoadmore];
    __weak CJTableViewController *_wss = self;
    [_tableView setRefreshBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ( _wss == nil ) {
                return;
            }
            __strong CJTableViewController *_sss = _wss;
            [_sss->_tableView finishUpdate];
        });
    }];
    
    [_tableView setLoadMoreBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ( _wss == nil ) {
                return;
            }
            __strong CJTableViewController *_sss = _wss;
            [_sss->_tableView finishUpdate];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"demo_cell"];
    if ( _cell == nil ) {
        _cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"demo_cell"];
        
        UIView *_sepLine = [[UIView alloc] init];
        [_sepLine setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_sepLine setBackgroundColor:[UIColor grayColor]];
        [_cell.contentView addSubview:_sepLine];
        
        NSDictionary *_views = NSDictionaryOfVariableBindings(_sepLine);
        [_cell.contentView addConstraints:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"H:|[_sepLine]|"
                                           options:0 metrics:nil views:_views]];
        [_cell.contentView addConstraints:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"V:[_sepLine(0.5)]|"
                                           options:0 metrics:nil views:_views]];
    }
    return _cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell.textLabel setText:[NSString stringWithFormat:@"%ld-%ld",
                             (long)indexPath.section + 1, (long)indexPath.row + 1]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
}

@end
