//
//  CJTableViewController.m
//  CJUIKit
//
//  Created by fminor on 30/11/2016.
//  Copyright © 2016 fminor. All rights reserved.
//

#import "CJTableViewController.h"
#import <UITableView+CJUpdator.h>
#import "TSUpdateAnimationView.h"

@interface CJTableViewController ()

@end

@implementation CJTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _container = [[UIScrollView alloc] init];
    [_container setFrame:self.view.bounds];
    [_container setPagingEnabled:YES];
    [self.view addSubview:_container];
    
    NSArray *_styleArr = @[@(CJPullUpdatorViewStyleVertical),
                           @(CJPullUpdatorViewStyleHorizontal)];
    
    // style 1, 2
    for ( int i = 0 ; i < 2 ; i++ ) {
        UITableView *_tableView = [[UITableView alloc] init];
        [_tableView setFrame:CGRectMake(i * self.view.bounds.size.width, 0,
                                        self.view.bounds.size.width, self.view.bounds.size.height)];
        [_tableView setBackgroundColor:[UIColor whiteColor]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setContentInset:UIEdgeInsetsMake(64.0, 0, 0, 0)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_container addSubview:_tableView];
        
        [_tableView setTableUpdatorStyle:CJUpdatorStyleRefreshAndLoadmore];
        [_tableView setRefreshStyle:[[_styleArr objectAtIndex:i] integerValue]];
        
        __weak UITableView *_wss = _tableView;
        [_tableView setRefreshBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ( _wss == nil ) {
                    return;
                }
                __strong UITableView *_sss = _wss;
                [_sss finishUpdate];
            });
        }];
        
        [_tableView setLoadMoreBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ( _wss == nil ) {
                    return;
                }
                __strong UITableView *_sss = _wss;
                [_sss finishUpdate];
            });
        }];
    }
    
    // style 3: custom refresh view
    UITableView *_customRefreshTableView = [[UITableView alloc]
                                            initWithFrame:CGRectMake(2 * _container.bounds.size.width,
                                                                     0,
                                                                     _container.bounds.size.width,
                                                                     _container.bounds.size.height)
                                            style:UITableViewStylePlain];
    [_customRefreshTableView setContentInset:UIEdgeInsetsMake(64.0, 0, 0, 0)];
    [_customRefreshTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _customRefreshTableView.delegate = self;
    _customRefreshTableView.dataSource = self;
    __weak UITableView *_wTable = _customRefreshTableView;
    [_customRefreshTableView setTableUpdatorStyle:CJUpdatorStyleRefresh];
    [_customRefreshTableView setUpdateAnimationView:[[TSUpdateAnimationView alloc] init]];
    [_customRefreshTableView setRefreshBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ( _wTable == nil ) {
                return;
            }
            __strong UITableView *_sTable = _wTable;
            [_sTable finishUpdate];
        });
    }];
    [_container addSubview:_customRefreshTableView];
    
    [_container setContentSize:CGSizeMake(self.view.bounds.size.width * 3, self.view.bounds.size.height)];
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
