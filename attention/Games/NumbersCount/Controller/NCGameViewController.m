//
//  ViewController.m
//  attention
//
//  Created by Max on 20/09/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "NCGameViewController.h"
#import "NCGame.h"
#import "NCCell.h"
#import "NCStatsViewController.h"
#import "NCSettings.h"
#import <AudioToolbox/AudioServices.h>

@interface NCGameViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerCenter;
@property (strong, nonatomic) UILabel *headerCenterLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *headerRightButton;
@property (weak, nonatomic) IBOutlet UIView *quickMenu;


@property (weak, nonatomic) IBOutlet UIView *board;
//@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

//@property (nonatomic) UIView *board;

@property (nonatomic) NSDate *startedAt;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) int duration;
@property (nonatomic) int currentClickIndex;
@property (nonatomic) NSMutableArray *digits;
@property (nonatomic) int cols;
@property (nonatomic) int rows;

@end

@implementation NCGameViewController

- (void)viewWillDisappear:(BOOL)animated
{
//    NSLog(@"disappearing!");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NCSettings *settings = [[NCSettings alloc] init];
    self.cols = settings.cols;
    self.rows = settings.rows;

//    [[self.view subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSLog(@"%@", [obj class]);
//    }];
    
    
//    ((UIView*)[self.view subviews][0]).hidden = YES;
    
    
//    self.statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, paddingTop, self.view.bounds.size.width, statusBarHeight)];
//
    
//    NSLog(@"btn: %@", self.restartButton.frame);
    
//    UIButton *restartButton = [[UIButton alloc] initWithFrame:CGRectMake(self.statusBar.bounds.size.width - 50, 0, 44, 44)];
//    [self.restartButton setTitle:@"RSTRT" forState:UIControlStateNormal];
//    [self.restartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.headerRightButton.target = self;
    self.headerRightButton.action = @selector(headerRightButtonClick:);

//    [self.statusBar addSubview:self.durationLabel];

    
//    [self.view addSubview:self.statusBar];
    
    [self restartGame];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];

    UIButton *headerTitleButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    CGSize bsize = headerTitleButton.bounds.size;
    CGSize vsize = self.headerCenter.bounds.size;
    
//    float vcenter = vsize.height / 2. - bsize.height / 2.;

//    headerTitleButton.frame = CGRectMake(self.headerCenter.frame.size.width - bsize.width, vcenter, bsize.width, bsize.height);
    if (nil == self.headerCenterLabel) {
        self.headerCenterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, vsize.width - bsize.width, vsize.height)];
        self.headerCenterLabel.textAlignment = NSTextAlignmentCenter;
//    [self.headerCenter addSubview:headerTitleButton];
        [self.headerCenter addSubview:self.headerCenterLabel];
//    [self.headerTitle addTarget:self action:@selector(headerClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self updateHeaderLabel];
}

- (void) headerRightButtonClick:(id)sender {
//    [self performSegueWithIdentifier:@"numbers_count_settings" sender:self];
    [self restartGame];
}

- (void) headerClick:(UIButton*)button {
    [self openStats];
}

-(void)onCellTouchDown:(UIButton*)sender {

}

-(void)onCellTouchUp:(UIButton*)sender {

    BOOL result = [self.game select:sender.tag];

    if (result) {
        [self updateHeaderLabel];
        
        float progress = (float)self.game.currentIndex / (float)[self.game.items count];
        [self.progressBar setProgress:progress animated:YES];
//        self.progressBar.tintColor = [UIColor redColor];
        
        if (self.game.isComplete) {
            [self endGame];
        }
        sender.alpha = 0.1;
        [UIView animateWithDuration:0.5
                         animations:^{
                             // do first animation
                             sender.alpha = 1.0;
                         }];
    } else {
        // Vibarate if support, beep if not
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        // vibrate only if support
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    


//    UIColor *currentColor = sender.backgroundColor;
//    if (result) {
//        sender.backgroundColor = [UIColor greenColor];
//    } else {
//        sender.backgroundColor = [UIColor redColor];
//    }
    
//        sender.hidden = NO;
//    NSDate *dateShow = [NSDate dateWithTimeIntervalSinceNow:0];
    
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setTimeStyle:NSDateFormatterMediumStyle];

//    [[NSTimeInterval alloc] ]
//    NSDate *duration = [NSDate dateWithTimeInterval:1 sinceDate:self.startedAt];
//    NSString *dateString = [dateFormat stringFromDate:duration];
//    NSLog(@"%@", dateString);

}

- (void) updateHeaderLabel
{
    if (0 == self.game.duration % 2) {
        [self.headerCenterLabel setText:[self durationString]];
    } else {
        [self.headerCenterLabel setText:[NSString stringWithFormat:@"%lu", self.game.currentNumber]];
    }
}

- (void) timerTick {
    if (!self.game) {
        return;
    }
    [self updateHeaderLabel];
}

- (NSString*)durationString {
    
    NSUInteger minutes = self.game.duration / 60;
    NSUInteger seconds = self.game.duration - minutes*60;

    return [NSString stringWithFormat:@"%02lu:%02lu", minutes, seconds];
}

- (void) restartGame {
    while ([[self.board subviews] count] > 0) {
        [[[self.board subviews] objectAtIndex:0] removeFromSuperview];
    }

    int cols = self.cols;
    int rows = self.rows;
    

    NSArray *colors = [[NSArray alloc] initWithObjects:
                       [UIColor redColor],
                       [UIColor orangeColor],
                       [UIColor yellowColor],
                       [UIColor greenColor],
                       [UIColor purpleColor],
                       [UIColor blueColor],
                       [UIColor magentaColor],
                       [UIColor cyanColor],

                       nil];
    NSArray *darkColors = @[[UIColor blueColor], [UIColor purpleColor]];



    self.progressBar.progress = 0.0;
    // Do any additional setup after loading the view, typically from a nib.
    
    if (self.game) {
        [self.game finish];
    }
    
    self.game = [[NCGame alloc] initWithTotal:cols*rows];
    [self updateHeaderLabel];
    
    float width = self.board.bounds.size.width / cols;
    float height = self.board.bounds.size.height / rows;
    float margin = 0.0;
    float y = 0.0;
    float x = 0.0;
    float size = width + width / 10.;

    NSArray *fonts = @[[NSNumber numberWithFloat:size],
                       [NSNumber numberWithFloat:size/2],
                       [NSNumber numberWithFloat:size/3],
                       [NSNumber numberWithFloat:size/4],
                       [NSNumber numberWithFloat:size/5],
                       [NSNumber numberWithFloat:size/6],
//                       [NSNumber numberWithFloat:size/8],
                       ];
    
    NSArray *fontsMulti = @[//[NSNumber numberWithFloat:size/1.8],
                            [NSNumber numberWithFloat:size/2],
                            [NSNumber numberWithFloat:size/3],
                            [NSNumber numberWithFloat:size/4],
                            [NSNumber numberWithFloat:size/5],
                            [NSNumber numberWithFloat:size/6],
                       ];
    
    for (int i = 0; i < [self.game.items count]; i++) {
        NCCell *cell = [self.game.items objectAtIndex:i];
        
        if (0 == i % cols && i > 1) {
            y = y + height + margin;
            x = 0.0;
        }

        UIButton *v = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        UIColor *randomColor;
        
        for (int r = 0; r < 100; r++) {
            randomColor = colors[(arc4random() % [colors count])];

            if (i > 0 && randomColor == ((UIView*)[self.board subviews][i - 1]).backgroundColor) {
                continue;
            }
            
            if (i >= cols && randomColor == ((UIView*)[self.board subviews][i - cols]).backgroundColor) {
                continue;
            }
            break;
        }

        [v setBackgroundColor:randomColor];
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, width, height)];
        [l setTextAlignment:NSTextAlignmentCenter];
        [l setText:[NSString stringWithFormat:@"%lu", (unsigned long)cell.value]];
        if ([darkColors containsObject:v.backgroundColor]) {
            l.textColor = [UIColor whiteColor];
        }
        NSNumber *size;
        if (cell.value < 10) {
            size = [fonts objectAtIndex:(arc4random() % [fonts count])];
        } else {
            size = [fontsMulti objectAtIndex:(arc4random() % [fontsMulti count])];
        }
        
        [l setFont:[UIFont fontWithName:@"Helvetica" size: [size floatValue]]];
        [v addSubview:l];
        
        x = x + width + margin;
        
        [v addTarget:self action:@selector(onCellTouchDown:) forControlEvents:UIControlEventTouchDown];
        [v addTarget:self action:@selector(onCellTouchUp:) forControlEvents:UIControlEventTouchUpInside];

        v.tag = i;
        
        [self.board addSubview:v];
    }
    
    [self.game start];
    

}

- (void) endGame {

    [self updateHeaderLabel];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DONE"
                                                    message:[NSString stringWithFormat:@"Duration: %@\nSpeed: %.1f", [self durationString],[self.game getSpeed]]
                                                    delegate:self
                                                    cancelButtonTitle:@"Again!"
                                                    otherButtonTitles:@"Show stat", nil];

    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (0 == buttonIndex) {
        [self restartGame];
    } else if (1 == buttonIndex) {
        [self openStats];
    }
        
}

- (void) openStats {
    [self performSegueWithIdentifier:@"stats" sender:self];
//    StatsViewController *c = [[StatsViewController alloc] init];
    
//    [self presentViewController:c animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (float) random:(float)min :(float)max {
    return (((float)arc4random()/0x100000000)*(max-min)+min);
}

@end
