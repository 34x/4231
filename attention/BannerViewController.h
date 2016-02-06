//
//  BannerViewController.h
//  attention
//
//  Created by Max on 06.02.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface BannerViewController : UIViewController <ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;

+ (BannerViewController*) instance;


- (void) setBannerActive:(BOOL)active;
@end
