//
//  MainViewController.m
//  MyOpia
//
//  Created by Ray Lin on 9/8/15.
//  Copyright (c) 2015 BananaFoundation. All rights reserved.
//

#import "MainViewController.h"
@import AVFoundation;

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIView *captureView;
@property (weak, nonatomic) IBOutlet UIView *blurView;
@property (nonatomic) AVCaptureDevice *videoCaptureDevice;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer2;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the camera and preview layer and set the layer that will be blurred
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    self.videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoCaptureDevice error:&error];
    if (videoInput) {
        [captureSession addInput:videoInput];
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        self.previewLayer.frame = [[UIScreen mainScreen] bounds];
        self.previewLayer.connection.videoOrientation = [self avOrientationForDeviceOrientation:[UIDevice currentDevice].orientation];
        [self.captureView.layer addSublayer:self.previewLayer];
        self.captureView.frame = [[UIScreen mainScreen] bounds];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [captureSession startRunning];
    }
    else {
        NSLog(@"fuck");
    }
    
    // Add blur layer
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurViewEffect = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = self.captureView.frame;
    blurViewEffect.frame = self.blurView.frame;
    blurViewEffect.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurView.layer.mask = [self getHoleMask];
    [self.blurView addSubview:blurViewEffect];
    
    // Add observer for orientation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    else if( deviceOrientation == UIDeviceOrientationPortrait)
        result = AVCaptureVideoOrientationPortrait;
    else if( deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
        result = AVCaptureVideoOrientationPortraitUpsideDown;
    return result;
}

- (void)changeOrientation {
    if (!UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        self.previewLayer.connection.videoOrientation = [self avOrientationForDeviceOrientation:[UIDevice currentDevice].orientation];
    }
}

- (CAShapeLayer *)getHoleMask {
    CGRect bounds = self.blurView.frame;
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    static CGFloat const kRadius = 200;
    CGRect const circleRect = CGRectMake(CGRectGetMidX(bounds) - kRadius,
                                         CGRectGetMidY(bounds) - kRadius,
                                         2 * kRadius, 2 * kRadius);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [path appendPath:[UIBezierPath bezierPathWithRect:bounds]];
    maskLayer.path = path.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    
    return maskLayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"How the fudge did you get a memory warning from this dumb app");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
