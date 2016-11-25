//
//  CJEmotionView.m
//  Pods
//
//  Created by fminor on 9/5/16.
//
//

#import "CJEmotionView.h"
#import "SDWebImageManager.h"

#define ANIMATE_COUNT                       10 // 50
#define ANIMATE_EMOTION_DIAMETER            32.f

typedef NS_ENUM(NSUInteger, CJEmotionCollideType) {
    CJEmotionCollideTypeEmotion                 = 1,
    CJEmotionCollideTypeWall                    = 1 << 1
};

@interface CJEmotionView ()
{
    
}

@end

@implementation CJEmotionView

@synthesize animationType = _animationType;
@synthesize emotionImage = _emotionImage;
@synthesize imageUrlArr = _imageUrlArr;

@synthesize rainMinDelay = _rainMinDelay;
@synthesize rainMaxDelay = _rainMaxDelay;
@synthesize rainMinDuration = _rainMinDuration;
@synthesize rainMaxDuration = _rainMaxDuration;
@synthesize rainTotalImageNumber = _rainTotalImageNumber;
@synthesize rainMinRotateRate = _rainMinRotateRate;
@synthesize rainMaxRotateRate = _rainMaxRotateRate;

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    NSArray *_gestures = [self gestureRecognizers];
    for ( UIGestureRecognizer *_gesture in _gestures ) {
        [self removeGestureRecognizer:_gesture];
    }
    
    if ( userInteractionEnabled ) {
        UITapGestureRecognizer *_tap = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(_actionTapEmotionView:)];
        _tap.delegate = self;
        [self addGestureRecognizer:_tap];
    }
}

- (BOOL)isUserInteractionEnabled
{
    return [super isUserInteractionEnabled];
}

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        [self setUserInteractionEnabled:NO];
        
        _spriteKitEnabled = YES;
        _rainMinDelay = 0;
        _rainMaxDelay = 2;
        _rainMinDuration = 1.5;
        _rainMaxDuration = 3.0;
        _rainMinRotateRate = 0.5;
        _rainMaxRotateRate = 10;
        _rainTotalImageNumber = 20;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"Dealloc emotion view!");
}

- (void)displayInView:(UIView *)view
{
    void (^_display)(void) = ^{
        switch ( _animationType & CJEmotionAnimationTypeMainType ) {
            case CJEmotionAnimationTypeRain: {
                [self setFrame:view.bounds];
                [view addSubview:self];
                UITapGestureRecognizer *_tap = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(_actionTapEmotionView:)];
                _tap.delegate = self;
                [self addGestureRecognizer:_tap];
                [self _displayRainAnimationInView:self];
                break;
            }
                
            case CJEmotionAnimationTypeHuge: {
                [self setFrame:view.bounds];
                [view addSubview:self];
                [self _displayHugeAnimationInView:view];
                break;
            }
                
            case CJEmotionAnimationTypeRow: {
                [self _displayRowAnimationInView:view];
                break;
            }
                
            case CJEmotionAnimationTypeFireworks: {
                [self setFrame:view.bounds];
                [view addSubview:self];
                [self _displayFireworksAnimationForEmotionImage:_emotionImage inView:self];
                break;
            }
                
            default:
                break;
        }
    };
    
    if ( _emotionImage != nil || _emotionImageArr != nil ) {
        _display();
    }
    
    if ( _imageUrlArr != nil ) {
        __block int _downloadedCount = 0;
        for ( NSString *_imageUrl in _imageUrlArr ) {
            if ( [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:_imageUrl]] ) {
                _downloadedCount++;
                continue;
            }
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_imageUrl] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if ( finished ) {
                    _downloadedCount++;
                    if ( _downloadedCount == _imageUrlArr.count ) {
                        _display();
                    }
                }
            }];
        }
        
        if ( _downloadedCount == _imageUrlArr.count ) {
            _display();
        }
    }
}

- (void)_displayFireworksAnimationForEmotionImage:(UIImage *)image inView:(UIView *)view
{
    BOOL _isRotate = ( _animationType & CJEmotionAnimationTypeRotationType ) == CJEmotionAnimationTypeRotate;
    
    CALayer *_startLayer = [CALayer layer];
    _startLayer.contents = (id)image.CGImage;
    [view.layer addSublayer:_startLayer];
    [_startLayer setFrame:CGRectMake(0, -100, ANIMATE_EMOTION_DIAMETER, ANIMATE_EMOTION_DIAMETER)];
    
    NSMutableArray *_animationList = [[NSMutableArray alloc] init];
    
    // animation begin
    int _start_x = arc4random() % (int)view.bounds.size.width;
    
    // 第一个图
    CAKeyframeAnimation *_startAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    _startAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.1 :1.0 :0.8 :1.0];
    CGMutablePathRef _thePath = CGPathCreateMutable();
    CGPathMoveToPoint(_thePath, NULL, _start_x, view.bounds.size.height + ANIMATE_EMOTION_DIAMETER);
    CGPoint _centerPoint = CGPointMake(0.5 * view.bounds.size.width, 0.3 * view.bounds.size.height);
    CGPathAddLineToPoint(_thePath, NULL, _centerPoint.x, _centerPoint.y);
    _startAnimation.path = _thePath;
    _startAnimation.duration = 3.0f;
    [_animationList addObject:_startAnimation];
    
    CABasicAnimation *_sizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    _sizeAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, ANIMATE_EMOTION_DIAMETER * 5, ANIMATE_EMOTION_DIAMETER * 5)];
    _sizeAnimation.duration = _startAnimation.duration;
    [_animationList addObject:_sizeAnimation];
    
    if ( _isRotate ) {
        int _rotateDirection = 1 - 2 * (arc4random() % 2);
        CAKeyframeAnimation *_rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotateAnimation.duration = 3.f;
        _rotateAnimation.values = @[@(0.0), @(_rotateDirection * M_PI * 10)];
        _rotateAnimation.keyTimes = @[@0.0, @1.0];
        _rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [_animationList addObject:_rotateAnimation];
    }
    
    // 烟花爆炸
    int _fireworkCount = 12;
    float _radius = sqrtf(_centerPoint.x * _centerPoint.x +
                          MAX(view.bounds.size.height - _centerPoint.y, _centerPoint.y) * MAX(view.bounds.size.height - _centerPoint.y, _centerPoint.y));
    for ( int i = 0 ; i < _fireworkCount ; i++ ) {
        NSMutableArray *_burstAnimationList = [[NSMutableArray alloc] init];
        
        CALayer *_burstLayer = [CALayer layer];
        _burstLayer.contents = (id)image.CGImage;
        [view.layer addSublayer:_burstLayer];
        [_burstLayer setFrame:CGRectMake(0, -100, ANIMATE_EMOTION_DIAMETER, ANIMATE_EMOTION_DIAMETER)];
        
        CGFloat _burstDuration = 2.f + ( arc4random() % 200 ) / 1000.f;
        
        // 路径动画
        CAKeyframeAnimation *_burstAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        [_burstAnimation setCalculationMode:kCAAnimationLinear];
        CGMutablePathRef _burstPath = CGPathCreateMutable();
        CGPathMoveToPoint(_burstPath, NULL, _centerPoint.x, _centerPoint.y);
        
        float _angle_1 = 2 * M_PI * i / _fireworkCount + M_PI / _fireworkCount;
        float _x_1 = _centerPoint.x + _radius / 2 * cosf(_angle_1);
        float _y_1 = _centerPoint.y - _radius / 2 * sinf(_angle_1);
        
        float _angle_2 = 2 * M_PI * i / _fireworkCount + M_PI / _fireworkCount + (( i < 3 || i > 8 ) ? (-0.05) : 0.05);
        float _x_2 = _centerPoint.x + _radius * 3 / 4 * cosf(_angle_2);
        float _y_2 = _centerPoint.y - _radius * 3 / 4 * sinf(_angle_2);
        
        float _angle_end = 2 * M_PI * i / _fireworkCount + M_PI / _fireworkCount + (( i < 3 || i > 8 ) ? (-0.1) : 0.1);
        float _x_end = _centerPoint.x + _radius * cosf(_angle_end);
        float _y_end = _centerPoint.y - _radius * sinf(_angle_end);
        
        CGPathAddCurveToPoint(_burstPath, NULL, _x_1, _y_1, _x_2, _y_2, _x_end, _y_end);
        _burstAnimation.path = _burstPath;
        _burstAnimation.duration = _burstDuration;
        [_burstAnimationList addObject:_burstAnimation];
        
        // 旋转动画
        if ( _isRotate ) {
            int _burstRotateDirection = 1 - 2 * (arc4random() % 2);
            CABasicAnimation *_burstRotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            _burstRotateAnimation.duration = _burstDuration;
            _burstRotateAnimation.repeatCount = 100;
            CGFloat _fromAngle = arc4random() % 100 / 10.f;
            _burstRotateAnimation.fromValue = [NSNumber numberWithFloat:_fromAngle];
            _burstRotateAnimation.byValue = [NSNumber numberWithFloat:_burstRotateDirection * 4 * M_PI];
            [_burstAnimationList addObject:_burstRotateAnimation];
        }
        
        // 时间
        CAAnimationGroup *_burstAnimationGroup = [CAAnimationGroup animation];
        CFTimeInterval _localLayerTime = [_burstLayer convertTime:CACurrentMediaTime() fromLayer:nil];
        _burstAnimationGroup.beginTime = _localLayerTime + _startAnimation.duration;
        _burstAnimationGroup.duration = _burstDuration;
        _burstAnimationGroup.animations = _burstAnimationList;
        [CATransaction setCompletionBlock:^{
            [_burstLayer removeFromSuperlayer];
        }];
        
        [_burstLayer addAnimation:_burstAnimationGroup forKey:[NSString stringWithFormat:@"burstAnimation+%d", i]];
    }
    
    CAAnimationGroup *_animationGroup = [CAAnimationGroup animation];
    [_animationGroup setAnimations:_animationList];
    CFTimeInterval _localLayerTime = [_startLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    _animationGroup.duration = 8.f;
    _animationGroup.beginTime = _localLayerTime;
    
    [CATransaction setCompletionBlock:^{
        [_startLayer removeFromSuperlayer];
        [self removeFromSuperview];
    }];
    [_startLayer addAnimation:_animationGroup forKey:@"fireworks"];
}

- (void)_displayRainAnimationInView:(UIView *)view
{
    if ( _rainViews == nil  ) {
        _rainViews = [[NSMutableArray alloc] init];
    }
    
    SKView *_skView = [[SKView alloc] init];
    [_skView setBackgroundColor:[UIColor clearColor]];
    [_skView setFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)];
    
    SKScene *_presentScene = [[SKScene alloc] initWithSize:view.bounds.size];
    [_presentScene setBackgroundColor:[UIColor clearColor]];
    [_presentScene.physicsWorld setGravity:CGVectorMake(0, 0)];
    [_skView presentScene:_presentScene];
    [view addSubview:_skView];
    
    for ( int i = 0; i < _rainTotalImageNumber ; i++ ) {
        // 确定图片
        UIImage *_image = nil;
        int _imageIndex = 0;
        if ( _emotionImage != nil ) {
            _image = _emotionImage;
        } else if ( _emotionImageArr != nil ) {
            _imageIndex = arc4random() % _emotionImageArr.count;
            _image = [_emotionImageArr objectAtIndex:_imageIndex];
        } else {
            _imageIndex = arc4random() % _imageUrlArr.count;
            NSString *_imageUrl = [_imageUrlArr objectAtIndex:_imageIndex];
            NSString *_imageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:_imageUrl]];
            _image = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:_imageKey];
        }
        
        // 确定各参数
        int _start_x = arc4random() % (int)view.bounds.size.width;
        int _end_x = arc4random() % (int)view.bounds.size.width;
        CGFloat _duration = _rainMinDuration + ( arc4random() % (int)(1000 * (_rainMaxDuration - _rainMinDuration))) / 1000.f;
        CGFloat _delay_time = _rainMinDelay + ( arc4random() % (int)(1000 * (_rainMaxDelay - _rainMinDelay))) / 1000.f;
        CGFloat _bound_ratio = 1 + ( arc4random() % 1000 / 4000.f - 1 / 8.f );
        int _rotateDirection = 1 - 2 * (arc4random() % 2);
        CGFloat _angularVelocity = _rotateDirection * (_rainMinRotateRate + ( arc4random() % (int)( 1000 * ( _rainMaxRotateRate - _rainMinRotateRate )) ) / 1000.f);
        
        if ( self.userInteractionEnabled ) {
            UIButton *_emotionView = [[UIButton alloc] init];
            [_emotionView setTag:_imageIndex];
            [view addSubview:_emotionView];
            [_rainViews addObject:_emotionView];
            
            [_emotionView setFrame:CGRectMake(-100,
                                              0,
                                              _image.size.width * _bound_ratio / 2,
                                              _image.size.height * _bound_ratio / 2)];
            [_emotionView setImage:_image forState:UIControlStateNormal];
            [_emotionView addTarget:self action:@selector(_actionTapEmotionView:)
                   forControlEvents:UIControlEventTouchUpInside];
            
            CGFloat _a = _emotionView.bounds.size.width;
            CGFloat _b = _emotionView.bounds.size.height;
            CGFloat _r = sqrtf(_a * _a + _b * _b);
            [_emotionView setCenter:CGPointMake(_start_x, -_r)];
            [UIView animateWithDuration:_duration delay:_delay_time options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [_emotionView setCenter:CGPointMake(_end_x, view.bounds.size.height + _r)];
            } completion:^(BOOL finished) {
                [_emotionView removeFromSuperview];
                [_rainViews removeObject:_emotionView];
            }];
            
            // 旋转动画
            if (( _animationType & CJEmotionAnimationTypeRotationType ) == CJEmotionAnimationTypeRotate ) {
                CGFloat _minRotateDuration = 1.f / _rainMaxRotateRate;
                CGFloat _maxRotateDuration = 1.f / _rainMinRotateRate;
                CGFloat _rotateDuration = _minRotateDuration + ( arc4random() % (int)( 1000 * ( _maxRotateDuration - _minRotateDuration )) ) / 1000.f;
                int _rotateDirection = 1 - 2 * (arc4random() % 2);
                CABasicAnimation *_rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                _rotateAnimation.duration = _rotateDuration;
                _rotateAnimation.repeatCount = 100;
                _rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
                _rotateAnimation.toValue = [NSNumber numberWithFloat:_rotateDirection * 2 * M_PI];
                [_emotionView.layer addAnimation:_rotateAnimation forKey:@"rotate"];
            }
        } else {
            if ( self.spriteKitEnabled ) {
                CGFloat _diameter = ANIMATE_EMOTION_DIAMETER * _bound_ratio;
                
                SKSpriteNode *_sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:_image] size:CGSizeMake(_diameter + 2, _diameter + 2)];
//                _sprite.alpha = 0.f;
                
                SKCropNode* _cropNode = [SKCropNode node];
                SKShapeNode* _mask = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(_diameter, _diameter) cornerRadius:_diameter / 2];
                [_mask setFillColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:1]];
                [_mask setStrokeColor:[SKColor clearColor]];
                [_mask setLineWidth:0.f];
                [_cropNode setMaskNode:_mask];
                [_cropNode addChild:_sprite];
                [_cropNode setAlpha:0.f];
                [_cropNode setPosition:CGPointMake(_start_x, _presentScene.size.height)];
                
                _cropNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_diameter / 2];
                _cropNode.physicsBody.angularVelocity = _angularVelocity;
                _cropNode.physicsBody.categoryBitMask = CJEmotionCollideTypeEmotion;
                _cropNode.physicsBody.contactTestBitMask = 0;
                _cropNode.physicsBody.collisionBitMask = 0;
                SKAction *_delayAction = [SKAction waitForDuration:_delay_time];
                SKAction *_appearAction = [SKAction fadeAlphaTo:1 duration:0];
                SKAction *_moveAction = [SKAction customActionWithDuration:0 actionBlock:^(SKNode * _Nonnull node, CGFloat elapsedTime) {
                    [node.physicsBody setVelocity:CGVectorMake((_end_x - _start_x) / _duration,
                                                               -_presentScene.size.height / _duration)];
                }];
                SKAction *_sequence = [SKAction sequence:@[_delayAction, _appearAction, _moveAction]];
                [_cropNode runAction:_sequence];
                [_presentScene addChild:_cropNode];
            } else {
                CALayer *_emotionLayer = [CALayer layer];
                _emotionLayer.contents = (id)_image.CGImage;
                [_emotionLayer setMasksToBounds:YES];
                [view.layer addSublayer:_emotionLayer];
                
                [_emotionLayer setFrame:CGRectMake(-100,
                                                   0,
                                                   ANIMATE_EMOTION_DIAMETER * _bound_ratio,
                                                   ANIMATE_EMOTION_DIAMETER * _bound_ratio)];
                _emotionLayer.cornerRadius = ANIMATE_EMOTION_DIAMETER * _bound_ratio / 2;
                NSMutableArray *_animationGroup = [[NSMutableArray alloc] init];
                
                // animation begin
                // 位置动画
                CAKeyframeAnimation *_positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
                [_positionAnimation setCalculationMode:kCAAnimationLinear];
                CGMutablePathRef _thePath = CGPathCreateMutable();
                CGPathMoveToPoint(_thePath, NULL, _start_x, 0);
                CGPathAddLineToPoint(_thePath, NULL, _end_x, view.bounds.size.height);
                _positionAnimation.path = _thePath;
                _positionAnimation.duration = _duration;
                [_animationGroup addObject:_positionAnimation];
                
                // 旋转动画
                if (( _animationType & CJEmotionAnimationTypeRotationType ) == CJEmotionAnimationTypeRotate ) {
                    CGFloat _minRotateDuration = 1.f / _rainMaxRotateRate;
                    CGFloat _maxRotateDuration = 1.f / _rainMinRotateRate;
                    CGFloat _rotateDuration = _minRotateDuration + ( arc4random() % (int)( 1000 * ( _maxRotateDuration - _minRotateDuration )) ) / 1000.f;
                    int _rotateDirection = 1 - 2 * (arc4random() % 2);
                    CABasicAnimation *_rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                    _rotateAnimation.duration = _rotateDuration;
                    _rotateAnimation.repeatCount = 100;
                    _rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
                    _rotateAnimation.toValue = [NSNumber numberWithFloat:_rotateDirection * 2 * M_PI];
                    [_animationGroup addObject:_rotateAnimation];
                }
                
                // 组合动画
                CAAnimationGroup *_groupAnimation = [CAAnimationGroup animation];
                CFTimeInterval _localLayerTime = [_emotionLayer convertTime:CACurrentMediaTime() fromLayer:nil];
                _groupAnimation.duration = _duration + _delay_time;
                _groupAnimation.beginTime = _localLayerTime + _delay_time;
                _groupAnimation.animations = _animationGroup;
                
                [CATransaction setCompletionBlock:^{
                    [_emotionLayer removeFromSuperlayer];
                }];
                
                [_emotionLayer addAnimation:_groupAnimation forKey:@"combineAnimate"];
            }
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((_rainMaxDelay + _rainMaxDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

- (void)_displayRowAnimationInView:(UIView *)view
{
    @try {
        UIImage *_image = [_emotionImageArr objectAtIndex:0];
        
        CALayer *_emotionLayer = [CALayer layer];
        _emotionLayer.contents = (id)_image.CGImage;
        [view.layer addSublayer:_emotionLayer];
        
        [_emotionLayer setFrame:CGRectMake(-1000, -1000,
                                           view.bounds.size.width / 2,
                                           view.bounds.size.width / 2)];
        NSMutableArray *_animationGroup = [[NSMutableArray alloc] init];
        
        // 位置动画
        CGRect _view_bounds = view.bounds;
        CGFloat (^_random)(CGFloat, CGFloat) = ^(CGFloat min, CGFloat max) {
            return arc4random() % (int)(max - min) + min;
        };
        CGFloat (^_random_y)(void) = ^{
            return _random(_view_bounds.size.height * 0.3, _view_bounds.size.height * 0.7);
        };
        
        CGFloat _start_x = -_emotionLayer.bounds.size.width / 2;
        CGFloat _y = _random_y();
        CGFloat _end_x = _view_bounds.size.width + _emotionLayer.bounds.size.width / 2;
        
        CAKeyframeAnimation *_animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        CGMutablePathRef _thePath = CGPathCreateMutable();
        CGPathMoveToPoint(_thePath, NULL, _start_x, _y);
        CGPathAddLineToPoint(_thePath, NULL, _end_x, _y);
        _animation.path = _thePath;
        _animation.duration = 5.f;
        
        [CATransaction setCompletionBlock:^{
            [_emotionLayer removeFromSuperlayer];
            [self removeFromSuperview];
        }];
        [_animationGroup addObject:_animation];
        
        // 旋转动画
        if (( _animationType & CJEmotionAnimationTypeRotationType ) == CJEmotionAnimationTypeRotate ) {
            CGFloat _rotateDuration = 0.1 + ( arc4random() % 2000 ) / 1000.f;
            int _rotateDirection = 1 - 2 * (arc4random() % 2);
            CABasicAnimation *_rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            _rotateAnimation.duration = _rotateDuration;
            _rotateAnimation.repeatCount = INT32_MAX;
            _rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
            _rotateAnimation.toValue = [NSNumber numberWithFloat:_rotateDirection * 2 * M_PI];
            [_animationGroup addObject:_rotateAnimation];
        }
        
        // 组合动画
        CAAnimationGroup *_groupAnimation = [CAAnimationGroup animation];
        CFTimeInterval _localLayerTime = [_emotionLayer convertTime:CACurrentMediaTime() fromLayer:nil];
        _groupAnimation.duration = 5.f;
        _groupAnimation.beginTime = _localLayerTime;
        _groupAnimation.animations = _animationGroup;
        
        [_emotionLayer addAnimation:_groupAnimation forKey:@"rowAnimation"];
    } @catch (NSException *exception) {
        
    }
}

- (void)_displayHugeAnimationInView:(UIView *)view
{
    @try {
        UIImage *_image = [_emotionImageArr objectAtIndex:0];
        [self _displayHugeAnimationForEmotionImage:_image inView:view];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

- (void)_displayHugeAnimationForEmotionImage:(UIImage *)image inView:(UIView *)view
{
    CALayer *_emotionLayer = [CALayer layer];
    _emotionLayer.contents = (id)image.CGImage;
    [view.layer addSublayer:_emotionLayer];
    
    [_emotionLayer setFrame:CGRectMake(-1000, -1000,
                                       view.bounds.size.width / 2,
                                       view.bounds.size.width / 2)];
    NSMutableArray *_animationGroup = [[NSMutableArray alloc] init];
    
    // 位置动画
    CGRect _view_bounds = view.bounds;
    CGFloat (^_random)(CGFloat, CGFloat) = ^(CGFloat min, CGFloat max) {
        return arc4random() % (int)(max - min) + min;
    };
    CGFloat (^_random_x)(void) = ^{
        return _random(_view_bounds.size.width * 0.3, _view_bounds.size.width * 0.7);
    };
    
    CGFloat (^_random_px)(void) = ^{
        return _random(_view_bounds.size.width * 0, _view_bounds.size.width * 1);
    };
    
    CGFloat _start_x = _random_x();
    CGFloat _x1 = _random_px();
    CGFloat _x2 = _random_px();
    CGFloat _end_x = _random_x();
    
    CAKeyframeAnimation *_animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef _thePath = CGPathCreateMutable();
    CGPathMoveToPoint(_thePath, NULL, _start_x, - 0.5 * _emotionLayer.bounds.size.height);
    CGPathAddCurveToPoint(_thePath, NULL,
                          _x1, (view.bounds.size.height + _emotionLayer.bounds.size.height ) / 3 - 0.5 * _emotionLayer.bounds.size.height,
                          _x2, (view.bounds.size.height + _emotionLayer.bounds.size.height ) * 2 / 3 - 0.5 * _emotionLayer.bounds.size.height,
                          _end_x, ( view.bounds.size.height + _emotionLayer.bounds.size.height ) * 3 / 3 - 0.5 * _emotionLayer.bounds.size.height);
    _animation.path = _thePath;
    _animation.duration = 8.f;
    
    [CATransaction setCompletionBlock:^{
        [_emotionLayer removeFromSuperlayer];
        [self removeFromSuperview];
    }];
    [_animationGroup addObject:_animation];
    
    // 旋转动画
    if (( _animationType & CJEmotionAnimationTypeRotationType ) == CJEmotionAnimationTypeRotate ) {
        CGFloat _rotateDuration = 0.1 + ( arc4random() % 2000 ) / 1000.f;
        int _rotateDirection = 1 - 2 * (arc4random() % 2);
        CABasicAnimation *_rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotateAnimation.duration = _rotateDuration;
        _rotateAnimation.repeatCount = INT32_MAX;
        _rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        _rotateAnimation.toValue = [NSNumber numberWithFloat:_rotateDirection * 2 * M_PI];
        [_animationGroup addObject:_rotateAnimation];
    }
    
    // 组合动画
    CAAnimationGroup *_groupAnimation = [CAAnimationGroup animation];
    CFTimeInterval _localLayerTime = [_emotionLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    _groupAnimation.duration = 8.f;
    _groupAnimation.beginTime = _localLayerTime;
    _groupAnimation.animations = _animationGroup;
    
    [_emotionLayer addAnimation:_groupAnimation forKey:@"hugeAnimation"];
}

- (void)_actionTapEmotionView:(UIGestureRecognizer *)gesture
{
    NSArray *_tempArr = [NSArray arrayWithArray:_rainViews];
    for ( UIView *_animateView in _tempArr ) {
        CALayer *_pLayer = _animateView.layer.presentationLayer;
        if ( [_pLayer hitTest:[gesture locationInView:self]] ) {
            if ( [self.delegate respondsToSelector:@selector(userDidClickEmotionView:imageIndex:)] ) {
                [self.delegate userDidClickEmotionView:_animateView imageIndex:(int)(_animateView.tag)];
            }
            return;
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSArray *_tempArr = [NSArray arrayWithArray:_rainViews];
    for ( UIView *_animateView in _tempArr ) {
        CALayer *_pLayer = _animateView.layer.presentationLayer;
        if ( [_pLayer hitTest:point]) {
            return self;
        }
    }
    return nil;
}

@end

