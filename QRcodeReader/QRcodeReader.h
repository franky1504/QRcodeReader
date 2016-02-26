//
//  QRcodeReader.h
//  QRcodeReader
//
//  Created by i_feyuwu on 2016/2/26.
//  Copyright © 2016年 FrankyWu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QRcodeReaderDelegate;

@interface QRcodeReader : UIViewController

@property (nonatomic, strong) id<QRcodeReaderDelegate> delegate;

@end

@protocol QRcodeReaderDelegate <NSObject>

- (void)backAndReturnData:(NSString *) barcodeResult;

@end
