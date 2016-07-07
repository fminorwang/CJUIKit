//
//  CJAtlasScrollViewController.m
//  Pods
//
//  Created by fminor on 7/7/16.
//
//

#import "CJAtlasScrollViewController.h"
#import "UIImageView+WebCache.h"

#define IMAGE_MARGIN                            4.f
#define PAGE_CONTROL_BOTTOM_MARGIN              20.f

@interface CJAtlasScrollViewController ()
{
    UIScrollView                            *_mainContainer;
    UIPageControl                           *_pageControl;
    
    NSMutableArray                          *_imageScrollContainers;
    NSMutableArray                          *_imageViews;
}

@end

@implementation CJAtlasScrollViewController

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        _imageUrlList = nil;
        _currentDisplayIndex = 0;
        
        _imageScrollContainers = [[NSMutableArray alloc] init];
        _imageViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _mainContainer = [[UIScrollView alloc] init];
    [_mainContainer setFrame:self.view.bounds];
    [_mainContainer setDelegate:self];
    [self.view addSubview:_mainContainer];
    
    _pageControl = [[UIPageControl alloc] init];;
    CGFloat _page_control_height = 20.f;
    [_pageControl setFrame:CGRectMake(0, self.view.bounds.size.height - PAGE_CONTROL_BOTTOM_MARGIN - _page_control_height,
                                      self.view.bounds.size.width, _page_control_height)];
    [_pageControl setNumberOfPages:[_imageUrlList count]];
    [_pageControl setCurrentPage:_currentDisplayIndex];
    [self.view addSubview:_pageControl];
    
    CGFloat _imageContainerWidth = _mainContainer.bounds.size.width - 2 * IMAGE_MARGIN;
    CGFloat _imageContainerHeight = _mainContainer.bounds.size.height;
    for ( int i = 0 ; i < [_imageUrlList count] ; i++ ) {
        NSString *_imageUrl = [_imageUrlList objectAtIndex:i];
        UIScrollView *_imageScrollContainer = [[UIScrollView alloc] init];
        [_imageScrollContainer setFrame:CGRectMake(i * _mainContainer.bounds.size.width + IMAGE_MARGIN,
                                                   0,
                                                   _imageContainerWidth,
                                                   _imageContainerHeight)];
        [_imageScrollContainer setDelegate:self];
        [_mainContainer addSubview:_imageScrollContainer];
        
        UIImageView *_imageView = [[UIImageView alloc] init];
        [_imageView setFrame:_imageScrollContainer.bounds];
        [_imageView sd_setImageWithURL:[NSURL URLWithString:_imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            CGRect _realFrame = [self _realFrameFromImageSize:image.size scrollContainerSize:_imageScrollContainer.bounds.size];
            CGFloat _ratio_w = image.size.width / _imageScrollContainer.bounds.size.width;
            CGFloat _ratio_h = image.size.height / _imageScrollContainer.bounds.size.height;
            CGFloat _maxScale = MAX(_ratio_w, _ratio_h);
            _maxScale = MAX(_maxScale, _imageScrollContainer.bounds.size.width / _realFrame.size.width);
            _maxScale = MAX(_maxScale, _imageScrollContainer.bounds.size.height / _realFrame.size.height);
            [_imageScrollContainer setMaximumZoomScale:_maxScale];
            [_imageScrollContainer setMinimumZoomScale:1.0f];
        }];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageScrollContainer addSubview:_imageView];
        
        [_imageScrollContainers addObject:_imageScrollContainer];
        [_imageViews addObject:_imageView];
        
        UITapGestureRecognizer *_doubleTap = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(_actionDoubleClick:)];
        [_doubleTap setNumberOfTapsRequired:2];
        [_imageScrollContainer addGestureRecognizer:_doubleTap];
    }
    [_mainContainer setContentSize:CGSizeMake([_imageUrlList count] * self.view.bounds.size.width,
                                              self.view.bounds.size.height)];
    [_mainContainer setPagingEnabled:YES];
    [_mainContainer setDelegate:self];
    
    UITapGestureRecognizer *_tapMain = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(_actionTapMainContainer:)];
    [_tapMain setDelegate:self];
    [_mainContainer addGestureRecognizer:_tapMain];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ( ![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] || ![otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] ) {
        return NO;
    }
    
    UITapGestureRecognizer *_gestureRecognizer = (UITapGestureRecognizer *)gestureRecognizer;
    UITapGestureRecognizer *_otherGestureRecognizer = (UITapGestureRecognizer *)otherGestureRecognizer;
    
    if ( [_gestureRecognizer numberOfTapsRequired] == 1 ) {
        if ( [_otherGestureRecognizer numberOfTapsRequired] == 2 ) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - user action

- (void)_actionTapMainContainer:(UITapGestureRecognizer *)gesture
{
    if ( gesture.view != _mainContainer ) {
        return;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)_actionDoubleClick:(UITapGestureRecognizer *)gesture
{
    UIScrollView *_scrollContainer = (UIScrollView *)gesture.view;
    if ( ![_scrollContainer isKindOfClass:[UIScrollView class]] ) {
        return;
    }
    
    CGFloat _zoomScale = _scrollContainer.maximumZoomScale;
    if ( _scrollContainer.zoomScale > 1.0f ) {
        _zoomScale = _scrollContainer.minimumZoomScale;
    }
    
    [_scrollContainer setZoomScale:_zoomScale animated:YES];
}

#pragma mark - utilities

- (CGRect)_realFrameFromImageSize:(CGSize)imageSize scrollContainerSize:(CGSize)containerSize
{
    CGRect _realFrame;
    CGFloat _ratio_w = imageSize.width / containerSize.width;
    CGFloat _ratio_h = imageSize.height / containerSize.height;
    if ( _ratio_w > _ratio_h ) {
        _realFrame.size = CGSizeMake(containerSize.width, imageSize.height / _ratio_w);
    } else {
        _realFrame.size = CGSizeMake(imageSize.width / _ratio_h, containerSize.height);
    }
    _realFrame.origin.x = ( containerSize.width - imageSize.width ) / 2;
    _realFrame.origin.y = ( containerSize.height - imageSize.height ) / 2;
    return _realFrame;
}

#pragma mark - scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    NSUInteger _index = [_imageScrollContainers indexOfObject:scrollView];
    return [_imageViews objectAtIndex:_index];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSUInteger _index = [_imageScrollContainers indexOfObject:scrollView];
    UIImageView *_currentImageView = [_imageViews objectAtIndex:_index];
    CGRect _realFrame = [self _realFrameFromImageSize:_currentImageView.image.size
                                  scrollContainerSize:scrollView.bounds.size];
    CGFloat _scale = scrollView.zoomScale;
    CGSize _realSize = CGSizeMake(_realFrame.size.width * _scale, _realFrame.size.height * _scale);
    CGSize _maskSize = CGSizeMake(_currentImageView.bounds.size.width * _scale, _currentImageView.bounds.size.height * _scale);
    
    CGFloat _insetTB = - ( _maskSize.height - scrollView.bounds.size.height ) / 2;
    CGFloat _insetLR = - ( _maskSize.width - scrollView.bounds.size.width ) / 2;
    _insetTB = MAX(_insetTB, - ( _maskSize.height - _realSize.height ) / 2);
    _insetLR = MAX(_insetLR, - ( _maskSize.width - _realSize.width ) / 2 );
    
    [scrollView setContentInset:UIEdgeInsetsMake(_insetTB, _insetLR, _insetTB, _insetLR)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ( scrollView != _mainContainer ) {
        return;
    }
    
    int _currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [_pageControl setCurrentPage:_currentPage];
    _currentDisplayIndex = _currentPage;
}

@end
