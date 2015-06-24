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

@interface MainMenuViewController ()


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
    
//    [self setupLocalNotifications];
    
//    [self drawPlot];
    
//    NSLog(@"%lu %lu %lu", UIImageOrientationDown, UIImageOrientationUp, UIImageOrientationRight);
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    }
    
    [self.infoButton addTarget:self action:@selector(infoButtonClick) forControlEvents:UIControlEventTouchUpInside];

}

- (void) infoButtonClick {
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = NSLocalizedString(@"Little info", nil);
    alert.message = NSLocalizedString(@"about", nil);
    [alert addButtonWithTitle:NSLocalizedString(@"info_ok", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Go to github!", nil)];
    alert.delegate = self;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"click");
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString: @"https://github.com/34x/4231"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
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
        [self.numbersCountButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    
    if (self.seqIdx < [params count]) {
        self.seqIdx++;
    } else {
        self.seqIdx = 0;
    }

}

- (void) inspectView:(UIView*)rv {
    for (UIView *sub in [rv subviews]) {
        NSLog(@"%@", sub);
        NSLog(@"%.2f x %.2f and %.2f x %.2f", sub.frame.origin.x, sub.frame.origin.y, sub.frame.size.width, sub.frame.size.height);
        NSLog(@"%.2f x %.2f and %.2f x %.2f", sub.bounds.origin.x, sub.bounds.origin.y, sub.bounds.size.width, sub.bounds.size.height);
        if ([sub isKindOfClass:[UINavigationBar class]]) {
//            sub.alpha = .2;
        }
        [self inspectView:sub];
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

    float tomorrow = 3600. * 24.;
    NSDate *currDate = [NSDate dateWithTimeIntervalSinceNow:tomorrow];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:currDate];
    
    for (int i = 8; i < 20; i = i + 2) {

        int hour = i;

//        NSDateComponents *components = [[NSDateComponents alloc] init];

        [components setDay:components.day];
        [components setMonth:components.month];
        [components setYear:components.year];
        [components setMinute:minutes];
        [components setHour:hour];
        
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
