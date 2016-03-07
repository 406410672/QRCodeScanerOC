//
//  QRScanView.m
//  QRCode Scan
//
//  Created by 洪涛 on 16/3/7.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import "QRScanView.h"
#import "Define.h"
@interface QRScanView()
@property (strong,nonatomic) NSArray<UIButton *> *buttonArray;
@property (strong,nonatomic) UIImageView *scanLine;
@property (strong,nonatomic) UILabel *tipsLabel;
@end
@implementation QRScanView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
    }
    return  self;
}
#pragma mark - lazyload
- (NSArray<UIButton *> *)buttonArray{
    if (!_buttonArray) {
        NSLog(@"%@ %s",[NSThread currentThread],__func__);
        NSArray *images = @[@"PictureNormal",@"FlashLightCloseNormal",@"CloseButtonNormal"];
        NSArray *slectedImages = @[@"PictureSelected",@"FlashLightCloseSelected",@"CloseButtonSelected"];
        NSMutableArray *muarr = @[].mutableCopy;
        for (int i = 0; i < images.count; i ++) {
            UIButton *btn = [[UIButton alloc]init];
            btn.tag = 1000 + i;
            [btn addTarget:self action:@selector(btnOnclick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:slectedImages[i]] forState:UIControlStateHighlighted];
            [self addSubview:btn];
            [muarr addObject:btn];
            
        }
        _buttonArray = muarr.copy;
    }
    return  _buttonArray;
}
-(UILabel *)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0,BOTTOM(self.scanFrameView)+15, WIDTH(self), 16)];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.text = @"将二维码/条形码防到框内";
        _tipsLabel.font = [UIFont systemFontOfSize:16];
        _tipsLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        [self addSubview:_tipsLabel];
    }
    return _tipsLabel;
}
-(UIView *)scanFrameView{
    if (!_scanFrameView) {
        _scanFrameView = [[UIImageView alloc]initWithFrame:CGRectMake(MainScreenWidth / 2 - TransparentArea.width / 2,MainScreenHeight / 2 - TransparentArea.height / 2,TransparentArea.width,TransparentArea.height)];
        [_scanFrameView setImage:[UIImage imageNamed:@"ScanFrame"]];
        _scanFrameView.clipsToBounds = YES;
        [self addSubview:_scanFrameView];
    }
    return _scanFrameView;
}
-(UIImageView *)scanLine{
    if (_scanLine == nil) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(15, 15, 226, 226)];
        view.clipsToBounds = YES;
        [self.scanFrameView addSubview:view];
        _scanLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, -137, 226, 137)];
        [_scanLine setImage:[UIImage imageNamed:@"ScanLine"]];
        [view addSubview:_scanLine];
    }
    return _scanLine;
}

#pragma mark - progress Animation
-(void)actionViewAnimationInPreviewLayer{
    [self actionButtonAnimation];
    [self actionScannFrameAnimation];
    [self actionScannLine];
    [self bgColorAnimation];
    [self tipsLabelAnimation];
}
-(void)tipsLabelAnimation{
    for (int i = 0; i <= 6; i ++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05*i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tipsLabel.textColor = [UIColor colorWithWhite:1.0 alpha:i/10.0];
        });
    }
}
- (void)bgColorAnimation{
    [UIView animateKeyframesWithDuration:0.6 delay:0.0 options:0 animations:^{
        [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    } completion:nil];
}
- (void)actionScannLine{
    [UIView animateKeyframesWithDuration:1.0 delay:0.0 options:UIViewKeyframeAnimationOptionRepeat animations:^{
        self.scanLine.frame = CGRectMake(0.0, 230, WIDTH(self.scanLine), HEIGHT(self.scanLine));
    } completion:^(BOOL finished) {
    }];
}
- (void)actionScannFrameAnimation{
    self.scanFrameView.transform = CGAffineTransformMakeScale(0.85, 0.85);
    [UIView animateWithDuration:0.3 animations:^{
        self.scanFrameView.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.scanFrameView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    }];
};

-(void)actionButtonAnimation{
    [self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            obj.frame = CGRectMake(40+ 130 * idx, -48, 48, 48);
        }
    }];
    for (int i = 0; i < self.buttonArray.count; i ++) {
        UIButton *btn = self.buttonArray[i];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1*i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.90 initialSpringVelocity:12.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                btn.frame = CGRectMake(40+ 130 * i, 60, 48, 48);
                [NSThread currentThread];
            } completion:^(BOOL finished) {
                
            }];
        });
    }
}
#pragma mark - event
- (void)btnOnclick:(UIButton *)btn{
    if (!self.onclickBlock) {
        return;
    }
    self.onclickBlock(btn.tag - 1000);
}
#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    
    CGRect middleClearDrawRect = CGRectMake(MainScreenWidth / 2 - TransparentArea.width / 2,
                                      MainScreenHeight / 2 - TransparentArea.height / 2,
                                      TransparentArea.width,TransparentArea.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self addScreenFillRect:ctx rect:MainScreenBounds];
    
    [self addCenterClearRect:ctx rect:middleClearDrawRect];
    
    
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBFillColor(ctx, 40 / 255.0,40 / 255.0,40 / 255.0,0.5);
    CGContextFillRect(ctx, rect);
}

- (void)addCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect {
    CGContextClearRect(ctx, rect);
}

@end
