//
//  MainMenuViewController.m
//  attention
//
//  Created by Max on 25/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "MainMenuViewController.h"
#import "NCGame.h"
#import "UIPlotView.h"
#import <QuartzCore/QuartzCore.h>
#import "NCSettings.h"
#import "PiwikTracker.h"
#import "GCHelper.h"
#import "ATSettings.h"
#import <iAd/iAd.h>
#import "BannerViewController.h"

@interface MainMenuViewController ()

@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;

@property (weak, nonatomic) IBOutlet UIView *numbersCount;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *viewTitle;
@property (weak, nonatomic) IBOutlet UIButton *numbersCountStats;
@property (weak, nonatomic) IBOutlet UIButton *numbersCountButton;

@property (weak, nonatomic) IBOutlet UIView *plot;
@property (readwrite) UIView *imageOverlay;

@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) NSUInteger seqIdx;

@end

@implementation MainMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *numbersCountTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numbersCountClick:)];
    [self.numbersCount addGestureRecognizer:numbersCountTap];
    
    [self.numbersCountButton addTarget:self action:@selector(numbersCountClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *numbersCountStatsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(numbersCountStatsClick:)];
    [self.numbersCountStats addGestureRecognizer:numbersCountStatsTap];
    
    [self.numbersCountStats addTarget:self action:@selector(numbersCountStatsClick:) forControlEvents:UIControlEventTouchUpInside];
//    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg2.jpg"]];
    
    [self setupLocalNotifications];
    
//    [self drawPlot];
    
//    NSLog(@"%lu %lu %lu", UIImageOrientationDown, UIImageOrientationUp, UIImageOrientationRight);
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    }
}


- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    BOOL bannerIsActive = [[[ATSettings sharedInstance] get:@(ATSettingsKeyBannerMain)] boolValue];
    [[BannerViewController instance] setBannerActive:bannerIsActive];

    NSLog(@"Will appear");
//    if([[ATSettings sharedInstance] get:@(ATSettingsKeyBannerMain)]){
//        _bannerView.hidden = NO;
//    } else {
//        _bannerView.hidden = YES;
//    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[PiwikTracker sharedInstance] sendView:@"main_menu"];
    
    
    //[NSTimer scheduledTimerWithTimeInterval:9 target:self selector:@selector(infoButtonMove) userInfo:nil repeats:YES];
    
    if ([GCHelper sharedInstance].gameCenterAvailable && [GCHelper sharedInstance].userAuthenticated) {
        self.leaderboardButton.hidden = NO;
    } else {
        self.leaderboardButton.hidden = YES;
    }
}

- (void) infoButtonMove {
    [UIView animateWithDuration:0.4 animations:^{
        self.infoButton.transform = CGAffineTransformRotate(self.infoButton.transform, M_PI / 5.0);
        self.infoButton.transform = CGAffineTransformScale(self.infoButton.transform, 2.0, 2.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 animations:^{
            self.infoButton.transform = CGAffineTransformRotate(self.infoButton.transform, M_PI / -2.5);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 animations:^{
                self.infoButton.transform = CGAffineTransformRotate(self.infoButton.transform, M_PI / 5.0);
                self.infoButton.transform = CGAffineTransformScale(self.infoButton.transform, 0.5, 0.5);
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
}


- (void) timerTick {
    if (!self.seqIdx) {
        self.seqIdx = 0;
    }
    
    NSArray *params = [NCGame getSequencesParams];
    
    if (self.seqIdx < [params count]) {
//    NSDictionary *param = [params objectAtIndex:self.seqIdx];
        NCGame *tmpGame = [[NCGame alloc] initWithTotal:4];
        NSArray *seq = [tmpGame getSequence:self.seqIdx difficultyLevel:0];
    
        NSString *title = [seq componentsJoinedByString:@" "];
        [self.numbersCountButton setTitle:title forState:UIControlStateNormal];
    } else {
        [self.numbersCountButton setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];
    }
    
    if (self.seqIdx < [params count]) {
        self.seqIdx++;
    } else {
        self.seqIdx = 0;
    }

}

- (void)setupLocalNotifications {

    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    UIApplication *application = [UIApplication sharedApplication];
    
    // ask for notification permissions
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge];
    }
    
    
    int minutes = 42;
    int hours = 14;

    float tomorrow = 3600. * 24 * 4;
    
    for (int i = 0; i < 8; i++) {

        int day = tomorrow * i;

        NSDate *currDate = [NSDate dateWithTimeIntervalSinceNow:day];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:currDate];

        [components setDay:components.day];
        [components setMonth:components.month];
        [components setYear:components.year];
        [components setMinute:minutes];
        [components setHour:hours];
        
        NSDate *date = [calendar dateFromComponents:components];
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification = [UILocalNotification new];
        notification.fireDate = date;
        
    //    notification.fireDate  = [[NSDate date] dateByAddingTimeInterval:5.0f];
        
        
        //    notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.timeZone = [NSTimeZone systemTimeZone];
        //    notification.timeZone = [NSTimeZone timeZoneWithName:@"Europe/Belgrade"];
        //    NSLog(@"%@", [NSTimeZone knownTimeZoneNames]);
        notification.alertBody = NSLocalizedString(@"А не пора бы нам немного позаниматься?", nil);
        notification.alertAction = NSLocalizedString(@"View details", nil);
        
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = 0;
        
        
        NSLog(@"Notification will be shown on: %@",notification.fireDate);
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)drawPlot {
    [self.plot removeFromSuperview];
    UIPlotView *plot = [[UIPlotView alloc] initWithFrame:CGRectMake(.0, 0., 400., 100.)];
    plot.plotBackgroundColor = [UIColor lightGrayColor];
    [self.plot addSubview:plot];
    plot.points = @[
                    @[@100, @20],
                    @[@200, @50]
                    ];
    [plot redraw];

}

- (void) numbersCountClick:(id)sender {
    [self performSegueWithIdentifier:@"numbers_count_game" sender:self];
}

- (void) numbersCountStatsClick:(id)sender {
    [self performSegueWithIdentifier:@"numbers_count_stats" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
