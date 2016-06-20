//
//  CJWebView.h
//  Pods
//
//  Created by fminor on 5/20/16.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

typedef NS_ENUM(NSUInteger, CJWebViewType) {
    CJWebViewTypeUIWebView              = 0,
    CJWebViewTypeWKWebView
};

@interface CJWebView : UIView
{
    UIWebView                   *_webView;
    WKWebView                   *_wkWebView;
    
    CJWebViewType               _webViewType;
}

- (instancetype)initWithWebViewType:(CJWebViewType)webViewType;

@end
