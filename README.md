//
// Created by Franky Wu on 2016/2/26
// Copyright © 2015年 All rights reserved.
//

# **使用方法**

1.複製QRcodeReader.h & QRcodeReader.m & QRcodeReader.xib至專案

2.#import "QRcodeReader.h"

3.加入 QRcodeReaderDelegate

```
@interface ViewController ()<QRcodeReaderDelegate>
```

```
- (void)backAndReturnData:(NSString *)barcodeResult {
    self.aString = barcodeResult;
}
```

4.PresentViewController

```
    QRcodeReader *qrcodeview = [[QRcodeReader alloc] init];
    qrcodeview.delegate = self;
    [self presentViewController:qrcodeview animated:YES completion:nil];
```