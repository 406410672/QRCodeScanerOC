//
//  ViewController.m
//  QRCode Scan
//
//  Created by 洪涛 on 16/3/7.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeScanViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)btnAction:(id)sender {
    QRCodeScanViewController *vc = [[QRCodeScanViewController alloc]init];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
