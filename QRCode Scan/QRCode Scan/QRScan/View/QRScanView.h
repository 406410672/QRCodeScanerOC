//
//  QRScanView.h
//  QRCode Scan
//
//  Created by 洪涛 on 16/3/7.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"
@interface QRScanView : UIView
@property (strong,nonatomic) UIImageView *scanFrameView;

@property (copy,nonatomic) void (^onclickBlock) (LemonQRScanBtnOnclickEvent status);
-(void)actionViewAnimationInPreviewLayer;
@end
