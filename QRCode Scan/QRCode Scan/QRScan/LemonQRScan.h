//
//  LemonQRScanManager.h
//  QRCOde
//
//  Created by 洪涛 on 16/3/5.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Define.h"
#import <AVFoundation/AVFoundation.h>
@protocol LemonQRScanDelegate;
@interface LemonQRScan : NSObject
/**
 *  用于返回检测到的二维码数据
 */
@property (weak,nonatomic) id<LemonQRScanDelegate> delegate;
/**
 *  执行此方法前，先执行requestAccessForCamera: 获得设备使用允许
 *
 */
+(instancetype)createQRScanIn:(UIView *)view;

/**
 *  1判断当前是否允许使用设备。
    2请求授权。
 *  @param complied 请求与判断结果利用block返回
 */
+(void)requestAccessForCamera:(void (^)(BOOL enable))complied;

-(void)startRunning;

-(void)stopRunning;
/**
 *  执行此方法。
    进行手电筒的开关操作
 */
-(void)progressTorch;
@end

@interface LemonQRScan (LemonQRScanImageDecode)
+(NSString *)stringValueFrom:(UIImage *)image;
@end

@protocol LemonQRScanDelegate <NSObject>
@required
-(void)qrCodeValueString:(NSString *)valueString;
-(void)buttonOnclickCallBack:(LemonQRScanBtnOnclickEvent)status;
@end
