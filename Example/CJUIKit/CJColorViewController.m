//
//  CJColorViewController.m
//  CJUIKit
//
//  Created by fminor on 20/12/2016.
//  Copyright © 2016 fminor. All rights reserved.
//

#import "CJColorViewController.h"
#import <UIColor+CJUIKit.h>

#define kColorCell                                  @"color_cell"

#define CJ_COLOR_CELL_MARGIN                        10.f
#define CJ_COLOR_CELL_HEIGHT                        140.f

@interface CJColorCell : UICollectionViewCell

@property (nonatomic, strong) UIView                *colorView;
@property (nonatomic, strong) UILabel               *colorLabel;

@end

@implementation CJColorCell

- (UIView *)colorView
{
    if ( _colorView == nil ) {
        [self _init];
    }
    return _colorView;
}

- (UILabel *)colorLabel
{
    if ( _colorLabel == nil ) {
        [self _init];
    }
    return _colorLabel;
}

- (void)_init
{
    if ( _colorView != nil && _colorLabel != nil ) {
        return;
    }
    
    _colorView = [[UIView alloc] init];
    [_colorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    _colorLabel = [[UILabel alloc] init];
    [_colorLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.contentView addSubview:_colorView];
    [self.contentView addSubview:_colorLabel];
    
    NSDictionary *_views = NSDictionaryOfVariableBindings(_colorView, _colorLabel);
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_colorView]|"
                                      options:0 metrics:nil views:_views]];
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|[_colorLabel]|"
                                      options:0 metrics:nil views:_views]];
    [self.contentView addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|[_colorView]-0-[_colorLabel]|"
                                      options:0 metrics:nil views:_views]];
    [self.contentView addConstraint:[NSLayoutConstraint
                                     constraintWithItem:_colorView attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:_colorLabel attribute:NSLayoutAttributeHeight
                                     multiplier:5 constant:0]];
}

@end

@interface CJColorViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView            *_collectionView;
    
    NSArray                     *_colorArray;
}

@end

@implementation CJColorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Color";
    
    CGFloat _width = [UIScreen mainScreen].bounds.size.width - 2 * CJ_COLOR_CELL_MARGIN;
    CGFloat _height = CJ_COLOR_CELL_HEIGHT;
    
    _colorArray = @[@"#ECB1AC", @"#ECB1ACFF",
                    @"#ECB1AC^0.5", @"#ECB1AC^.3",
                    [NSString stringWithFormat:@"w(%.01f) | #ECB1AC^0.0 : #ECB1AC^1.0", _width],
                    [NSString stringWithFormat:@"w(%.01f->0.0) | #ECB1AC^0.0 : #ECB1AC^1.0", _width],
                    [NSString stringWithFormat:@"w(%.01f) | #ECB1AC^0.0 : #ECB1AC^1.0 : #ECB1AC^0.0", _width],
                    [NSString stringWithFormat:@"w(%.01f) | #ECB1AC : #FFFFFF(0.7) : #ECB1AC", _width],
                    [NSString stringWithFormat:@"h(%.01f) | #ECB1AC^0.0 : #ECB1AC^1.0", _height],
                    [NSString stringWithFormat:@"w(%.01f),h(%.01f) | #FFFFFF : #FF0000(0.5) : #ECB1AC", _width, _height],
                    [NSString stringWithFormat:@"w(0.0->%.01f),h(%.01f->0.0) | #FFFFFF : #FF0000(0.5) : #ECB1AC", _width, _height]
                    ];
    
    UICollectionViewFlowLayout *_layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_layout];
    [_collectionView registerClass:[CJColorCell class] forCellWithReuseIdentifier:kColorCell];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _colorArray.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat _margin = CJ_COLOR_CELL_MARGIN;
    return UIEdgeInsetsMake(_margin, _margin, 0, _margin);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat _margin = CJ_COLOR_CELL_MARGIN;
    CGFloat _width = 0.f;
    CGFloat _height = CJ_COLOR_CELL_HEIGHT;
    if ( indexPath.row < 4 ) {
        _width = ( [UIScreen mainScreen].bounds.size.width - 3 * _margin ) / 2;
        return CGSizeMake(_width, _height);
    } else {
        _width = [UIScreen mainScreen].bounds.size.width - 2 * _margin;
        return CGSizeMake(_width, _height);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CJColorCell *_cell = [collectionView dequeueReusableCellWithReuseIdentifier:kColorCell forIndexPath:indexPath];
    NSString *_colorStr = [_colorArray objectAtIndex:indexPath.row];
    [_cell.colorView setBackgroundColor:[UIColor colorWithString:_colorStr]];
    [_cell.colorLabel setText:_colorStr];
    [_cell.colorLabel setAdjustsFontSizeToFitWidth:YES];
    return _cell;
}

@end
