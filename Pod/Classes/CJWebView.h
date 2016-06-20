//
//  CJWebView.h
//  Pods
//
//  Created by fminor on 5/20/16.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

typedef void (^CJActionHandler)(NSDictionary *params);

typedef NS_ENUM(NSUInteger, CJWebViewType) {
    CJWebViewTypeUIWebView              = 0,
    CJWebViewTypeWKWebView
};

@interface CJWebView : UIView<UIWebViewDelegate, WKScriptMessageHandler>
{
    UIWebView                   *_webView;
    WKWebView                   *_wkWebView;
    WKWebViewConfiguration      *_wkConfig;
    
    CJWebViewType               _webViewType;
    
    NSMutableDictionary         *_jsbridgeDict;
}

- (instancetype)initWithWebViewType:(CJWebViewType)webViewType;

// web view method
- (void)loadRequest:(NSURLRequest *)request;

// js-bridge interface

/* 
 used for UIWebView only, default is "fake";
 fake://xxxxx/action?param1=value1&param2=value2...
 */
@property (nonatomic, copy) NSString                    *jsbridgeScheme;

/*
 add handler for Jsbridge action
 */
- (void)addJsbridgeAction:(NSString *)action handler:(CJActionHandler)handler;
- (void)removeJsbridgeAction:(NSString *)action;

@end
