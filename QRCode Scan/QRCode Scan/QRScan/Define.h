//
//  Const.h
//  QRCOde
//
//  Created by 洪涛 on 16/3/5.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#ifndef Const_h
#define Const_h
typedef NS_ENUM(NSInteger, LemonQRScanBtnOnclickEvent) {
    LemonQRScanBtnOnclickEventPhotoAlbum,
    LemonQRScanBtnOnclickEventTorch,
    LemonQRScanBtnOnclickEventClose
};

#define KQRScanQueueName  "KQRScanQueueName"
#define TransparentArea CGSizeMake(256.0, 256.0)
#define LEFT(view) CGRectGetMinX(view.frame)
#define MiddleX(view) CGRectGetMidX(view.frame)
#define RIGHT(view) CGRectGetMaxX(view.frame)
#define TOP(view) CGRectGetMinY(view.frame)
#define MiddleY(view) CGRectGetMidY(view.frame)
#define BOTTOM(view) CGRectGetMaxY(view.frame)
#define WIDTH(view) CGRectGetWidth(view.frame)
#define HEIGHT(view) CGRectGetHeight(view.frame)


/*****************************************************MainScreen*****************************************************/
#define MainScreenBounds [UIScreen mainScreen].bounds
#define MainScreenWidth [UIScreen mainScreen].bounds.size.width
#define MainScreenHeight [UIScreen mainScreen].bounds.size.height
#endif /* Const_h */
