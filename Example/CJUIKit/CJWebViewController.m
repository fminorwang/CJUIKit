//
//  CJWebViewController.m
//  CJUIKit
//
//  Created by fminor on 5/20/16.
//  Copyright © 2016 fminor. All rights reserved.
//

#import "CJWebViewController.h"

@interface CJWebViewController ()

@end

@implementation CJWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [[CJWebView alloc] init];
    [_webView setFrame:self.view.bounds];
    [self.view addSubview:_webView];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.30.116:8081/awardPodcaster.html"]]];
    [_webView addJsbridgeAction:@"test" handler:^(NSDictionary *params) {
        UIAlertView *_alert = [[UIAlertView alloc]
                               initWithTitle:@"" message:@"test" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [_alert show];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
