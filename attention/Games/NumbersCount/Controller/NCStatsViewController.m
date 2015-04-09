//
//  StatsViewController.m
//  attention
//
//  Created by Max on 19/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "NCStatsViewController.h"
#import "NCGame.h"

@interface NCStatsViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statsSelector;
@property (weak, nonatomic) IBOutlet UIScrollView *hourSelectorScroll;
@end

@implementation NCStatsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.scrollView.backgroundColor = [UIColor redColor];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

}

- (void) tapOnHourSelector:(id)sender{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tap = sender;

        [self drawDaysStats:[NSNumber numberWithLong: tap.view.tag]];
        
        // TODO: fix it and optimize
        for (UIView *v in [self.hourSelectorScroll subviews]) {
            v.backgroundColor = nil;
        }
        tap.view.backgroundColor = [UIColor colorWithRed:90./100. green:95./100. blue:255./100. alpha:1];
    }
}

- (IBAction)selectStats:(id)sender {
    if (0 == self.statsSelector.selectedSegmentIndex) {
        [self drawDaysStats];
    } else {
        [self drawDayStats];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self drawDaysStats];
    [self.statsSelector addTarget:self action:@selector(selectStats:) forControlEvents:UIControlEventValueChanged];
    
    
//    for (int i = 0; i < 24; i++) {
//        UIView *hourSelect = [[UIView alloc] initWithFrame:CGRectMake(xCord, (hourSelectHeight + 2)*(i-1) + 120., hourSelectWidth,   hourSelectHeight)];
//        [self.view addSubview:hourSelect];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, hourSelectWidth, hourSelectHeight)];
//        label.text = [NSString stringWithFormat:@"%d", i];
//        label.textAlignment = NSTextAlignmentCenter;
//        [hourSelect addSubview:label];
////        hourSelect.backgroundColor = [UIColor blueColor];
//    }
}

- (void) clearStats {
    while ([[self.scrollView subviews] count] > 0) {
        [[self.scrollView subviews][0] removeFromSuperview];
    }
}

- (void) drawDayStats {
    NSDictionary *stats = [NCGame statsForDay];
    if (0 == [stats count]) {
        return;
    }
    [self.hourSelectorScroll setHidden:YES];
    [self clearStats];
    float rowHeight = 24;
    NSString *font = @"Helvetica";
    float smallFont = 12.;
    int row = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    NSArray *totals = [[stats allKeys] sortedArrayUsingComparator:^(id obj1, id obj2){
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    for (NSString *total in totals) {
        NSDictionary *days = stats[total];

        
        //TODO: fix this ugly
        float max = 0;
        for (NSString *day in days) {
            if ([days[day] floatValue] > max) {
                max = [days[day] floatValue];
            }
        }
        
        NSArray *sorted = [[days allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {

            NSInteger i1 = [[obj1 stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
            NSInteger i2 = [[obj2 stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
            
            if (i1 > i2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (i1 < i2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(4, row*rowHeight, self.scrollView.frame.size.width, rowHeight)];
        l.text = total;
        l.textAlignment = NSTextAlignmentCenter;
//        [self.scrollView addSubview:l];
//        row++;

        for (NSString *hour in sorted) {
            float speed = [days[hour] floatValue];
            float percent = speed / max;
            
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, row*rowHeight, self.scrollView.frame.size.width, rowHeight)];
            dayLabel.text = [NSString stringWithFormat:@"%@", hour];
            dayLabel.textColor = [UIColor whiteColor];
            dayLabel.font = [UIFont fontWithName:font size:smallFont];
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, row*rowHeight, percent, rowHeight)];
            v.backgroundColor = [UIColor colorWithRed:100. / 255. * 61. / 100. green:100. / 255. * 112. / 100. blue:100. / 255. * 232. / 100. alpha:.9];
            [self.scrollView addSubview:v];
            [self.scrollView addSubview:dayLabel];
            
            UILabel *speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(-40., 0., 40., rowHeight)];
            speedLabel.text = [NSString stringWithFormat:@"%.2f", speed];
            speedLabel.textColor = [UIColor whiteColor];
            speedLabel.textAlignment = NSTextAlignmentRight;
            speedLabel.font = [UIFont fontWithName:font size:smallFont];
            [v addSubview:speedLabel];
            
            row++;
        }
        
        row++;
    }
    
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, rowHeight*row)];
    
    float width = self.scrollView.bounds.size.width;
    // can be faster!
    width = width - width * 0.2;
    for (UIView *view in [self.scrollView subviews]) {
        if (![view isKindOfClass:[UILabel class]]) {
            CGRect rect = view.frame;
            [UIView animateWithDuration:0.9
                             animations:^{
                                 view.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * width + 40, rect.size.height);
                                 
                                 UIView *l = [view subviews][0];
                                 CGRect lrect = l.frame;
                                 l.frame = CGRectMake(rect.size.width * width - 4, lrect.origin.y
                                                      , lrect.size.width, lrect.size.height);
                             }];
        }
    }
}

- (void) drawDaysStats{
    [self drawDaysStats:nil];
}

- (void) drawDaysStats:(NSNumber*)hour {
    NSDictionary *stats = [NCGame stats];
    if (0 == [stats count]) {
        return;
    }
    [self.hourSelectorScroll setHidden:NO];
    
    NSMutableDictionary *hoursEnabled = [[NSMutableDictionary alloc] init];
    
    NSString *selectedHourKey;
    if (nil != hour) {
        selectedHourKey = [NSString stringWithFormat:@"%02ld", [hour integerValue]];
    }
    
    [self clearStats];
    float rowHeight = 24.;
    NSString *font = @"Helvetica";
    float smallFont = 12.;
    int row = 0;
    self.view.backgroundColor = [UIColor whiteColor];


    
    NSArray *totals = [[stats allKeys] sortedArrayUsingComparator:^(id obj1, id obj2){
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    for (NSString *total in totals) {
        // because we show totals not splitted, remove header
        bool totalTitleDrawed = YES;
        
        NSDictionary *days = stats[total];
        
        float max = 0;
        for (NSString *dayKey in days) {
            NSMutableDictionary *day = days[dayKey];
            if (max < [day[@"max"] floatValue]) {
                max = [day[@"max"] floatValue];
            }
        }

        NSArray *sorted = [[days allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {

            NSInteger i1 = [[obj1 stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
            NSInteger i2 = [[obj2 stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
            
            if (i1 > i2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (i1 < i2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }];

        NSString *month;
        for (NSString *day in sorted) {
            float speed;
            if (nil == selectedHourKey) {
                speed = [days[day][@"avg"] floatValue];
                
                for (NSString *enabledHour in days[day][@"hours"]) {
                    if (nil == hoursEnabled[enabledHour]) {
                        hoursEnabled[enabledHour] = [NSNumber numberWithInt:0];
                    }
                }

            } else {
                speed = [days[day][@"hours"][selectedHourKey] floatValue];
            }
            
            if (0. == speed) {
                continue;
            }
            
            /*
             * TOTAL LABEL DRAW
             */
            if(!totalTitleDrawed) {
                UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(4, row*rowHeight, self.scrollView.frame.size.width, rowHeight)];
                l.text = total;
                l.textAlignment = NSTextAlignmentCenter;
                [self.scrollView addSubview:l];
                row++;
                totalTitleDrawed = YES;
            }
            
            NSArray *date = [day componentsSeparatedByString:@"."];
            
            float percent = speed / max;
//            NSLog(@"p: %f max: %f", percent, max);
            /*
             * SPEED LABEL DRAW
             */
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, row*rowHeight, self.scrollView.frame.size.width, rowHeight)];
            if (nil == month || ![month isEqualToString:date[1]]) {
                dayLabel.text = [NSString stringWithFormat:@"%@.%@.%@", date[2], date[1], date[0]];
                month = date[1];
            } else {
                dayLabel.text = [NSString stringWithFormat:@"%@", date[2]];
            }
            dayLabel.textColor = [UIColor whiteColor];
            dayLabel.font = [UIFont fontWithName:font size:smallFont];
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, row*rowHeight, percent, rowHeight)];
            v.backgroundColor = [UIColor colorWithRed:100. / 255. * 61. / 100. green:100. / 255. * 112. / 100. blue:100. / 255. * 232. / 100. alpha:.9];
            [self.scrollView addSubview:v];
            [self.scrollView addSubview:dayLabel];
            
            UILabel *speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(-40., 0., 40., rowHeight)];
            speedLabel.text = [NSString stringWithFormat:@"%.2f", speed];
            speedLabel.textColor = [UIColor whiteColor];
            speedLabel.textAlignment = NSTextAlignmentRight;
            speedLabel.font = [UIFont fontWithName:font size:smallFont];
            [v addSubview:speedLabel];
            
            row++;
        }
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, rowHeight*row)];
    
    
    /*
     width for digit | percent
     
     
     */
    
    float frameWidth = self.scrollView.bounds.size.width;
    float paddingWidth = 110.;
    // can be faster!
    float widthForPercentage = frameWidth - paddingWidth - frameWidth * 0.1;
    for (UIView *view in [self.scrollView subviews]) {
        if (![view isKindOfClass:[UILabel class]]) {
            CGRect rect = view.frame;
            float percentageWidth = rect.size.width * widthForPercentage;
            [UIView animateWithDuration:0.9
                             animations:^{
                                 view.frame = CGRectMake(rect.origin.x, rect.origin.y, paddingWidth + percentageWidth, rect.size.height);
                                 
                                 UIView *l = [view subviews][0];
                                 CGRect lrect = l.frame;
                                 l.frame = CGRectMake(view.frame.size.width - 44., lrect.origin.y
                                                      , lrect.size.width, lrect.size.height);
                             }];
        }
    }

    if (nil == selectedHourKey) {
        for (UIView *v in [self.hourSelectorScroll subviews]) {
            [v removeFromSuperview];
        }
        
        float hourSelectWidth = 44.;
        float hourSelectHeight = 38.;

        NSArray *hoursEnabledSorted = [[hoursEnabled allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
            NSInteger i1 = [obj1 integerValue];
            NSInteger i2 = [obj2 integerValue];
            
            if (i1 > i2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (i1 < i2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;

        }];
        
        int idx = 0;
        for (NSString *hour in hoursEnabledSorted) {

            UIView *hourSelect = [[UIView alloc] initWithFrame:CGRectMake(0, hourSelectHeight*idx, hourSelectWidth,   hourSelectHeight)];
            hourSelect.tag = [hour intValue];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, hourSelectWidth, hourSelectHeight)];
            label.text = [NSString stringWithFormat:@"%@", hour];
            label.textAlignment = NSTextAlignmentCenter;
            //        label.textColor = [UIColor blueColor];
            [hourSelect addSubview:label];
            
            [self.hourSelectorScroll addSubview:hourSelect];
            hourSelect.alpha =0.;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnHourSelector:)];
            [hourSelect addGestureRecognizer:tap];
            idx++;
        }
        
        [self.hourSelectorScroll setContentSize:CGSizeMake(hourSelectWidth, hourSelectHeight*idx)];
        
        idx = 1;
        for (UIView *view in [self.hourSelectorScroll subviews]) {
            [UIView animateWithDuration:.9 + (idx / 10.)
                             animations:^{
                                 view.alpha = 1.;
                             }];
            idx++;
        }
    }
    
}

- (void) drawStats:(NSArray*)stats fitHeight:(BOOL)fitHeight{
    
}

- (void) backButtonClick:(UIButton*)button {
//    [self performSegueWithIdentifier:@"stats" sender:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
//    [self segueForUnwindingToViewController:self fromViewController:self identifier:@"stats"];
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
