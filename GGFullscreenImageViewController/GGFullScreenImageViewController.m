//
//  GGFullscreenImageViewController.m
//  TFM
//
//  Created by John Wu on 6/5/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import "GGFullscreenImageViewController.h"
#import <QuartzCore/QuartzCore.h>

static const double kAnimationDuration = 0.3;

static inline GGOrientation convertOrientation(UIInterfaceOrientation orientation) {
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return GGOrientationPortrait;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return GGOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return GGOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return GGOrientationLandscapeRight;
            break;
        default:
            break;
    }
}

static inline NSInteger RadianDifference(UIInterfaceOrientation from, UIInterfaceOrientation to) {
    GGOrientation gg_from = convertOrientation(from);
    GGOrientation gg_to = convertOrientation(to);
    return gg_from-gg_to;
}

@interface GGFullscreenImageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) UIInterfaceOrientation fromOrientation;
@property (nonatomic, assign) UIInterfaceOrientation toOrientation;

- (void) onDismiss;

@end

@implementation GGFullscreenImageViewController

- (id) init {
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.supportedOrientations = UIInterfaceOrientationMaskAll;
    }
    return self;
}

#pragma mark - View Life Cycle

- (void) loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor blackColor];

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 2;
    self.scrollView.autoresizingMask = self.view.autoresizingMask;
    [self.view addSubview:self.scrollView];
    
    self.containerView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.containerView.autoresizingMask = self.view.autoresizingMask;
    [self.scrollView addSubview:self.containerView];

    self.imageView = [[UIImageView alloc] initWithFrame:self.containerView.bounds];
    self.imageView.autoresizingMask = self.view.autoresizingMask;
    self.imageView.userInteractionEnabled = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDismiss)];
    [self.imageView addGestureRecognizer:tap];;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIApplication *app = [UIApplication sharedApplication];
    UIView *window = [app keyWindow];
    [app setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    // match imageView configuration
    self.imageView.image = self.liftedImageView.image;
    self.imageView.contentMode = self.liftedImageView.contentMode;

    CGRect startFrame = [self.liftedImageView convertRect:self.liftedImageView.bounds toView:window];
    self.imageView.layer.position = CGPointMake(startFrame.origin.x + floorf(startFrame.size.width/2), startFrame.origin.y + floorf(startFrame.size.height/2));
    
    UIInterfaceOrientation orientation = self.presentingViewController.interfaceOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.imageView.layer.bounds = CGRectMake(0, 0, startFrame.size.width, startFrame.size.height);
    } else {
        self.imageView.layer.bounds = CGRectMake(0, 0, startFrame.size.height, startFrame.size.width);
    }
    
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.imageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        self.imageView.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        self.imageView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
    } else {
        self.imageView.layer.transform = CATransform3DIdentity;
    }

    [window addSubview:self.imageView];

    self.fromOrientation = self.presentingViewController.interfaceOrientation;
    self.toOrientation = self.interfaceOrientation;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIApplication *app = [UIApplication sharedApplication];
    UIView *window = [app keyWindow];
    [app setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    CGRect endFrame = [self.containerView convertRect:self.containerView.bounds toView:window];

    CABasicAnimation *center = [CABasicAnimation animationWithKeyPath:@"position"];
    center.fromValue = [NSValue valueWithCGPoint:self.imageView.layer.position];
    center.toValue = [NSValue valueWithCGPoint:CGPointMake(floorf(endFrame.size.width/2),floorf(endFrame.size.height/2))];
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"bounds"];
    scale.fromValue = [NSValue valueWithCGRect:self.imageView.layer.bounds];

    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotate.fromValue = [NSValue valueWithCATransform3D:self.imageView.layer.transform];

    UIInterfaceOrientation from = self.fromOrientation;
    UIInterfaceOrientation to = self.toOrientation;

    if (UIInterfaceOrientationIsPortrait(to)) {
        scale.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, endFrame.size.width, endFrame.size.height)];
    } else {
        scale.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, endFrame.size.height, endFrame.size.width)];
    }

    NSInteger factor = RadianDifference(from, to);
    rotate.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.imageView.layer.transform, factor*M_PI_2, 0, 0, 1)];

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = kAnimationDuration;
    group.delegate = self;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];    
    group.animations = @[scale,rotate,center];
    [group setValue:@"expand" forKey:@"type"];

    self.imageView.layer.position = [center.toValue CGPointValue];
    self.imageView.layer.bounds = [scale.toValue CGRectValue];
    self.imageView.layer.transform = [rotate.toValue CATransform3DValue];
    [self.imageView.layer addAnimation:group forKey:nil];

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = [app keyWindow];
    [app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    CGRect startFrame = [self.containerView convertRect:self.imageView.frame toView:window];
    self.imageView.layer.position = CGPointMake(startFrame.origin.x + floorf(startFrame.size.width/2), startFrame.origin.y + floorf(startFrame.size.height/2));

    UIInterfaceOrientation orientation = self.interfaceOrientation;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.imageView.layer.bounds = CGRectMake(0, 0, startFrame.size.width, startFrame.size.height);
    } else {
        self.imageView.layer.bounds = CGRectMake(0, 0, startFrame.size.height, startFrame.size.width);
    }
    
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.imageView.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        self.imageView.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        self.imageView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
    } else {
        self.imageView.layer.transform = CATransform3DIdentity;
    }

    [window addSubview:self.imageView];

    self.fromOrientation = self.interfaceOrientation;
    self.toOrientation = self.presentingViewController.interfaceOrientation;
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = [app keyWindow];
    
    CGRect endFrame = [self.liftedImageView.superview convertRect:self.liftedImageView.frame toView:window];

    CABasicAnimation *center = [CABasicAnimation animationWithKeyPath:@"position"];
    center.fromValue = [NSValue valueWithCGPoint:self.imageView.layer.position];
    center.toValue = [NSValue valueWithCGPoint:CGPointMake(endFrame.origin.x + floorf(endFrame.size.width/2), endFrame.origin.y + floorf(endFrame.size.height/2))];
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"bounds"];
    scale.fromValue = [NSValue valueWithCGRect:self.imageView.layer.bounds];
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotate.fromValue = [NSValue valueWithCATransform3D:self.imageView.layer.transform];

    UIInterfaceOrientation from = self.fromOrientation;
    UIInterfaceOrientation to = self.toOrientation;

    if (UIInterfaceOrientationIsPortrait(to)) {
        scale.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, endFrame.size.width, endFrame.size.height)];
    } else {
        scale.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, endFrame.size.height, endFrame.size.width)];
    }

    NSInteger factor = RadianDifference(from, to);
    rotate.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.imageView.layer.transform, factor*M_PI_2, 0, 0, 1)];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.duration = kAnimationDuration;
    group.delegate = self;
    group.animations = @[scale,rotate,center];
    [group setValue:@"contract" forKey:@"type"];

    self.imageView.layer.position = [center.toValue CGPointValue];
    self.imageView.layer.bounds = [scale.toValue CGRectValue];
    self.imageView.layer.transform = [rotate.toValue CATransform3DValue];
    [self.imageView.layer addAnimation:group forKey:nil];
}

#pragma mark - Private Methods

- (void) onDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Orientation

- (NSUInteger) supportedInterfaceOrientations {
    return self.supportedOrientations;
}

#pragma mark - CAAnimationDelegate

- (void) animationDidStart:(CAAnimation *)anim {
    if ([[anim valueForKey:@"type"] isEqual:@"expand"]) {
        self.liftedImageView.hidden = YES;

    }
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"type"] isEqual:@"contract"]) {
        self.liftedImageView.hidden = NO;
        [self.imageView removeFromSuperview];
    } else if ([[anim valueForKey:@"type"] isEqual:@"expand"]) {
        self.imageView.layer.position = CGPointMake(self.containerView.frame.origin.x + floorf(self.containerView.frame.size.width/2), self.containerView.frame.origin.y + floorf(self.containerView.frame.size.height/2));
        self.imageView.layer.bounds = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
        self.imageView.layer.transform = CATransform3DIdentity;
        [self.containerView addSubview:self.imageView];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.containerView;
}

@end
