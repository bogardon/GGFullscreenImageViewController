//
//  ViewController.m
//  FullScreenImage
//
//  Created by John Wu on 4/2/13.
//  Copyright (c) 2013 John Wu. All rights reserved.
//

#import "ViewController.h"
#import "GGFullScreenImageViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    UIImage *image = [UIImage imageNamed:@"okc.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(85, 10, 150, 85);
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [imageView addGestureRecognizer:tap];
}

- (void) onTap:(UITapGestureRecognizer *)tap {
    GGFullScreenImageViewController *vc = [[GGFullScreenImageViewController alloc] init];
    vc.liftedImageView = (UIImageView *)tap.view;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
