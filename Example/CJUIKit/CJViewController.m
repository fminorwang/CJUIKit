//
//  CJViewController.m
//  CJUIKit
//
//  Created by fminor on 01/08/2016.
//  Copyright (c) 2016 fminor. All rights reserved.
//

#import "CJViewController.h"

#import "CJWebViewController.h"
#import "CJTableViewController.h"
#import "CJColorViewController.h"

#import "CJUIKit-Prefix.pch"
#import "CJMaskView.h"

@interface CJViewController ()
{
    NSArray                 *_titles;
}

@end

@implementation CJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTranslucent:YES];
    self.title = @"CJUIKit";
    
    _tableView = [[UITableView alloc] init];
    [_tableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _titles = @[@"UITableView+CJUpdator: 刷新与加载更多", @"CJWebView", @"Color"];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"view_cell"];
    if ( _cell == nil ) {
        _cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"view_cell"];
        
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
        [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return _cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    cell.textLabel.text = [_titles objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ( indexPath.row ) {
        case 0: {
            CJTableViewController *_vc = [[CJTableViewController alloc] init];
            [self.navigationController pushViewController:_vc animated:YES];
            break;
        }
            
        case 1: {
            CJWebViewController *_vc = [[CJWebViewController alloc] init];
            [self.navigationController pushViewController:_vc animated:YES];
            break;
        }
            
        case 2: {
            CJColorViewController *_vc = [[CJColorViewController alloc] init];
            [self.navigationController pushViewController:_vc animated:YES];
        }
            
        default:
            break;
    }
}

@end
