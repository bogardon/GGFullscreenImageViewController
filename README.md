GGFullscreenImageViewController
===============================

`UIViewController` subclass that lets you fullscreen an `UIImageView`. Assuming `self` is your `UIViewController` subclass and `imageView` is the `UIImageView` you want to fullscreen. Just do:

    GGFullscreenImageViewController *vc = [[GGFullscreenImageViewController alloc] init];
    vc.liftedImageView = imageView;
    [self presentViewController:vc animated:YES completion:nil];

You can optionally set `supportedOrientations` on `GGFullscreenImageViewController`. Notice that by default, `GGFullscreenImageViewController` supports all orientations defined in your info-plist.
