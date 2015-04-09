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
    self.nextLevelLimit = 20.;
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
        sender.alpha = 0.01;
        [UIView animateWithDuration:1.
                         animations:^{
                             // do first animation
                             sender.alpha = 1.0;
                         }];
        
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

}

- (void) updateHeaderLabel
{
//    if (0 == self.game.duration % 2) {
//        [self.headerCenterLabel setText:[self durationString]];
//    } else {
//        [self.headerCenterLabel setText:[NSString stringWithFormat:@"%lu", self.game.currentNumber]];
//    }
    
    NSUInteger left = self.game.timeLimit - self.game.duration;
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
    if (self.game.isDone) {
        [self endGame:YES];
    }
    [self updateHeaderLabel];
}

- (NSString*)durationString {
    
    NSUInteger minutes = self.game.duration / 60;
    NSUInteger seconds = self.game.duration - minutes*60;

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
    self.game.timeLimit = 30;
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
        
        UIButton *v = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, width, height)];
        [v setBackgroundColor:[UIColor whiteColor]];
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
                
                if (i > 0 && randomColor == ((UIView*)[self.board subviews][i - 1]).backgroundColor) {
                    continue;
                }
                
                if (i >= self.cols && randomColor == ((UIView*)[self.board subviews][i - self.cols]).backgroundColor) {
                    continue;
                }
                break;
            }
            
            [v setBackgroundColor:randomColor];
            
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
        
        v.tag = cell.value;
        
        [self.board addSubview:v];
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
        NSString *buttonText;
        
        if (diff > self.nextLevelLimit || .0 == diff) {
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
            buttonText = @"Next!";
        } else {
            nextLevel = @"Try hard for next level!";
            buttonText = @"Again!";
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
                                                    cancelButtonTitle:buttonText
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
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
        }
        
    }
    
}

- (void) selectGameType {
    [self endGame:NO];
    
    if (!self.alertSequenceSelect) {
        
        self.alertSequenceSelect = [[UIAlertView alloc]
                                    initWithTitle:@"Wich one?"
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
