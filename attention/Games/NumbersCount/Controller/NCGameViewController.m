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
#import "GCHelper.h"
#import "NCStatsViewController.h"
#import "NCSettings.h"
#import <AudioToolbox/AudioServices.h>
#import "PiwikTracker.h"

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
@property (strong, nonatomic) NSString *sequenceId;
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
@property (weak, nonatomic) IBOutlet UIView *restartGameAlert;
@property (weak, nonatomic) IBOutlet UIButton *sequencePreviewButton;
@property (weak, nonatomic) IBOutlet UIButton *beginGameButton;

@property (nonatomic, readwrite) NCSettings *settings;
@end

@implementation NCGameViewController

- (void)viewWillDisappear:(BOOL)animated
{
    self.restartGameAlert.hidden = YES;
    NSLog(@"disappearing!");
    NCSettings *settings = [[NCSettings alloc] init];
    settings.sequence = (int)self.sequenceLevel;
    [settings save];
    [self endGame:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"will appear");
    self.gameReverse = NO;
    self.gameWithLetters = NO;
    self.gameTimeLimit = 25;
    self.difficultyLevel = 0;
    self.sequenceLevel = 0;
    self.nextLevelLimit = 60.; // %
    
    self.settings = [[NCSettings alloc] init];
    
    [super viewWillAppear:animated];
//    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [[PiwikTracker sharedInstance] sendView:@"game"];
    NSLog(@"did appear");
    [super viewDidAppear:animated];
    [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];

    NCSettings *settings = [[NCSettings alloc] init];
    self.cols = settings.cols;
    self.rows = settings.rows;
    self.sequenceLevel = settings.sequence;

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
    
    [self.beginGameButton addTarget:self action:@selector(beginGame) forControlEvents:UIControlEventTouchUpInside];
    [self.sequencePreviewButton addTarget:self action:@selector(restartGame) forControlEvents:UIControlEventTouchUpInside];
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
        
        float progress = (float)self.game.currentIndex / (float)self.game.sequenceLength;
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

    if (result) {
        cellView.alpha = 0;
//        bgv.alpha = 1;
    } else {
        [UIView animateWithDuration:.1
         animations:^{
             cellView.transform = CGAffineTransformRotate(cellView.transform, M_PI / 10.);
             
         } completion: ^(BOOL finished) {
             [UIView animateWithDuration:.2
                  animations:^{
                      cellView.transform = CGAffineTransformRotate(cellView.transform, M_PI / -5.);
                      
                  } completion: ^(BOOL finished) {
                      [UIView animateWithDuration:.1
                                       animations:^{
                                           cellView.transform = CGAffineTransformRotate(cellView.transform, M_PI / 10.);
                                           
                                       } completion: ^(BOOL finished) {
                                           
                                       }];

                  }];

         }];
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
    
//    float diff = [self percentWithPrevious];
//    if (diff > self.nextLevelLimit || (.0 == diff && 0 == self.difficultyLevel)) {
//        [self.headerCenterLabel setTextColor:[UIColor greenColor]];
//        [self.progressBar setTintColor:[UIColor blueColor]];
//    } else {
//        [self.headerCenterLabel setTextColor:[UIColor redColor]];
//        [self.progressBar setTintColor:[UIColor redColor]];
//    }
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

    self.sequenceLevel = [NCGame checkSequenceLevel:self.sequenceLevel];
    
    NSDictionary *sequenceParams = [NCGame getSequenceParams:self.sequenceLevel];
    NSMutableDictionary *ssettings = [self.settings getSequenceSettings:[sequenceParams objectForKey:@"id"]];

    NSUInteger sequenceLength = [ssettings[@"sequenceLength"] integerValue];

 
    NSInteger boardIndex = [NCSettings getCloserBoardIndex:sequenceLength];
    NSInteger currentBoardIndex = [ssettings[@"currentBoard"] integerValue];
    
    
    // if in some cases we have wrong board size, fix it here
    if (currentBoardIndex < boardIndex) {
        ssettings[@"currentBoard"] = [NSNumber numberWithInteger: boardIndex];
    }
    
    self.sequenceId = sequenceParams[@"id"];
    

    [self.settings save];
    
    NSArray *boards = [NCSettings getBoardSizes];
    NSArray *cBoard = [boards objectAtIndex:[ssettings[@"currentBoard"] integerValue]];
//    sequenceLength = 2;
//    cBoard = [boards objectAtIndex:8]; // 11 73, 12 91
//    self.difficultyLevel = 2;
    
    self.cols = [cBoard[0] intValue];
    self.rows = [cBoard[1] intValue];
    
    [[PiwikTracker sharedInstance] sendViews: @"game", @"start", self.sequenceId, nil];
    
    self.game = [[NCGame alloc] initWithTotal: self.cols * self.rows ];
    self.game.timeLimit = (self.gameTimeLimit * self.cols * self.rows);
    self.game.difficultyLevel = self.difficultyLevel;
    self.game.sequenceLevel = self.sequenceLevel;
    self.game.sequenceLength = sequenceLength;
    
    if (0 == self.difficultyLevel) {
        ssettings[@"lastResult"] = @0.0;
        [self.settings save];
    }
    
    [self updateHeaderLabel];
    
    

    self.cellItems = [self.game getItems];

    NSString *sep;
    if ([self.game.sequence count] < 5) {
        sep = @"  ";
    } else if ([self.game.sequence count] < 8) {
        sep = @" ";
    } else {
        sep = @"";
    }
    
//    show symbols horisontaly
//    if (0 == arc4random() % 2) {
//        sep = @"\n";
//    }
    
    NSString *msg = [self.game.sequence componentsJoinedByString:sep];
    
//    msg = [NSString stringWithFormat:@"%@\n\n→", msg];
    
    [self.sequencePreviewButton setTitle:msg forState:UIControlStateNormal];
    
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
    
    self.restartGameAlert.hidden = NO;

}

- (void)drawBoard {
    
    __block NSInteger cellsCount = [[self.board subviews] count];
    
    if ( 0 == cellsCount) {
        [self drawNewCells];
        return;
    }
    
    for (int i = 0; i < cellsCount; i++) {
        NSLog(@" %li", cellsCount);
        UIView *cell = (UIView*)[[self.board subviews] objectAtIndex:i];
        [UIView animateWithDuration:0.1 animations:^{
            cell.alpha = 0.1;
            cell.transform = CGAffineTransformScale(cell.transform, 0.1, 0.1);
        } completion:^(BOOL finished){
            [cell removeFromSuperview];
            cellsCount--;

            if (0 == cellsCount) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self drawNewCells];
                });
            }
        }];
    }
    
    
    
}

- (void) drawNewCells {
    float width = self.board.bounds.size.width / self.cols;
    float height = self.board.bounds.size.height / self.rows;
    float margin = 0.0;
    float y = 0.0;
    float x = 0.0;
    
    float size = MIN(width, height); // + width / 10. + width;
    size = size * 1.4;
    
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
                         //                         [NSNumber numberWithFloat:.2],
                         [NSNumber numberWithFloat:.4],
                         [NSNumber numberWithFloat:.6],
                         [NSNumber numberWithFloat:.8],
                         [NSNumber numberWithFloat:1.]
                         ];
    
    
    NSArray *fonts = @[
                       //                       [NSNumber numberWithFloat:size],
                       [NSNumber numberWithFloat:size/2],
                       [NSNumber numberWithFloat:size/3],
                       [NSNumber numberWithFloat:size/4],
                       //                       [NSNumber numberWithFloat:size/5],
                       //                       [NSNumber numberWithFloat:size/6],
                       //                       [NSNumber numberWithFloat:size/8],
                       ];
    
    NSArray *fontsMulti = @[//[NSNumber numberWithFloat:size/1.8],
                            [NSNumber numberWithFloat:size/2],
                            [NSNumber numberWithFloat:size/3],
                            [NSNumber numberWithFloat:size/4],
                            [NSNumber numberWithFloat:size/5],
                            //                            [NSNumber numberWithFloat:size/6],
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
        

        __block float alpha = cellView.alpha;
        __block CGAffineTransform transform = cellView.transform;
        
        [self.board addSubview:cellView];
        cellView.alpha = 0.0;
        cellView.transform = CGAffineTransformScale(transform, 0.1, 0.1);
        
        [UIView animateWithDuration:0.1 animations:^{
            cellView.transform = CGAffineTransformScale(transform, 1.0, 1.0);
            cellView.alpha = alpha;
        }];
    }
}


- (void) endGame:(BOOL) showResult{
//    NSLog(@"endGame:%i", showResult);
    
    [self.timer invalidate];
    self.timer = nil;

    NSDictionary *result;
    float gameScore = .0;
    if (self.game) {
        result = [self.game finish];
        gameScore = [[NCGame getScore:result] floatValue];
        
    }
    
    NSArray *winMsgs = @[@"win1", @"win2", @"win3"];
    NSArray *looseMsgs = @[@"loose1", @"loose2", @"loose3", @"loose4"];
    
    [self updateHeaderLabel];
    
    NSString *msgTitle = NSLocalizedString(looseMsgs[arc4random() % [looseMsgs count]], nil);
    
    if (showResult) {
        NSMutableDictionary *ssettings = [self.settings getSequenceSettings:[NCGame getSequenceId:self.sequenceLevel]];
        
        float lastResult = [ssettings[@"lastResult"] floatValue];
        
        float diff = .0;
        if (gameScore > .0 && lastResult > .0) {
            diff = gameScore / (lastResult / 100.);
        }
        
        [[GCHelper sharedInstance] reportScore:gameScore*100];
        
        int solved = [[ssettings objectForKey:@"solved" ] intValue];
        
        int errorsLimit = 6;
        int nextBoardLimitFactor = 6;
        int sequenceLength = [ssettings[@"sequenceLength"] intValue];

        [[PiwikTracker sharedInstance] sendViews: @"game", @"finish", self.sequenceId, nil];
        
        if (self.game.clickedWrong > 0) {
            lastResult = 0;
            int errors = [ssettings[@"errors"] intValue] + 1;
            ssettings[@"errors"] = [NSNumber numberWithInt:errors];
            
            if (errors >= errorsLimit) {
                ssettings[@"errors"] = [NSNumber numberWithInt:0];
                ssettings[@"solved"] = [NSNumber numberWithInt:0];
                
                if (sequenceLength > 2) {
                    
                    NSUInteger boardIndex = [NCSettings getCloserBoardIndex:sequenceLength];
                    NSUInteger currentIndex = [ssettings[@"currentBoard"] integerValue];
                    
                    // if we have not in initial board for this sequence. We decrase board size
                    if (currentIndex > boardIndex) {
                        boardIndex--;
                        ssettings[@"currentBoard"] = [NSNumber numberWithInteger:boardIndex];
                        
                        [[PiwikTracker sharedInstance] sendEventWithCategory:@"game"
                              action:@"decrease_board"
                                name:self.sequenceId
                               value:@1
                         ];

                    } else { // if we at start of board for this sequence length we decrase sequence length
                        sequenceLength--;
//                        boardIndex--;
                        boardIndex = [NCSettings getCloserBoardIndex:sequenceLength];

                        ssettings[@"currentBoard"] = [NSNumber numberWithInteger:boardIndex];
                        ssettings[@"sequenceLength"] = [NSNumber numberWithInt:sequenceLength];
                        
                        [[PiwikTracker sharedInstance] sendEventWithCategory:@"game"
                              action:@"decrease_sequence"
                                name:self.sequenceId
                               value:@1
                         ];
                    }


                    
                } else {
                    NSUInteger currentIndex = [ssettings[@"currentBoard"] integerValue];

                    if (currentIndex > 0) {
                        currentIndex--;
                        ssettings[@"currentBoard"] = [NSNumber numberWithInteger:currentIndex];
                        
                        [[PiwikTracker sharedInstance] sendEventWithCategory:@"game"
                              action:@"decrease_board"
                                name:self.sequenceId
                               value:@1
                         ];
                        
                    }
                    
                }
                
            }
            
        } else if (gameScore > 0. && (diff > self.nextLevelLimit || .0 == diff)) {
            msgTitle = NSLocalizedString(winMsgs[arc4random()%[winMsgs count]], nil);
            
            lastResult = gameScore;
            solved++;
            ssettings[@"solved"] = [NSNumber numberWithInt:solved];
            
            if (self.difficultyLevel < 3) {
                self.difficultyLevel++;
            } else {
                ssettings[@"errors"] = [NSNumber numberWithInt:0];
                // next sequence length
                if (self.game.total > self.game.sequenceLength * nextBoardLimitFactor) {

                    ssettings[@"solved"] = [NSNumber numberWithInt:0];
                    ssettings[@"sequenceLength"] = [NSNumber numberWithInt:++sequenceLength];

                    NSUInteger boardIndex = [NCSettings getCloserBoardIndex:sequenceLength];
                    ssettings[@"currentBoard"] = [NSNumber numberWithInteger:boardIndex];
                    
                    [[PiwikTracker sharedInstance] sendEventWithCategory:@"game"
                        action:@"increase_sequence"
                        name:self.sequenceId
                        value:@1
                     ];
                    
                } else { // increase the board size
                    ssettings[@"currentBoard"] = [NSNumber numberWithInt:[ssettings[@"currentBoard"] intValue] + 1];
                    
                    [[PiwikTracker sharedInstance] sendEventWithCategory:@"game"
                          action:@"increase_board"
                            name:self.sequenceId
                           value:@1
                     ];
                }
                
                // change sequence
                self.sequenceLevel++;

                self.difficultyLevel = 0;
            }
        }
        
        [self.settings save];
        
        NSString *nextLevelLimit = @"";
        if (lastResult) {
            float nextLimit = lastResult / 100. * self.nextLevelLimit;
            nextLevelLimit = [NSString stringWithFormat:@"\nNext level limit: %.2f", nextLimit];
        }
        
        ssettings[@"lastResult"] = [NSNumber numberWithFloat:lastResult];
        
        NSString *alertTitle = msgTitle;

//        NSString *alertMessage = [NSString
//                                  stringWithFormat:@"Score: %.2f\
//                                  \nDuration: %@\
//                                  \nSpeed: %.1f\
//                                  \nDifficulty: %lu\
//                                  \nSequence: %lu\
//                                  \nClicked: %lu\
//                                  \nWrong:%lu\
//                                  \n%@\
//                                  \nnextBoard %@",
//                                  gameScore,
//                                  [self durationString],
//                                  [self.game getSpeed],
//                                  dlevel,
//                                  slevel,
//                                  self.game.clicked,
//                                  self.game.clickedWrong,
//                                  nextLevelLimit,
//                                  nextBoard
//                                ];

        
        NSString *alertMessage = [NSString stringWithFormat:@"%@\n",
                                  [NSString stringWithFormat:NSLocalizedString(@"you_score",nil), gameScore ]
                ];
//        NSLog(@"%@", self.sequenceId);
        if ([@"randomFlags" isEqualToString:self.sequenceId]) {
            NSDictionary *flags = @{
                                    @"🇦🇺" : @"Australia",
                                    @"🇦🇹" : @"Austria",
                                    @"🇧🇪" : @"Belgium",
                                    @"🇧🇷" : @"Brazil",
                                    @"🇨🇦" : @"Canada",
                                    @"🇨🇱" : @"Chile",
                                    @"🇨🇳" : @"China",
                                    @"🇨🇴" : @"Colombia",
                                    @"🇩🇰" : @"Denmark",
                                    @"🇫🇮" : @"Finland",
                                    @"🇫🇷" : @"France",
                                    @"🇩🇪" : @"Germany",
                                    @"🇭🇰" : @"Hong Kong",
                                    @"🇮🇳" : @"India",
                                    @"🇮🇩" : @"Indonesia",
                                    @"🇮🇪" : @"Ireland",
                                    @"🇮🇱" : @"Israel",
                                    @"🇮🇹" : @"Italy",
                                    @"🇯🇵" : @"Japan",
                                    @"🇰🇷" : @"Korea",
                                    @"🇲🇴" : @"Macao",
                                    @"🇲🇾" : @"Malaysia",
                                    @"🇲🇽" : @"Mexico",
                                    @"🇳🇱" : @"Netherland",
                                    @"🇳🇿" : @"New Zealand",
                                    @"🇳🇴" : @"Norway",
                                    @"🇵🇭" : @"Philippines",
                                    @"🇵🇱" : @"Poland",
                                    @"🇵🇹" : @"Portugal",
                                    @"🇵🇷" : @"Puerto Rico",
                                    @"🇷🇺" : @"Russia",
                                    @"🇸🇦" : @"Saudi Arabia",
                                    @"🇸🇬" : @"Singapore",
                                    @"🇿🇦" : @"South Africa",
                                    @"🇪🇸" : @"Spain",
                                    @"🇸🇪" : @"Sweden",
                                    @"🇨🇭" : @"Switzerland",
                                    @"🇹🇷" : @"Turkey",
                                    @"🇬🇧" : @"Great Britain",
                                    @"🇺🇸" : @"USA",
                                    @"🇦🇪" : @"United Arab Emirates",
                                    @"🇻🇳" : @"Vietnam"
            };
            
//            NSLog(@"%@", self.game.sequence);
            
            for (int i = 0; i < [self.game.sequence count]; i++) {
                NSString *flag = self.game.sequence[i];
                NSString *country = [flags objectForKey:flag];
                
//                NSLog(@"flag %@", flag);

                if (country) {
                    alertMessage = [NSString stringWithFormat:@"%@\n%@ %s",
                                    alertMessage, self.game.sequence[i], [country UTF8String]];
                }
                
            }
        }
        
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
            self.difficultyLevel = 0;
        }

        self.sequenceLevel = [NCGame checkSequenceLevel:self.sequenceLevel];
        NSDictionary *sequenceParams = [NCGame getSequenceParams:self.sequenceLevel];
        self.sequenceId = sequenceParams[@"id"];

        [[PiwikTracker sharedInstance] sendViews: @"game", @"select_type_with", self.sequenceId, nil];
        
        [self restartGame];
    } else if (self.alertGameStart == alertView) {
        
    }
    
}

- (void)beginGame {
    [self drawBoard];
    
    self.restartGameAlert.hidden = YES;
    
    [self.game start];
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    }
}

- (void) selectGameType {
    [self endGame:NO];

    [[PiwikTracker sharedInstance] sendViews: @"game", @"select_type_from", self.sequenceId, nil];
    
    if (!self.alertSequenceSelect) {
        
        self.alertSequenceSelect = [[UIAlertView alloc]
                                    initWithTitle:NSLocalizedString(@"Which one?", nil)
                                    message: nil
                                    delegate:self
                                    cancelButtonTitle:@"?"
                                    otherButtonTitles:nil];

        
        NSArray *params = [NCGame getSequencesParams];

        [params enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            NCGame *tmpGame = [[NCGame alloc] initWithTotal:6];
            NSArray *seq = [tmpGame getSequence:idx difficultyLevel:0];
 
            [self.alertSequenceSelect addButtonWithTitle:[seq componentsJoinedByString:@" "]];
//            [self.alertSequenceSelect addButtonWithTitle:[param objectForKey:@"label"]];
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
