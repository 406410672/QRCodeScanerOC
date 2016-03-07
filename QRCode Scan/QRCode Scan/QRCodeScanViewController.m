//
//  QRCodeScanViewController.m
//  QRCode Scan
//
//  Created by 洪涛 on 16/3/7.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import "QRCodeScanViewController.h"
#import "LemonQRScan.h"
@interface QRCodeScanViewController()<LemonQRScanDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong,nonatomic)LemonQRScan *qrscan;
@end
@implementation QRCodeScanViewController
-(void)viewDidLoad{
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [LemonQRScan requestAccessForCamera:^(BOOL enable) {
            if (enable) {
                self.qrscan = [LemonQRScan createQRScanIn:self.view];
                self.qrscan.delegate = self;

                [self.qrscan startRunning];
            }
        }];
    });

}
-(void)buttonOnclickCallBack:(LemonQRScanBtnOnclickEvent)status{
                    switch (status) {
                        case LemonQRScanBtnOnclickEventPhotoAlbum:{
                            [self presentPhotoVC];
                        }
                            break;
                        case LemonQRScanBtnOnclickEventTorch:{
                            [self.qrscan progressTorch];
                        }
                            break;
                        case LemonQRScanBtnOnclickEventClose:{
                            [self.qrscan stopRunning];
                            [self dismissViewControllerAnimated:YES  completion:nil];
                        }
                            break;
                        default:
                            break;
                    }
}
- (void)presentPhotoVC{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark - result
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0){
    [picker dismissViewControllerAnimated:YES completion:nil];
    if(!image){
        return;
    }
    NSLog(@"扫描结果：%@",[LemonQRScan stringValueFrom:image]);
}
-(void)qrCodeValueString:(NSString *)valueString{
    NSLog(@"扫描结果：%@",valueString);
}
@end
