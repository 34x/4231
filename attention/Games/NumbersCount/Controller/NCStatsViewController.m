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
@end

@implementation NCStatsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
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
        [self.scrollView addSubview:l];
        row++;

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
    
    
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, rowHeight*row)];
    
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

- (void) drawDaysStats {
    NSDictionary *stats = [NCGame stats];
    if (0 == [stats count]) {
        return;
    }
    
    [self clearStats];
    float rowHeight = 24;
    NSString *font = @"Helvetica";
    float smallFont = 12.;
    int row = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    

//    NSLog(@"log items count: %lu", [stats count]);


    
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
//        NSLog(@"total: %@", total);
//        NSLog(@"days: %@", [days allKeys]);
        
        //TODO: fix this ugly
        float max = 0;
        for (NSString *day in days) {
            if ([days[day] floatValue] > max) {
                max = [days[day] floatValue];
            }
        }
        
        NSArray *sorted = [[days allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
//            NSLog(@"%@", obj1);
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
        [self.scrollView addSubview:l];
        row++;
        NSString *month;
        for (NSString *day in sorted) {
            NSArray *date = [day componentsSeparatedByString:@"."];
            if (nil == month || ![month isEqualToString:date[1]]) {
                UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(4, row*rowHeight, self.scrollView.frame.size.width-10, rowHeight)];
                l.text = [NSString stringWithFormat:@"%@.%@", date[0], date[1]];
//                l.textColor = [UIColor blackColor];
//                l.textAlignment = NSTextAlignmentRight;
                l.font = [UIFont fontWithName:font size:smallFont];
                [self.scrollView addSubview:l];
                month = date[1];
                row++;
            }
            
            float speed = [days[day] floatValue];
            float percent = speed / max;
            
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, row*rowHeight, self.scrollView.frame.size.width, rowHeight)];
            dayLabel.text = [NSString stringWithFormat:@"%@", date[2]];
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
        
        
        
//        NSArray *dayValues = [[days allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
//            
//            NSString *s1 = obj1;
//            NSArray *s1a = [s1 componentsSeparatedByString:@"."];
//
//            
//            NSString *s2 = obj2;
//            NSArray *s2a = [s2 componentsSeparatedByString:@"."];
//            
//            NSInteger i1 = [s1a[0] integerValue] + [s1a[1] integerValue] + [s1a[2] integerValue];
//            
//            NSLog(@"%@", s1a);
//            
//            if ([s1 integerValue] > [s2 integerValue]) {
//                return (NSComparisonResult)NSOrderedDescending;
//            }
//            
//            if ([s1 integerValue] < [s2 integerValue]) {
//                return (NSComparisonResult)NSOrderedAscending;
//            }
//            
//            return (NSComparisonResult)NSOrderedSame;
//        }];
////        NSLog(@"%@", dayValues);
//
//        for (NSString *day in dayValues){
////            NSLog(@"%@", day);
//        }
        
        
    }
    
//    NSString *day = [dateFormatter stringFromDate:items[0][0]];
//    float avg = 0.0;
//    int row = 0;
//    //    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
//    
//    NSInteger idx = 0;
//    for(id obj in items) {
//        
//        if ([obj isKindOfClass:[NSArray class]]) {
//            NSArray *item = (NSArray*)obj;
//            float speed = [item[1] floatValue] / [item[2] floatValue];
//
//            if (0 == avg) {
//                avg = speed;
//            } else {
//                avg = (avg + speed) / 2.;
//            }
//
//            if (![[dateFormatter stringFromDate:item[0]] isEqualToString:day] || idx + 1 == [items count]) {
//
//                UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(8, row*rowHeight, self.view.bounds.size.width, rowHeight)];
//                l.textColor = [UIColor whiteColor];
//                
//                float percent = avg / max;
//                
//                l.text = [NSString stringWithFormat:@"%@ %.2f", day, avg];
//                
//                UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, row*rowHeight, percent, rowHeight)];
//                bar.backgroundColor = [UIColor colorWithRed:100. / 255. * 61. / 100. green:100. / 255. * 112. / 100. blue:100. / 255. * 232. / 100. alpha:.9];
//                [self.scrollView addSubview:bar];
//                
//                [self.scrollView addSubview:l];
//                
//                row++;
//                avg = 0.;
//                day = [dateFormatter stringFromDate:item[0]];
//            }
//        }
//        idx++;
//    }
    
//
    [self.scrollView setContentSize:CGSizeMake(self.view.bounds.size.width, rowHeight*row)];
    
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
