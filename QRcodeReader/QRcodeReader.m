//
//  QRcodeReader.m
//  QRcodeReader
//
//  Created by i_feyuwu on 2016/2/26.
//  Copyright © 2016年 FrankyWu. All rights reserved.
//

#import "QRcodeReader.h"
#import <AVFoundation/AVFoundation.h>

@interface QRcodeReader () <AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UILabel *qrcodeLabel;
@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (weak, nonatomic) IBOutlet UIView *interestView;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (assign, nonatomic) float areaWidth;
@property (assign, nonatomic) float areaXWidth;
@property (assign, nonatomic) float areaYHeight;
@property (strong, nonatomic) CALayer *borderLayer;

@property (assign, nonatomic) BOOL isReading;
@end

@implementation QRcodeReader
@synthesize interestView;
@synthesize captureSession,previewLayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createBorder];
    [self startReading];
}

#pragma mark - Private method implementation
- (BOOL)startReading {
    NSError *error;

    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];

    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }

    // Initialize the captureSession object.
    captureSession = nil;
    captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [captureSession addInput:input];

    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc]init];
    [captureSession addOutput:captureMetadataOutput];

    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];

    CGRect cropRect = self.interestView.frame;
    CGSize containSize = self.scanView.bounds.size;
    CGRect scanRect = CGRectMake(cropRect.origin.y/containSize.height,
                                 cropRect.origin.x/containSize.width,
                                 cropRect.size.height/containSize.height,
                                 cropRect.size.width/containSize.width);
    captureMetadataOutput.rectOfInterest = scanRect;

    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.scanView.layer.bounds;
    [self.scanView.layer addSublayer:previewLayer];

    // Add scan border line
    [self.interestView.layer addSublayer:self.borderLayer];
    [self.borderLayer setNeedsDisplay];

    // Start video capture.
    [captureSession startRunning];

    return YES;
}

- (void)stopReading{
    [captureSession stopRunning];
    captureSession = nil;
    [self.borderLayer removeFromSuperlayer];
    [previewLayer removeFromSuperlayer];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        NSString *qrcodeStr = nil;

        AVMetadataObject *metadata = [metadataObjects objectAtIndex:0];
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            qrcodeStr = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];

            NSLog(@"QR Code: %@", qrcodeStr);
            [self.qrcodeLabel performSelectorOnMainThread:@selector(setText:) withObject:qrcodeStr waitUntilDone:NO];
            [self stopReading];
            [self performSelectorOnMainThread:@selector(backAndReturnData:) withObject:qrcodeStr waitUntilDone:NO];
        }
    }
}

#pragma mark - protocal
- (void)backAndReturnData:(NSString *)qrcodeResult {
    [self stopReading];
    if (self.delegate) {
        [self.delegate backAndReturnData:qrcodeResult];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backWithoutData:(id)sender {
    [self stopReading];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - border line
- (void)createBorder {
    self.areaWidth = 3.0f;
    self.areaXWidth = 30.0f;
    self.areaYHeight = 30.0f;
}

- (CALayer *)borderLayer {
    if (nil == _borderLayer) {
        _borderLayer = [CALayer layer];
        _borderLayer.frame = self.interestView.bounds;
        _borderLayer.delegate = self;
    }
    return _borderLayer;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef) context {
    CGContextSetLineWidth(context, self.areaWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGFloat layerWidth = layer.bounds.size.width;
    CGFloat layerHeight = layer.bounds.size.height;

    UIBezierPath *topLeftBezierPath = [[UIBezierPath alloc] init];

    [topLeftBezierPath moveToPoint:CGPointMake(0.0, 0.0)];
    [topLeftBezierPath addLineToPoint:CGPointMake(self.areaXWidth, 0.0f)];
    [topLeftBezierPath addLineToPoint:CGPointMake(self.areaXWidth, self.areaWidth)];
    [topLeftBezierPath addLineToPoint:CGPointMake(self.areaWidth, self.areaWidth)];
    [topLeftBezierPath addLineToPoint:CGPointMake(self.areaWidth, self.areaYHeight)];
    [topLeftBezierPath addLineToPoint:CGPointMake(0.0f, self.areaYHeight)];
    [topLeftBezierPath closePath];

    CGContextBeginPath(context);
    CGContextAddPath(context, topLeftBezierPath.CGPath);

    UIBezierPath *topRightPath = [[UIBezierPath alloc] init];

    [topRightPath moveToPoint:CGPointMake(layerWidth, 0.0f)];
    [topRightPath addLineToPoint:CGPointMake(layerWidth - self.areaXWidth, 0.0f)];
    [topRightPath addLineToPoint:CGPointMake(layerWidth - self.areaXWidth, self.areaWidth)];
    [topRightPath addLineToPoint:CGPointMake(layerWidth - self.areaWidth, self.areaWidth)];
    [topRightPath addLineToPoint:CGPointMake(layerWidth - self.areaWidth, self.areaYHeight)];
    [topRightPath addLineToPoint:CGPointMake(layerWidth, self.areaYHeight)];
    [topRightPath closePath];
    CGContextAddPath(context, topRightPath.CGPath);

    UIBezierPath *bottomLeftPath = [[UIBezierPath alloc] init];
    [bottomLeftPath moveToPoint:CGPointMake(0.0f, layerHeight)];
    [bottomLeftPath addLineToPoint:CGPointMake(self.areaXWidth, layerHeight)];
    [bottomLeftPath addLineToPoint:CGPointMake(self.areaXWidth, layerHeight - self.areaWidth)];
    [bottomLeftPath addLineToPoint:CGPointMake(self.areaWidth, layerHeight - self.areaWidth)];
    [bottomLeftPath addLineToPoint:CGPointMake(self.areaWidth, layerHeight - self.areaYHeight)];
    [bottomLeftPath addLineToPoint:CGPointMake(0.0f, layerHeight - self.areaYHeight)];
    [bottomLeftPath closePath];
    CGContextAddPath(context, bottomLeftPath.CGPath);

    UIBezierPath *bottomRightPath = [[UIBezierPath alloc] init];
    [bottomRightPath moveToPoint:CGPointMake(layerWidth, layerHeight)];
    [bottomRightPath addLineToPoint:CGPointMake(layerWidth - self.areaXWidth, layerHeight)];
    [bottomRightPath addLineToPoint:CGPointMake(layerWidth - self.areaXWidth, layerHeight - self.areaWidth)];
    [bottomRightPath addLineToPoint:CGPointMake(layerWidth - self.areaWidth, layerHeight - self.areaWidth)];
    [bottomRightPath addLineToPoint:CGPointMake(layerWidth - self.areaWidth, layerHeight - self.areaYHeight)];
    [bottomRightPath addLineToPoint:CGPointMake(layerWidth, layerHeight - self.areaYHeight)];
    [bottomRightPath closePath];
    CGContextAddPath(context, bottomRightPath.CGPath);

    CGContextDrawPath(context, kCGPathStroke);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
