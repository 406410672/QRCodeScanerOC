//
//  LemonQRScanManager.m
//  QRCOde
//
//  Created by 洪涛 on 16/3/5.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import "LemonQRScan.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXBinaryBitmap.h"
#import "ZXDecodeHints.h"
#import "ZXHybridBinarizer.h"
#import "ZXMultiFormatReader.h"
#import "ZXResult.h"
#import "Define.h"
#import "QRScanView.h"
@interface LemonQRScan ()<AVCaptureMetadataOutputObjectsDelegate>
@property (strong,nonatomic)UIView *view;
@property (nonatomic,strong)dispatch_queue_t sessionQueue;
//avfoundation
@property (strong,nonatomic) AVCaptureDevice *device;
@property (strong,nonatomic) AVCaptureSession *session;
@property (strong,nonatomic) AVCaptureDeviceInput *deviceInput;
@property (strong,nonatomic) AVCaptureMetadataOutput *metaDataOutput;
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong,nonatomic)QRScanView *scanView;
@end
@implementation LemonQRScan

#pragma mark - lazyload
-(dispatch_queue_t)sessionQueue{
    if (!_sessionQueue) {
        
        //为了更好的让metaDataDelegate更快的获取并且不丢弃数据，设置一个串行队列
        _sessionQueue = dispatch_queue_create(KQRScanQueueName, DISPATCH_QUEUE_SERIAL);
    }
    return _sessionQueue;
}
-(QRScanView *)scanView{
    if (!_scanView) {
        _scanView = [[QRScanView alloc]initWithFrame:self.view.bounds];
        __weak __typeof(self) weakSelf = self;
        [_scanView setOnclickBlock:^(LemonQRScanBtnOnclickEvent status) {
            [weakSelf buttonOnclickCallBack:status];
        }];

        [self.view addSubview:_scanView];
    }
    return _scanView;
}

#pragma mark - class method
+(instancetype)createQRScanIn:(UIView *)view{
    
    LemonQRScan *qrScan = [[self alloc]init];
    qrScan.view = view;
    qrScan.session = [[AVCaptureSession alloc]init];
    qrScan.session.sessionPreset = AVCaptureSessionPreset1280x720;
    
    //获取摄像头
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (device.position == AVCaptureDevicePositionBack) {
            qrScan.device = device;
        }
    }
    qrScan.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:qrScan.device error:nil];
    ![qrScan.session canAddInput:qrScan.deviceInput]?:[qrScan.session addInput:qrScan.deviceInput];
    //设置摄像头输出流
    qrScan.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:qrScan.session];
    qrScan.previewLayer.frame = view.bounds;
    [view.layer addSublayer:qrScan.previewLayer];
    
    //progress QRCode 对象
    qrScan.metaDataOutput = [[AVCaptureMetadataOutput alloc]init];
    [qrScan.metaDataOutput setMetadataObjectsDelegate:qrScan queue:qrScan.sessionQueue];
    ![qrScan.session canAddOutput:qrScan.metaDataOutput]?:[qrScan.session addOutput:qrScan.metaDataOutput];
    ![qrScan.metaDataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]? :[qrScan.metaDataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    return qrScan;
}

+(void)requestAccessForCamera:(void (^)(BOOL enable))complied{
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                complied(granted);
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            complied(YES);
            break;
        }
        default:
            complied(NO);
            break;
    }

}
-(void)startRunning{
    dispatch_async(self.sessionQueue, ^{
        [self.session startRunning];
    });
    [self.scanView actionViewAnimationInPreviewLayer];
}
-(void)stopRunning{
    
    dispatch_async(self.sessionQueue, ^{
        [self.session stopRunning];
    });
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count == 0) {
        return;
    }
    
    AVMetadataMachineReadableCodeObject *object = metadataObjects.firstObject;
    CGRect qrCodeRect = [self.previewLayer  rectForMetadataOutputRectOfInterest:object.bounds];
    
    if (CGRectContainsRect(self.scanView.scanFrameView.frame, qrCodeRect)) {
        NSString * stringValue = object.stringValue;
        
        if ([self.delegate respondsToSelector:@selector(qrCodeValueString:)]) {
            [self.delegate performSelector:@selector(qrCodeValueString:) withObject:stringValue];
        }
    }
}
#pragma mark - progress Torch
-(void)progressTorch{
    if (!self.device.torchActive) {
        if (![self.device isTorchModeSupported:AVCaptureTorchModeOn] ) {
            return;
        }
        [self lockDevice:^{
            [self.device setTorchModeOnWithLevel:0.01 error:nil];
            [self.device setTorchMode:AVCaptureTorchModeOn];
        }];
    }else{
        if (![self.device isTorchModeSupported:AVCaptureTorchModeOff] ) {
            return;
        }
        [self lockDevice:^{
            [self.device setTorchMode:AVCaptureTorchModeOff];
        }];
    }
}

- (void)lockDevice:(dispatch_block_t)block{
    if ([self.device lockForConfiguration:nil]) {
        block();
    }
    [self.device unlockForConfiguration];
}
#pragma mark - event 
- (void)buttonOnclickCallBack:(LemonQRScanBtnOnclickEvent)status{
    if ([self.delegate respondsToSelector:@selector(buttonOnclickCallBack:)]) {
        [self.delegate buttonOnclickCallBack:status];
    }
}
@end

@implementation LemonQRScan (LemonQRScanImageDecode)
+(NSString *)stringValueFrom:(UIImage *)image{
    
    if (!image){
        return nil;
    }
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc]initWithCGImage:image.CGImage];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    NSError *error = nil;
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap hints:hints error:&error];
    if (!result) {
        return @"请检查图片是不是二维码";
    }
    return result.text;
}
@end