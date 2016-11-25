//
//  CJAtlasScrollViewController.m
//  Pods
//
//  Created by fminor on 7/7/16.
//
//

#import "CJAtlasScrollViewController.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "NSArray+CJUIKit.h"

#define IMAGE_MARGIN                            2.f
#define PAGE_CONTROL_BOTTOM_MARGIN              20.f
#define kCJAtlasCellIdentifier                  @"kCJAtlasCellIdentifier"

@implementation CJAtlasCollectionCell

- (void)renderCell
{
    if ( _scrollContainer == nil ) {
        _scrollContainer = [[UIScrollView alloc] init];
        [_scrollContainer setFrame:CGRectMake(IMAGE_MARGIN, IMAGE_MARGIN,
                                              self.contentView.bounds.size.width - 2 * IMAGE_MARGIN,
                                              self.contentView.bounds.size.height - 2 * IMAGE_MARGIN)];
        [self.contentView addSubview:_scrollContainer];
    }
    if ( _imageView == nil ) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setFrame:_scrollContainer.bounds];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_scrollContainer addSubview:_imageView];
    }
}

@end

@interface CJAtlasScrollViewController () <UIActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    UICollectionView                        *_collectionContainer;
    UIScrollView                            *_mainContainer;
    UIPageControl                           *_pageControl;
    
    NSMutableArray                          *_imageScrollContainers;
    NSMutableArray                          *_imageViews;
    PHFetchResult                           *_photoFetchResult;
    
    UITapGestureRecognizer                  *_tapDisappearGesture;
    
    UIActionSheet                           *_actionSheet;
    
    CJAtlasType                             _atlasType;
    
    UIImage                                 *_imageToBeSaved;
    
    NSUInteger                              _originIndex;
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
        
        _enableTapDisappearGesture = YES;
        
        _atlasType = CJAtlasTypeUnknown;
        
        _originIndex = INT_MAX;
    }
    return self;
}

- (void)setImageList:(NSArray *)imageList
{
    _imageList = [imageList copy];
    _atlasType = CJAtlasTypeImage;
    [self reload];
}

- (void)setImageUrlList:(NSArray *)imageUrlList
{
    _imageUrlList = [imageUrlList copy];
    _atlasType = CJAtlasTypeUrl;
    [self reload];
}

- (void)setPhotoFetchResult:(PHFetchResult *)photoFetchResult
{
    _photoFetchResult = photoFetchResult;
    _atlasType = CJAtlasTypePhotoLibrary;
}

- (void)setCurrentDisplayIndex:(NSUInteger)currentDisplayIndex
{
    @try {
        [self currentDisplayIndexWillChange];
        _currentDisplayIndex = currentDisplayIndex;
        if ( _collectionContainer ) {
            [_collectionContainer scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentDisplayIndex inSection:0]
                                         atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                 animated:YES];
        }
        [self currentDisplayIndexDidChange];
        if ( _originIndex == INT_MAX ) {
            _originIndex = currentDisplayIndex;
        }
    } @catch (NSException *exception) {
        _currentDisplayIndex = currentDisplayIndex;
    } @finally {
        
    }
}

- (void)setEnableTapDisappearGesture:(BOOL)enableTapDisappearGesture
{
    @try {
        _enableTapDisappearGesture = enableTapDisappearGesture;
        if ( _tapDisappearGesture == nil ) {
            _tapDisappearGesture = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self action:@selector(_actionTapMainContainer:)];
            _tapDisappearGesture.delegate = self;
        }
        if ( _enableTapDisappearGesture ) {
            [self.view addGestureRecognizer:_tapDisappearGesture];
        } else {
            [self.view removeGestureRecognizer:_tapDisappearGesture];
        }
    } @catch (NSException *exception) {
        
    }
}

- (NSUInteger)imageCount
{
    switch ( _atlasType ) {
        case CJAtlasTypeImage: {
            return [_imageList count];
        }
            
        case CJAtlasTypeUrl: {
            return [_imageUrlList count];
        }
            
        case CJAtlasTypePhotoLibrary: {
            return [_photoFetchResult count];
        }
            
        default:
            break;
    }
    return 0;
}

- (void)reload
{
    if ( _collectionContainer != nil ) {
        [_collectionContainer reloadData];
        if ( _currentDisplayIndex >= [self imageCount] ) {
            _currentDisplayIndex = [self imageCount] - 1;
        }
        [_pageControl setNumberOfPages:[self imageCount]];
        [_pageControl setCurrentPage:_currentDisplayIndex];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UICollectionViewFlowLayout *_flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [_flowLayout setItemSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    [_flowLayout setMinimumInteritemSpacing:0];
    [_flowLayout setMinimumLineSpacing:0.f];
    [_flowLayout setSectionInset:UIEdgeInsetsZero];
    [_flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _collectionContainer = [[UICollectionView alloc]
                            initWithFrame:self.view.bounds collectionViewLayout:_flowLayout];
    [_collectionContainer setPagingEnabled:YES];
    [_collectionContainer setBackgroundColor:[UIColor clearColor]];
    [_collectionContainer registerClass:[CJAtlasCollectionCell class]
             forCellWithReuseIdentifier:kCJAtlasCellIdentifier];
    _collectionContainer.delegate = self;
    _collectionContainer.dataSource = self;
    [self.view addSubview:_collectionContainer];
    
    _pageControl = [[UIPageControl alloc] init];;
    CGFloat _page_control_height = 20.f;
    [_pageControl setFrame:CGRectMake(0, self.view.bounds.size.height - PAGE_CONTROL_BOTTOM_MARGIN - _page_control_height,
                                      self.view.bounds.size.width, _page_control_height)];
    [_pageControl setNumberOfPages:[self imageCount]];
    [_pageControl setCurrentPage:_currentDisplayIndex];
    [_pageControl setHidesForSinglePage:YES];
    [self.view addSubview:_pageControl];
    
    [self setEnableTapDisappearGesture:_enableTapDisappearGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if ( _currentDisplayIndex > 0 ) {
        [_collectionContainer scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentDisplayIndex inSection:0]
                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                             animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - collection view delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self imageCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CJAtlasCollectionCell *_cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCJAtlasCellIdentifier forIndexPath:indexPath];
    [_cell renderCell];
    _cell.scrollContainer.delegate = self;
    
    void (^_reframe)(UIImage *) = ^(UIImage *image) {
        CGFloat _ratio_w = image.size.width / _cell.scrollContainer.bounds.size.width;
        CGFloat _ratio_h = image.size.height / _cell.scrollContainer.bounds.size.height;
        CGFloat _maxScale = MAX(_ratio_w, _ratio_h);
        _maxScale = MAX(1, _maxScale);
        [_cell.scrollContainer setMaximumZoomScale:_maxScale];
        [_cell.scrollContainer setMinimumZoomScale:1.0f];
        [_cell.scrollContainer setContentSize:_cell.scrollContainer.bounds.size];
    };
    
    switch ( _atlasType ) {
        case CJAtlasTypeUrl: {
            NSString *_imageUrl = [_imageUrlList objectAtIndex:indexPath.row];
            if ( _originIndex == indexPath.row && _originImage != nil ) {
                if ( ![[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:_imageUrl]] ) {
                    [_cell.imageView setImage:_originImage];
                    _reframe(_originImage);
                }
            }
            
            if ( [[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:_imageUrl]] ) {
                UIImage *_image = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:_imageUrl];
                [_cell.imageView setImage:_image];
                _reframe(_image);
            } else {
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_imageUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    [_cell.imageView setImage:image];
                    _reframe(image);
                }];
            }
            break;
        }
            
        case CJAtlasTypeImage: {
            UIImage *_image = [_imageList objectAtIndex:indexPath.row];
            [_cell.imageView setImage:_image];
            _reframe(_image);
            break;
        }
            
        case CJAtlasTypePhotoLibrary: {
            PHAsset *_asset = [_photoFetchResult objectAtIndex:_photoFetchResult.count - 1 - indexPath.row];
            [[PHImageManager defaultManager] requestImageForAsset:_asset targetSize:_cell.imageView.bounds.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                [_cell.imageView setImage:result];
                _reframe(result);
            }];
            break;
        }
            
        default:
            break;
    }
    
    UITapGestureRecognizer *_doubleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(_actionDoubleClick:)];
    [_doubleTap setNumberOfTapsRequired:2];
    [_cell.scrollContainer addGestureRecognizer:_doubleTap];
    
    UILongPressGestureRecognizer *_longPress = [[UILongPressGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(_actionLongPress:)];
    [_cell.scrollContainer addGestureRecognizer:_longPress];
    
    return _cell;
}

#pragma mark - gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ( [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] ) {
        return YES;
    }
    return NO;
}

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

- (void)_actionScrollToPage:(int)page
{
    [_mainContainer setContentOffset:CGPointMake(_mainContainer.bounds.size.width * page, 0) animated:YES];
    [self currentDisplayIndexWillChange];
    _currentDisplayIndex = page;
    [self currentDisplayIndexDidChange];
}

- (void)_actionDisappear
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    if ( self.navigationController ) {
        [self.navigationController.tabBarController.tabBar setHidden:NO];
        [self.navigationController.navigationBar setHidden:NO];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:NO completion:^{
        }];
    }
}

- (void)_actionTapMainContainer:(UITapGestureRecognizer *)gesture
{
    if ( gesture.view != self.view ) {
        return;
    }
    [self _actionDisappear];
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

- (void)_actionLongPress:(UIGestureRecognizer *)gesture
{
    @try {
        UIScrollView *_scrollView = (UIScrollView *)gesture.view;
        UIImageView *_imageView = (UIImageView *)[_scrollView.subviews firstObjectWhere:^BOOL(UIView *subview) {
            return ([subview isKindOfClass:[UIImageView class]]);
        }];
        _imageToBeSaved = _imageView.image;
        if ( gesture.state == UIGestureRecognizerStateRecognized && _imageToBeSaved ) {
            _actionSheet = [[UIActionSheet alloc]
                            initWithTitle:nil delegate:self
                            cancelButtonTitle:@"取消"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"保存图片", nil];
            [_actionSheet showInView:self.view];
        }
    } @catch (NSException *exception) {
        
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    _imageToBeSaved = nil;
    dispatch_time_t _time = dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC);
    dispatch_after(_time, dispatch_get_main_queue(), ^{
        if ( [_delegate respondsToSelector:@selector(CJAtlasScrollViewController:didFinishSavingImage:withError:contextInfo:)] ) {
            [_delegate CJAtlasScrollViewController:self didFinishSavingImage:image withError:error contextInfo:contextInfo];
        }
    });
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    @try {
        if ( _imageToBeSaved ) {
            UIImageWriteToSavedPhotosAlbum(_imageToBeSaved,
                                           self,
                                           @selector(image:didFinishSavingWithError:contextInfo:),
                                           nil);
        }
    } @catch (NSException *exception) {
        
    }
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
    _realFrame.origin.x = ( containerSize.width - _realFrame.size.width ) / 2;
    _realFrame.origin.y = ( containerSize.height - _realFrame.size.height ) / 2;
    return _realFrame;
}

#pragma mark - subclass method

- (void)currentDisplayIndexWillChange
{
    // Override by subclass of CJAtlasScrollViewController.
}

- (void)currentDisplayIndexDidChange
{
    // Override by subclass of CJAtlasScrollViewController.
}

#pragma mark - scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    NSArray *_subviews = [scrollView subviews];
    for ( UIView *_subview in _subviews ) {
        if ( [_subview isKindOfClass:[UIImageView class]] ) {
            return _subview;
        }
    }
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSArray *_subviews = [scrollView subviews];
    UIImageView *_currentImageView = nil;
    for ( UIView *_subview in _subviews ) {
        if ( [_subview isKindOfClass:[UIImageView class]] ) {
            _currentImageView = _subview;
            break;
        }
    }
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
    if ( scrollView != _collectionContainer ) {
        return;
    }
    
    int _currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    @try {
        [self currentDisplayIndexWillChange];
        [_pageControl setCurrentPage:_currentPage];
        _currentDisplayIndex = _currentPage;
        [self currentDisplayIndexDidChange];
    } @catch (NSException *exception) {
        [_pageControl setCurrentPage:_currentPage];
        _currentDisplayIndex = _currentPage;
    }
}

@end
