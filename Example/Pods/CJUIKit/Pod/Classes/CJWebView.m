//
//  CJWebView.m
//  Pods
//
//  Created by fminor on 5/20/16.
//
//

#import "CJWebView.h"

@implementation CJWebView

- (instancetype)init
{
    return [self initWithWebViewType:CJWebViewTypeWKWebView];
}

- (instancetype)initWithWebViewType:(CJWebViewType)webViewType
{
    self = [super init];
    if ( self ) {
        _webViewType = webViewType;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
