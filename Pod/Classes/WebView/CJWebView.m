//
//  CJWebView.m
//  Pods
//
//  Created by fminor on 5/20/16.
//
//

#import "CJWebView.h"
#import "NSString+CJUIKit.h"

#define BEGIN_USING_UI_WEB_VIEW             if ( _webViewType == CJWebViewTypeUIWebView ) {
#define END_USING_UI_WEB_VIEW               }

#define BEGIN_USING_WK_WEB_VIEW             if ( _webViewType == CJWebViewTypeWKWebView ) {
#define END_USING_WK_WEB_VIEW               }

@interface CJWebView () <UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate>

@end

@implementation CJWebView

- (instancetype)init
{
    CJWebViewType _type;
    if ( [[UIDevice currentDevice].systemVersion compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending ) {
        _type = CJWebViewTypeWKWebView;
    } else {
        _type = CJWebViewTypeUIWebView;
    }
    return [self initWithWebViewType:_type];
}

- (instancetype)initWithWebViewType:(CJWebViewType)webViewType
{
    self = [super init];
    if ( self ) {
        _webViewType = webViewType;
        _jsbridgeScheme = @"fake";
        switch ( _webViewType ) {
            case CJWebViewTypeWKWebView: {
                _wkConfig = [[WKWebViewConfiguration alloc] init];
                _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:_wkConfig];
                [_wkWebView setTranslatesAutoresizingMaskIntoConstraints:NO];
                [_wkWebView setUIDelegate:self];
                [_wkWebView setNavigationDelegate:self];
                [self addSubview:_wkWebView];
                
                NSDictionary *_views = NSDictionaryOfVariableBindings(_wkWebView);
                [self addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_wkWebView]|"
                                      options:0 metrics:nil views:_views]];
                [self addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_wkWebView]|"
                                      options:0 metrics:nil views:_views]];
                break;
            }
                
            case CJWebViewTypeUIWebView: {
                _webView = [[UIWebView alloc] init];
                [_webView setTranslatesAutoresizingMaskIntoConstraints:NO];
                [self addSubview:_webView];
                NSDictionary *_views = NSDictionaryOfVariableBindings(_webView);
                [self addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_webView]|"
                                      options:0 metrics:nil views:_views]];
                [self addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_webView]|"
                                      options:0 metrics:nil views:_views]];
                _webView.delegate = self;
                break;
            }
                
            default:
                break;
        }
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsLayout];
}

#pragma mark - web view methods

- (void)loadRequest:(NSURLRequest *)request
{
    switch ( _webViewType ) {
        case CJWebViewTypeWKWebView: {
            [_wkWebView loadRequest:request];
            break;
        }
            
        case CJWebViewTypeUIWebView:{
            [_webView loadRequest:request];
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)canGoBack
{
    switch ( _webViewType ) {
        case CJWebViewTypeWKWebView: {
            return [_wkWebView canGoBack];
            break;
        }
            
        case CJWebViewTypeUIWebView: {
            return [_webView canGoBack];
            break;
        }
            
        default: {
            return NO;
            break;
        }
    }
}

- (void)goBack
{
    switch ( _webViewType ) {
        case CJWebViewTypeWKWebView: {
            [_wkWebView goBack];
            break;
        }
            
        case CJWebViewTypeUIWebView: {
            [_webView goBack];
            break;
        }
            
        default: {
            return;
            break;
        }
    }
}

#pragma mark - 

- (void)addJsbridgeAction:(NSString *)action handler:(CJActionHandler)handler
{
    if ( [action length] == 0 ) return;
    if ( _jsbridgeDict == nil ) {
        _jsbridgeDict = [[NSMutableDictionary alloc] init];
    }
    [_jsbridgeDict setObject:handler forKey:action];
    
    BEGIN_USING_WK_WEB_VIEW
    [_wkConfig.userContentController addScriptMessageHandler:self name:action];
    END_USING_WK_WEB_VIEW
}

- (void)removeJsbridgeAction:(NSString *)action
{
    if ( [action length] == 0 ) return;
    if ( _jsbridgeDict == nil ) return;
    [_jsbridgeDict removeObjectForKey:action];
    
    BEGIN_USING_WK_WEB_VIEW
    [_wkConfig.userContentController removeScriptMessageHandlerForName:action];
    END_USING_WK_WEB_VIEW
}

#pragma mark - UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ( _jsbridgeDict == nil ) return YES;
    
    NSString *_absoluteString = request.URL.absoluteString;
    if ( ![_absoluteString hasPrefix:_jsbridgeScheme] ) {
        return YES;
    }

    NSArray *_components = [request.URL.path componentsSeparatedByString:@"/"];
    NSArray *_action = [_components lastObject];
    if ( ![_jsbridgeDict.allKeys containsObject:_action] ) {
        return YES;
    }
    
    NSString *_query = request.URL.query;
    NSDictionary *_params = [_query urlQueryParamDict];
    
    CJActionHandler _handler = [_jsbridgeDict objectForKey:_action];
    _handler(_params);
    return NO;
}

#pragma mark - WKWebView script delegate

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSString *_action = message.name;
    if ( ![_jsbridgeDict.allKeys containsObject:_action] ) {
        return;
    }
    
    CJActionHandler _handler = [_jsbridgeDict objectForKey:_action];
    _handler(message.body);
}

@end
