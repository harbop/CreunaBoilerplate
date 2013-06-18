//
//  CreunaLockoutLoader.m
//  Drive
//
//  Created by Kåre Harbo Poulsen on 11/12/12.
//  Copyright (c) 2012 Q8 - Kuwait Petroleum (Danmark) A/S. All rights reserved.
//

#import "CreunaLockoutLoader.h"

@interface CreunaLockoutLoaderViewController : UIViewController
@end

@implementation CreunaLockoutLoaderViewController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
@end

@implementation CreunaLockoutLoader

@synthesize overlayWindow = _overlayWindow;
@synthesize lockoutView = _lockoutView;
@synthesize spinner = _spinner;
@synthesize gradientBackground = _gradientBackground;

SYNTHESIZE_SINGLETON_FOR_CLASS(CreunaLockoutLoader);

bool _loadingSemaphor;

- (UIView*) blockingBackgroundWithFrame:(CGRect) frame
{
    if (!_lockoutView) {
        _lockoutView = [[UIView alloc] initWithFrame:frame];
        _lockoutView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.gradientBackground = [[UIView alloc] initWithFrame:frame];
        self.gradientBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.gradientBackground.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
        
        self.spinner = [[UIActivityIndicatorView alloc] init];
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.spinner.center = CGPointMake(frame.size.width / 2.0f, frame.size.height / 2.0f);
        
        [_lockoutView addSubview:self.gradientBackground];
        [_lockoutView addSubview:self.spinner];
        [self.spinner startAnimating];
    }
    return _lockoutView;
}

- (void) presentInView:(UIView*)view
{
    [self.spinner startAnimating];
    [view addSubview:[self blockingBackgroundWithFrame:view.bounds]];
}


+ (void) presentInView:(UIView*)view
{
    if (_loadingSemaphor) {
        // we are already displaying loader. abort.
        return;
    }
    _loadingSemaphor = YES;
    
    CreunaLockoutLoader* instance = [self sharedCreunaLockoutLoader];
    
    [instance presentInView:view];
}

+ (void) presentInOverlayWindow
{
    if (_loadingSemaphor) {
        // we are already displaying loader. abort.
        return;
    }
    _loadingSemaphor = YES;
    
    CreunaLockoutLoader* instance = [self sharedCreunaLockoutLoader];
    instance.overlayWindow = [[UIWindow alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
    instance.overlayWindow.rootViewController = [[CreunaLockoutLoaderViewController alloc] initWithNibName:nil bundle:nil];
    instance.overlayWindow.rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    instance.overlayWindow.hidden = NO;
    [instance.overlayWindow makeKeyAndVisible];
    
    [instance presentInView:instance.overlayWindow.rootViewController.view];
}

+ (void) dismiss
{
    if (!_loadingSemaphor) {
        // no loader shown. abort
        return;
    }
    _loadingSemaphor = NO;
    
    CreunaLockoutLoader* instance = [self sharedCreunaLockoutLoader];
    
    [instance.spinner stopAnimating];
    [instance.overlayWindow resignKeyWindow];
    [instance.lockoutView removeFromSuperview];
    instance.overlayWindow = nil;
}

@end

