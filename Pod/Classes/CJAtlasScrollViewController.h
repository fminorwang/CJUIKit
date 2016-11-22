//
//  CJAtlasScrollViewController.h
//  Pods
//
//  Created by fminor on 7/7/16.
//
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, CJAtlasType) {
    CJAtlasTypeUrl                  = 0,
    CJAtlasTypeImage                = 1,
    CJAtlasTypePhotoLibrary         = 2,
    
    CJAtlasTypeUnknown              = 0xFFFF
};

@protocol CJAtlasScrollViewControllerDelegate;

@interface CJAtlasCollectionCell : UICollectionViewCell

@property (nonatomic, strong)   UIScrollView        *scrollContainer;
@property (nonatomic, strong)   UIImageView         *imageView;

- (void)renderCell;

@end

@interface CJAtlasScrollViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak)     id<CJAtlasScrollViewControllerDelegate>     delegate;

@property (nonatomic, copy)     NSArray                 *imageUrlList;
@property (nonatomic, copy)     NSArray                 *imageList;
@property (nonatomic, strong)   PHFetchResult           *photoFetchResult;

@property (nonatomic, assign)   NSUInteger              currentDisplayIndex;
@property (nonatomic, assign)   CGRect                  atlasOriginLocation;                    // 原始图片相对于整个屏幕的 frame, 在 viewController 切换动画时使用到这个属性
@property (nonatomic, strong)   UIImage                 *originImage;

@property (nonatomic, assign)   BOOL                    enableTapDisappearGesture;              // default = YES
@property (nonatomic, assign)   BOOL                    enableLongPressGesture;                 // default = YES
@property (nonatomic, assign)   BOOL                    enableDoubleTapGesture;                 // default = YES

@property (nonatomic, readonly) NSUInteger              imageCount;

// Override by subclasses
- (void)currentDisplayIndexWillChange;
- (void)currentDisplayIndexDidChange;

/// 重新加载 UI
- (void)reload;

@end

@protocol CJAtlasScrollViewControllerDelegate <NSObject>

@optional
- (void)CJAtlasScrollViewController:(CJAtlasScrollViewController *)controller didFinishSavingImage:(UIImage *)image withError:(NSError *)error contextInfo:(void *)contextInfo;                                                     // 保存图片回调

@end
