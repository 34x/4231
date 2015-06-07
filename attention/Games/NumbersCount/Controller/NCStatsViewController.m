//
//  StatsViewController.m
//  attention
//
//  Created by Max on 19/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "NCStatsViewController.h"
#import "NCGame.h"
#import "UIPlotView.h"


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

- (IBAction)selectStats:(id)sender {
    if (0 == self.statsSelector.selectedSegmentIndex) {
        [self drawStats:@"YYYY.MM.dd"];
    } else {
        [self drawStats:@"HH"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self drawStats:@"YYYY.MM.dd"];
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

- (void) drawStats:(NSString*)format {
    NSDictionary *stats = [NCGame stats:format];

    if (0 == [stats count]) {
        return;
    }

    [self clearStats];
    
    float frameWidth = self.scrollView.bounds.size.width;
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frameWidth, 24)];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"Summary";
    [self.scrollView addSubview:label1];
    
    UIPlotView *plot = [[UIPlotView alloc] initWithFrame:CGRectMake(.0, 24., frameWidth, 150.)];
    plot.plotBackgroundColor = [UIColor whiteColor];
    plot.lineColor = [UIColor blueColor];
    NSMutableArray *points = [[NSMutableArray alloc] init];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 182, frameWidth, 32)];
    label2.text = @"Avarage";
    label2.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:label2];
    
    UIPlotView *plotAvg = [[UIPlotView alloc] initWithFrame:CGRectMake(.0, 214., frameWidth, 150.)];
    plotAvg.plotBackgroundColor = [UIColor whiteColor];
    plotAvg.lineColor = [UIColor greenColor];
    NSMutableArray *pointsAvg = [[NSMutableArray alloc] init];


    float rowHeight = 28.;
    NSString *font = @"Helvetica";
    float smallFont = 14.;

    int row = 0;
    float max = [[stats objectForKey:@"max"] floatValue];
    self.view.backgroundColor = [UIColor whiteColor];

    NSArray *days = [[[stats objectForKey:@"days"] allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {

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
    int x = 0;
    for (NSString *day in days) {
        NSDictionary *dayData = [[stats objectForKey:@"days" ] objectForKey:day];

        float dayMin = [[dayData objectForKey:@"min"] floatValue];
        float dayAvg = [[dayData objectForKey:@"avg"] floatValue];
        float dayMax = [[dayData objectForKey:@"max"] floatValue];
        float daySum = [[dayData objectForKey:@"sum"] floatValue];

        if (0. == dayAvg) {
            continue;
        }
        NSArray *date = [day componentsSeparatedByString:@"."];
        
        
        NSString *day;
        if ([date count] > 2) {
            day = [NSString stringWithFormat:@"%@", date[2]];
        } else {
            day = [NSString stringWithFormat:@"%@", date[0]];
        }
        
        [points addObject:@[day, [NSNumber numberWithFloat:daySum]]];
        [pointsAvg addObject:@[day, [NSNumber numberWithFloat:dayAvg]]];
        x = x + 20.;
        
        continue;
        

            
            float percentAvg = dayAvg / max;
            float percentMax = dayMax / max;
            float percentMin = dayMin / max;
            
            
            /*
             * SPEED LABEL DRAW
             */
            
            UIView *vmin = [[UIView alloc] initWithFrame:CGRectMake(0, row*rowHeight, percentMin, rowHeight)];

            vmin.backgroundColor = [NCStatsViewController getColor:184. green:233. blue:134. alpha:1.];

//            UILabel *lmin = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, rowHeight)];
//            lmin.text = [NSString stringWithFormat:@"%.2f", dayMin];
//            [vmin addSubview:lmin];
//            row++;
            
            UIView *vavg = [[UIView alloc] initWithFrame:CGRectMake(0, row*rowHeight, percentAvg, rowHeight)];
            
            vavg.backgroundColor = [NCStatsViewController getColor:114. green:164. blue:222. alpha:1.];
            
//            row++;

            UIView *vmax = [[UIView alloc] initWithFrame:CGRectMake(0, row*rowHeight, percentMax, rowHeight)];

            vmax.backgroundColor = [NCStatsViewController getColor:255. green:179. blue:19 alpha:1.];

//            UILabel *lmax = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, rowHeight)];
//            lmax.text = [NSString stringWithFormat:@"%.2f", dayMax];
//            [vmax addSubview:lmax];
            
            
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, row*rowHeight, self.scrollView.frame.size.width, rowHeight)];
            if ([date count] > 2) {
                if (nil == month || ![month isEqualToString:date[1]]) {
                    dayLabel.text = [NSString stringWithFormat:@"%@.%@.%@", date[2], date[1], date[0]];
                    month = date[1];
                } else {
                    dayLabel.text = [NSString stringWithFormat:@"%@", date[2]];
                }
            } else {
                dayLabel.text = [NSString stringWithFormat:@"%@", date[0]];
            }
            
            dayLabel.alpha = .6;
            dayLabel.font = [UIFont fontWithName:font size:smallFont];

            
            UILabel *speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(-40., 0., 40., rowHeight)];
            if ([format isEqualToString:@"HH"]) {
                speedLabel.text = [NSString stringWithFormat:@"%.2f", dayMax];
            } else {
                speedLabel.text = [NSString stringWithFormat:@"%.2f", dayAvg];
            }
            speedLabel.alpha = .7;
            speedLabel.textAlignment = NSTextAlignmentLeft;
            speedLabel.font = [UIFont fontWithName:font size:smallFont];
            
            
            [vmax addSubview:speedLabel];
            
//            [self.scrollView addSubview:vmax];
//            [self.scrollView addSubview:vavg];
//            [self.scrollView addSubview:vmin];
            
//            [self.scrollView addSubview:dayLabel];
            row++;
        }
    
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, rowHeight*row)];
    

    /*
     width for digit | percent
     
     
     */

    plot.points = points;
    [self.scrollView addSubview:plot];
    [plot redraw];
    plotAvg.points = pointsAvg;
    [self.scrollView addSubview:plotAvg];
    [plotAvg redraw];

    
    return;
    float paddingWidth = 110.;
    // can be faster!
    float widthForPercentage = frameWidth - paddingWidth - frameWidth * 0.2;
    for (UIView *view in [self.scrollView subviews]) {
        if (![view isKindOfClass:[UILabel class]]) {
            CGRect rect = view.frame;
            float percentageWidth = rect.size.width * widthForPercentage;
            [UIView animateWithDuration:1.2
                             animations:^{
                                 view.frame = CGRectMake(rect.origin.x, rect.origin.y, paddingWidth + percentageWidth, rect.size.height);
                                 
                                 if ([[view subviews] count] > 0) {
                                     UIView *l = [view subviews][0];
                                     CGRect lrect = l.frame;
                                     l.frame = CGRectMake(view.frame.size.width + 6., lrect.origin.y
                                                          , lrect.size.width, lrect.size.height);
                                 }
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

+ (UIColor*) getColor:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
    
    return [UIColor colorWithRed:100. / 255. * red / 100. green:100. / 255. * green / 100. blue: 100. / 255. * blue / 100. alpha:alpha];
}

@end
