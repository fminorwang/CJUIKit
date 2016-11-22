//
//  CJWebViewController.m
//  CJUIKit
//
//  Created by fminor on 5/20/16.
//  Copyright © 2016 fminor. All rights reserved.
//

#import "CJWebViewController.h"
#import "CJMaskView.h"

@interface CJWebViewController ()

@end

@implementation CJWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[CJWebView alloc] initWithWebViewType:CJWebViewTypeUIWebView];
    [_webView setFrame:self.view.bounds];
    [self.view addSubview:_webView];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.qingting.fm/"]]];
    [_webView addJsbridgeAction:@"test" handler:^(NSDictionary *params) {
        UIAlertView *_alert = [[UIAlertView alloc]
                               initWithTitle:@"" message:@"test" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [_alert show];
    }];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(_actionBack)]];
    
//    CJMaskView *_maskView = [[CJMaskView alloc] init];
//    [_maskView setFrame:self.view.bounds];
//    [_maskView setBackgroundColor:[UIColor clearColor]];
//    [self.view addSubview:_maskView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_actionBack
{
    if ( [_webView canGoBack] ) {
        [_webView goBack];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
