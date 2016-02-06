//
//  SettingsViewController.m
//  attention
//
//  Created by Max on 05.02.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import "SettingsViewController.h"
#import "PiwikTracker.h"
#import "ATSettings.h"
#import "BannerViewController.h"

@interface SettingsViewController() <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

//    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10.01)];
//    self.tableView.tableHeaderView.backgroundColor = [UIColor redColor];
}

- (void) viewWillAppear:(BOOL)animated {
    BOOL bannerIsActive = [[[ATSettings sharedInstance] get:@(ATSettingsKeyBannerSettings)] boolValue];
    [[BannerViewController instance] setBannerActive:bannerIsActive];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 4;
            break;
        default:
            return 0;
            break;
    }
    return 2;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (0 == indexPath.section) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell" forIndexPath:indexPath];
    
        UILabel *label = (UILabel*)[cell viewWithTag:24];
        
        switch (indexPath.row) {
            case 0:
                label.text = @"Open Github source";
                break;
            case 1:
                label.text = @"Rate us ⭐⭐⭐⭐⭐";
                break;
            case 2:
                label.text = @"Send feedback";
                break;
            case 3:
                label.text = @"Open website";
                break;
            default:
                break;
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BannerCell" forIndexPath:indexPath];
        UILabel *label = (UILabel*)[cell viewWithTag:1];
        UISwitch *toggle = (UISwitch*)[cell viewWithTag:2];
        ATSettings *settings = [ATSettings sharedInstance];

        switch (indexPath.row) {
            case 0:
                label.text = @"Main menu banner";
                [toggle setOn:[[settings get:@(ATSettingsKeyBannerMain)] boolValue] animated:YES];
                break;
            case 1:
                label.text = @"Sequence preview";
                [toggle setOn:[[settings get:@(ATSettingsKeyBannerSequence)] boolValue] animated:YES];
                break;
            case 2:
                label.text = @"Statistics";
                [toggle setOn:[[settings get:@(ATSettingsKeyBannerStatistics)] boolValue] animated:YES];
                break;
            case 3:
                label.text = @"Settings";
                [toggle setOn:[[settings get:@(ATSettingsKeyBannerSettings)] boolValue] animated:YES];
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        switch (indexPath.row) {
            case 0:
                [self openGithub];
                break;
            case 1:
                [self openRateApp];
                break;
            case 2:
                [self performSegueWithIdentifier:@"feedback" sender:self];
                break;
            case 3:
                [self openWebsite];
                break;
            default:
                break;
        }
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UISwitch *toggle = (UISwitch*)[cell viewWithTag:2];
        [toggle setOn:!toggle.on animated:YES];
        
        ATSettings *settings = [ATSettings sharedInstance];
        
        switch (indexPath.row) {
            case 0:
                [settings setSettingValue:@(toggle.on) forKey:@(ATSettingsKeyBannerMain)];
                break;
            case 1:
                [settings setSettingValue:@(toggle.on) forKey:@(ATSettingsKeyBannerSequence)];
                break;
            case 2:
                [settings setSettingValue:@(toggle.on) forKey:@(ATSettingsKeyBannerStatistics)];
                break;
            case 3:
                [settings setSettingValue:@(toggle.on) forKey:@(ATSettingsKeyBannerSettings)];
                
                [[BannerViewController instance] setBannerActive:toggle.on];
                break;
            default:
                break;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"About";
            break;
        case 1:
            return @"Toggle banners";
            break;
        default:
            return @"";
            break;
    }
}


- (void) openGithub {
    NSURL *url = [NSURL URLWithString: [[ATSettings sharedInstance] get:@"github"]];
    [[PiwikTracker sharedInstance] sendOutlink:[url absoluteString]];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void) openRateApp {
    NSString *appId = [[ATSettings sharedInstance] get:@"app_id"]; //Change this one to your ID
    
    NSString *iOS7AppStoreURLFormat = [[ATSettings sharedInstance] get:@"rate_url"];
    NSString *iOSAppStoreURLFormat = [[ATSettings sharedInstance] get:@"rate_url_old"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)? iOS7AppStoreURLFormat: iOSAppStoreURLFormat, appId]]; // Would contain the right link
    
    [[PiwikTracker sharedInstance] sendOutlink:[NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", appId]];
    
    [[UIApplication sharedApplication] openURL:url];

}


- (void) openWebsite {
    NSURL *url = [NSURL URLWithString: [[ATSettings sharedInstance] get:@"website"]];
    [[PiwikTracker sharedInstance] sendOutlink:[url absoluteString]];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
@end
