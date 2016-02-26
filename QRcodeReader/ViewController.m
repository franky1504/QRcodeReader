//
//  ViewController.m
//  QRcodeReader
//
//  Created by i_feyuwu on 2016/2/26.
//  Copyright © 2016年 FrankyWu. All rights reserved.
//

#import "ViewController.h"
#import "QRcodeReader.h"

@interface ViewController ()<QRcodeReaderDelegate>
@property (weak, nonatomic) IBOutlet UILabel *aLabel;
@property (weak, nonatomic) NSString *aString;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.aLabel.text = @"No Data";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (IBAction)gotoQRscan:(id)sender {
    QRcodeReader *qrcodeview = [[QRcodeReader alloc] init];
    qrcodeview.delegate = self;
    [self presentViewController:qrcodeview animated:YES completion:nil];
}

- (void)backAndReturnData:(NSString *)barcodeResult {
    self.aString = barcodeResult;
    self.aLabel.text = self.aString;
}
@end
