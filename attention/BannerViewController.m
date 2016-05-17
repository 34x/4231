//
//  BannerViewController.m
//  attention
//
//  Created by Max on 06.02.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import "AppDelegate.h"
#import "BannerViewController.h"

@implementation BannerViewController {
    CGFloat containerHeight;
    CGFloat bannerY;
    BOOL isBannerActive;
    NSTimer *failTimer;
}


+ (BannerViewController*) instance {
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return (BannerViewController*)delegate.window.rootViewController;
}

- (void) viewDidLoad {
    _bannerView.delegate = self;
    isBannerActive = NO;
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    containerHeight = _containerView.frame.size.height;
    bannerY = _bannerView.frame.origin.y;
}

- (void) setBannerActive:(BOOL)active {
    BOOL bannerOff = YES;
    
    if (bannerOff) {
        return;
    }
    
    isBannerActive = active;
    
    if(!_bannerView.isBannerLoaded && active) {
        return;
    }
    
    CGRect frame = self.view.frame;
    CGRect bannerFrame = _bannerView.frame;
    
    CGFloat height = containerHeight;
    CGFloat bannerPosition = _bannerView.frame.origin.y;
    
    if (!active) {
        height = containerHeight + _bannerView.frame.size.height;
        bannerPosition = bannerY + _bannerView.frame.size.height;
    } else {
        height = containerHeight;
        bannerPosition = bannerY;
    }
    
    
    [UIView animateWithDuration:1.0 animations:^{
        _containerView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);;
        _bannerView.frame =    CGRectMake(bannerFrame.origin.x, bannerPosition, bannerFrame.size.width, bannerFrame.size.height);;
    }];
    
}

- (void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
//    NSLog(@"Shared banner did fail");
    [failTimer invalidate];
    failTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(setBannerInactive) userInfo:nil repeats:NO];
}

- (void) bannerViewActionDidFinish:(ADBannerView *)banner {
//    NSLog(@"Shared banner did finish");
    [self setBannerActive:NO];
}

- (void) bannerViewDidLoadAd:(ADBannerView *)banner {
//    NSLog(@"Shared banner did load");
    [self setBannerActive:isBannerActive];
}

- (void) bannerViewWillLoadAd:(ADBannerView *)banner {
//    NSLog(@"Shared banner will load");
}

-( void) setBannerInactive {
    [self setBannerActive:NO];
    
}

-(BOOL) shouldAutorotate {
    return NO;
}

@end
