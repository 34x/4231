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
@property (strong, nonatomic) IBOutlet UIAlertView *alertGameStart;
@property (strong, nonatomic) IBOutlet UIAlertView *alertSequenceSelect;
@property (strong, nonatomic) IBOutlet UIAlertView *alertResult;
//@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

//@property (nonatomic) UIView *board;

@property (nonatomic) NSDate *startedAt;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) int duration;
@property (nonatomic) int currentClickIndex;
@property (nonatomic) NSMutableArray *digits;
@property (nonatomic) int cols;
@property (nonatomic) int rows;
@property (nonatomic) BOOL gameReverse;
@property (nonatomic) BOOL gameWithLetters;
@property (nonatomic) NSUInteger gameTimeLimit;
@property (nonatomic, readwrite) float lastResult;
@property (nonatomic, readwrite) NSUInteger difficultyLevel;
@property (nonatomic, readwrite) NSUInteger sequenceLevel;
@property (nonatomic, readwrite) float nextLevelLimit;
@property (nonatomic, readwrite) NSArray *cellItems;
@end

@implementation NCGameViewController

- (void)viewWillDisappear:(BOOL)animated
{
//    NSLog(@"disappearing!");
    [self endGame:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"will appear");
    self.gameReverse = NO;
    self.gameWithLetters = NO;
    self.gameTimeLimit = 30;
    self.difficultyLevel = 0;
    self.sequenceLevel = 0;
    self.nextLevelLimit = 50.;
    [super viewWillAppear:animated];
//    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"did appear");
    [super viewDidAppear:animated];
    [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];

    NCSettings *settings = [[NCSettings alloc] init];
    self.cols = settings.cols;
    self.rows = settings.rows;

    self.headerRightButton.target = self;
    self.headerRightButton.action = @selector(headerRightButtonClick:);
    
    [self restartGame];

    UIButton *headerTitleButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    CGSize bsize = headerTitleButton.bounds.size;
    CGSize vsize = self.headerCenter.bounds.size;
    
    if (nil == self.headerCenterLabel) {
        self.headerCenterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, vsize.width - bsize.width, vsize.height)];
        self.headerCenterLabel.textAlignment = NSTextAlignmentCenter;
        [self.headerCenter addSubview:self.headerCenterLabel];
    }
    [self updateHeaderLabel];
}

- (void) headerRightButtonClick:(id)sender {
    [self selectGameType];
}

- (void) headerClick:(UIButton*)button {
    [self openStats];
}

-(void)onCellTouchDown:(UIButton*)sender {

}

-(void)onCellTouchUp:(UIButton*)sender {
    UILabel *l = [sender.subviews objectAtIndex:0];

    BOOL result = [self.game select:sender.tag value:l.text];

    if (result) {
        [self updateHeaderLabel];
        
        float progress = (float)self.game.currentIndex / (float)[self.game.items count];
        [self.progressBar setProgress:progress animated:YES];
        
        if (self.game.isComplete) {
            [self endGame:YES];
        }
        
        if (3 == self.difficultyLevel) {
            self.cellItems = [NCGame randomize:self.cellItems];
            [self drawBoard];
        }
        
    } else {
        // Vibarate if support, beep if not
//        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        // vibrate only if support
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    UIView *cellView = [sender superview];
    UIView *bgv = [[cellView subviews] objectAtIndex:0];

    if (result) {
        cellView.alpha = 0;
//        bgv.alpha = 1;
    } else {
//        bgv.alpha = 0.1;
    }
    [UIView animateWithDuration:.8
                     animations:^{
                         // do first animation
//                         sender.backgroundColor = nil;
//                         bgv.alpha = 0.6;
                         cellView.alpha = 1;
                     }];


}

- (void) updateHeaderLabel
{
//    if (0 == self.game.duration % 2) {
//        [self.headerCenterLabel setText:[self durationString]];
//    } else {
//        [self.headerCenterLabel setText:[NSString stringWithFormat:@"%lu", self.game.currentNumber]];
//    }
    
    NSUInteger left = self.game.timeLimit - [[self.game getDuration] floatValue];
    [self.headerCenterLabel setText:[NSString stringWithFormat:@"%lu", left]];
    
    float diff = [self percentWithPrevious];
    if (diff > self.nextLevelLimit || (.0 == diff && 0 == self.difficultyLevel)) {
        [self.headerCenterLabel setTextColor:[UIColor greenColor]];
        [self.progressBar setTintColor:[UIColor blueColor]];
    } else {
        [self.headerCenterLabel setTextColor:[UIColor redColor]];
        [self.progressBar setTintColor:[UIColor redColor]];
    }
}

- (void) timerTick {
    if (!self.game) {
        return;
    }
    if ([self.game getIsDone]) {
        [self endGame:YES];
    }
    [self updateHeaderLabel];
}

- (NSString*)durationString {

    NSUInteger minutes = [[self.game getDuration] intValue] / 60;
    NSUInteger seconds = [[self.game getDuration] intValue] - minutes*60;

    return [NSString stringWithFormat:@"%02lu:%02lu", minutes, seconds];
}

- (void) restartGame {

    NSLog(@"restart game");
    
//    [self performSelector:<#(SEL)#> withObject:<#(id)#>]
    
//    return;
    // remove old game data if needed
    [self endGame:NO];
    
    
    
    
    // init new game
    
    self.progressBar.progress = 0.0;
    // Do any additional setup after loading the view, typically from a nib.

    self.game = [[NCGame alloc] initWithTotal:self.cols*self.rows];
    self.game.timeLimit = self.gameTimeLimit;
    self.game.difficultyLevel = self.difficultyLevel;
    self.game.sequenceLevel = self.sequenceLevel;
    
    [self updateHeaderLabel];
    
    

    self.cellItems = [self.game getItems];

    NSString *msg = [self.game.sequence componentsJoinedByString:@" "];
    
    msg = [NSString stringWithFormat:@"%@\n→", msg];
    
    if (!self.alertGameStart) {
        self.alertGameStart = [[UIAlertView alloc]
                          initWithTitle:@"Ready?"
                          message: msg
                          delegate:self
                          cancelButtonTitle:@"Go"
                          otherButtonTitles:nil];
        self.alertGameStart.tag = 2;
    } else {
        [self.alertGameStart setMessage:msg];
    }
    

    if(![self.alertGameStart isVisible]) {
        [self.alertGameStart show];
    }
}

- (void)drawBoard {
    while ([[self.board subviews] count] > 0) {
        [[[self.board subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    
    float width = self.board.bounds.size.width / self.cols;
    float height = self.board.bounds.size.height / self.rows;
    float margin = 0.0;
    float y = 0.0;
    float x = 0.0;
    float size = width + width / 10.;

//    [UIColor colorWithRed:1. green:.49 blue:.16 alpha:1],
//    [UIColor colorWithRed:1. green:.69 blue:.16 alpha:1],
//    [UIColor colorWithRed:.984 green:.157 blue:.271 alpha:1],
//    [UIColor colorWithRed:.141 green:.882 blue:.73 alpha:1],
//    
//    [UIColor colorWithRed:.965 green:.624 blue:.40 alpha:1],
//    [UIColor colorWithRed:.965 green:.757 blue:.40 alpha:1],
//    [UIColor colorWithRed:.918 green:.38 blue:.455 alpha:1],
//    [UIColor colorWithRed:.255 green:.616 blue:.545 alpha:1],

//    [UIColor colorWithRed:.714 green:.302 blue:.0 alpha:1],
//    [UIColor colorWithRed:.0 green:.506 blue:.235 alpha:1],
//    [UIColor colorWithRed:.714 green:.161 blue:.0 alpha:.8],
//    [UIColor colorWithRed:.0 green:.443 blue:.396 alpha:1],
//    
//    [UIColor colorWithRed:.992 green:.576 blue:.271 alpha:1],

    
    NSArray *colors = @[
                       [UIColor redColor],
                       [UIColor orangeColor],
                       [UIColor yellowColor],
                       [UIColor greenColor],
                       [UIColor blueColor],
                       [UIColor purpleColor],
                       [UIColor brownColor],
                       [UIColor cyanColor],
                       [UIColor magentaColor]
                    ];
    

    NSArray *darkColors = @[[UIColor blueColor], [UIColor purpleColor]];
    
    
    NSArray *opacity = @[
                         [NSNumber numberWithFloat:.2],
                         [NSNumber numberWithFloat:.4],
                         [NSNumber numberWithFloat:.6],
                         [NSNumber numberWithFloat:.8],
                         [NSNumber numberWithFloat:1.]
                         ];
    
    
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
 
    NSArray *fontsTriple = @[//[NSNumber numberWithFloat:size/1.8],
//                            [NSNumber numberWithFloat:size/3],
//                            [NSNumber numberWithFloat:size/4],
                            [NSNumber numberWithFloat:size/5],
                            [NSNumber numberWithFloat:size/6],
                            ];
    
    
    for (int i = 0; i < [self.cellItems count]; i++) {
        NCCell *cell = [self.cellItems objectAtIndex:i];
        
        if (0 == i % self.cols && i > 1) {
            y = y + height + margin;
            x = 0.0;
        }
        
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        
        UIButton *v = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];

        UIView *vbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];

        [vbg setBackgroundColor:[UIColor whiteColor]];

        [cellView addSubview:vbg];
        [cellView addSubview:v];
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, width, height)];
        
        [l setTextAlignment:NSTextAlignmentCenter];
        [l setText: cell.text];
        if ([cell.text length] > 1) {
            [l setFont:[UIFont fontWithName:@"Helvetica" size: size/4]];
        } else {
            [l setFont:[UIFont fontWithName:@"Helvetica" size: size/2]];
        }
        [v addSubview:l];
        
        if (self.difficultyLevel > 0)
        {
            UIColor *randomColor;
            
            for (int r = 0; r < 100; r++) {
                randomColor = colors[(arc4random() % [colors count])];

                if (i > 0 && randomColor == ((NCCell*)self.cellItems[i - 1]).color) {
                    continue;
                }
                
                if (i >= self.cols && randomColor == ((NCCell*)self.cellItems[i - self.cols]).color) {
                    continue;
                }
                break;
            }
            
            cell.color = randomColor;
            [vbg setBackgroundColor:randomColor];
            vbg.alpha = 0.6;
            
            if ([darkColors containsObject:v.backgroundColor]) {
                l.textColor = [UIColor whiteColor];
            }
        }
        
        if (self.difficultyLevel > 1)
        {
            NSNumber *size;
            if ([cell.text length] > 2) {
                size = [fontsTriple objectAtIndex:(arc4random() % [fontsTriple count])];
            } else if ([cell.text length] > 1 ) {
                size = [fontsMulti objectAtIndex:(arc4random() % [fontsMulti count])];
            } else {
                size = [fonts objectAtIndex:(arc4random() % [fonts count])];
                
            }
            
            [l setFont:[UIFont fontWithName:@"Helvetica" size: [size floatValue]]];
        }
        
        if (self.difficultyLevel > 2)
        {
            l.alpha = [[opacity objectAtIndex:(arc4random() % [opacity count])] floatValue];
        }
        
        
        x = x + width + margin;
        
        [v addTarget:self action:@selector(onCellTouchDown:) forControlEvents:UIControlEventTouchDown];
        [v addTarget:self action:@selector(onCellTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        
        v.tag = i;
        
        [self.board addSubview:cellView];
    }
}

- (float) percentWithPrevious {
    float lastResult = self.lastResult;
    float speed = [self.game getSpeed];
    float diff;
    if (lastResult) {
        diff = speed / (lastResult / 100.);
    } else {
        diff = 0.;
    }

    return diff;
}

- (void) endGame:(BOOL) showResult{
    NSLog(@"endGame:%i", showResult);
    
    [self.timer invalidate];
    self.timer = nil;
    
    if (self.game) {
        [self.game finish];
    }
    
    [self updateHeaderLabel];
    NSString *nextLevel;
    if (showResult) {
        
        float diff = [self percentWithPrevious];
        
        if ([self.game getSpeed] > 0. && (diff > self.nextLevelLimit || .0 == diff)) {
            nextLevel = @"Next level!";
            self.lastResult = [self.game getSpeed];
            if (self.difficultyLevel < 3) {
                self.difficultyLevel++;
                NSLog(@"Next difficult %lu", (unsigned long)self.difficultyLevel);
            } else {
                self.difficultyLevel = 0;
                self.sequenceLevel++;
                NSLog(@"Next sequence %lu", self.sequenceLevel);
            }
        } else {
            nextLevel = @"Try hard for next level!";
        }

        NSString *nextLevelLimit = @"";
        if (self.lastResult) {
            float nextLimit = self.lastResult / 100. * self.nextLevelLimit;
            nextLevelLimit = [NSString stringWithFormat:@"\nNext level min speed: %.2f", nextLimit];
        }
        
        
        NSString *alertTitle = [NSString stringWithFormat:@"%@", nextLevel];
        NSString *alertMessage = [NSString stringWithFormat:@"Duration: %@\nSpeed: %.1f%@",
                                  [self durationString],
                                  [self.game getSpeed],
                                  nextLevelLimit
                                ];
        
        if (!self.alertResult) {
        
            self.alertResult = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                    delegate:self
                                                    cancelButtonTitle:@"Go!"
                                                    otherButtonTitles:nil];
            self.alertResult.tag = 0;
        } else {
            [self.alertResult setTitle:alertTitle];
            [self.alertResult setMessage:alertMessage];
        }
        
        [self.alertResult show];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (0 == alertView.tag) {
        if (0 == buttonIndex) {
            [self restartGame];
        } else if (1 == buttonIndex) {
            [self openStats];
        }
    } else if (self.alertSequenceSelect == alertView) {
        if (buttonIndex > 0) {
            self.sequenceLevel = buttonIndex - 1;
        }

        [self restartGame];
    } else if (self.alertGameStart == alertView) {
        
        [self drawBoard];
        
        [self.game start];
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
        }
    }
    
}

- (void) selectGameType {
    [self endGame:NO];
    
    if (!self.alertSequenceSelect) {
        
        self.alertSequenceSelect = [[UIAlertView alloc]
                                    initWithTitle:@"Which one?"
                                    message: @""
                                    delegate:self
                                    cancelButtonTitle:@"?"
                                    otherButtonTitles:nil];

        
        NSArray *params = [NCGame getSequencesParams];
        NSMutableArray *labels = [[NSMutableArray alloc] init];
        [params enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            NSDictionary *param = obj;
//            [labels addObject: [param objectForKey:@"label"]];
            [self.alertSequenceSelect addButtonWithTitle:[param objectForKey:@"label"]];
        }];

        self.alertSequenceSelect.tag = 1;
    }

    [self.alertSequenceSelect show];

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
