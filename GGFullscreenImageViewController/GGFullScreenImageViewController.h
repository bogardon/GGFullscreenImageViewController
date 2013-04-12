//
//  GGFullscreenImageViewController.h
//  TFM
//
//  Created by John Wu on 6/5/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GGOrientation) {
    GGOrientationPortrait = 0,
    GGOrientationLandscapeLeft = 1,
    GGOrientationPortraitUpsideDown = 2,
    GGOrientationLandscapeRight = 3
};

@interface GGFullscreenImageViewController : UIViewController

@property (nonatomic, retain) UIImageView *liftedImageView;
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientations;

@end
