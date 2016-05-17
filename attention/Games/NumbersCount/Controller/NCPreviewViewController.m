//
//  NCPreviewViewController.m
//  attention
//
//  Created by Max on 06.02.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import "NCPreviewViewController.h"
#import "BannerViewController.h"
#import "NCGameViewController.h"
#import "ATSettings.h"
#import "GCHelper.h"

@implementation NCPreviewViewController


- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.game = [NCGame sharedInstance];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    BOOL bannerIsActive = [[[ATSettings sharedInstance] get:@(ATSettingsKeyBannerSequence)] boolValue];
    [[BannerViewController instance] setBannerActive:bannerIsActive];
    
    [self prepareForNewRound];
}

-(void) viewDidAppear:(BOOL)animated {
    [[GCHelper sharedInstance] showAuthControllerFrom:self];
}

- (void) prepareForNewRound {
    
    [self.game preparForNewRound];
    
    NSString *msg = [self.game.sequence componentsJoinedByString:@"   "];
    
    self.sequencePreviewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.sequencePreviewButton setTitle:msg forState:UIControlStateNormal];

    if (self.game.sequenceLength < 28) {
        self.sequencePreviewButton.titleLabel.font = [UIFont systemFontOfSize:42];
    } else {
        self.sequencePreviewButton.titleLabel.font = [UIFont systemFontOfSize:32];
    }
}

- (IBAction)sequenceButtonHandler:(id)sender {
    [self prepareForNewRound];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *dvc = segue.destinationViewController;
    
    if ([dvc isKindOfClass:[NCGameViewController class]]) {
        NCGameViewController *vc = (NCGameViewController*)dvc;
        vc.game = self.game;
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
