//
//  CJWebView.h
//  Pods
//
//  Created by fminor on 5/20/16.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface CJWebView : UIView
{
    UIWebView                   *_webView;
    WKWebView                   *_wkWebView;
}

@end
