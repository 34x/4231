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
#import <iAd/iAd.h>
#import "PiwikTracker.h"
#import "ATSettings.h"
#import "BannerViewController.h"
#import "NCShapeView.h"

NSInteger const ButtonTag = 718;

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
@property (nonatomic) NSUInteger cols;
@property (nonatomic) NSUInteger rows;
@property (nonatomic) BOOL gameReverse;
@property (nonatomic) BOOL gameWithLetters;
@property (nonatomic) NSUInteger gameTimeLimit;
@property (nonatomic, readwrite) float lastResult;
@property (nonatomic, readwrite) NSUInteger difficultyLevel;
@property (nonatomic, readwrite) NSUInteger sequenceLevel;
@property (nonatomic, readwrite) NSArray *cellItems;
@property (weak, nonatomic) IBOutlet UIView *restartGameAlert;
@property (weak, nonatomic) IBOutlet UIView *popupAskAtEnd;

@property (nonatomic, readwrite) NCSettings *settings;


@property (nonatomic) UIView *lastTouchedCell;
@end

@implementation NCGameViewController


- (void)viewWillDisappear:(BOOL)animated
{
    self.restartGameAlert.hidden = YES;

    NCSettings *settings = [[NCSettings alloc] init];
    settings.sequence = (int)self.sequenceLevel;
    [settings save];
    [self endGame:NO];
}

- (void)viewWillAppear:(BOOL)animated {

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [[BannerViewController instance] setBannerActive:NO];
    
    self.gameReverse = NO;
    self.gameWithLetters = NO;
    self.gameTimeLimit = 25;
    self.difficultyLevel = 0;
    self.sequenceLevel = 0;
    
    [super viewWillAppear:animated];
//    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[PiwikTracker sharedInstance] sendView:@"game"];

    [super viewDidAppear:animated];
    [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];


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


-(void)onCellTouchUp:(UIButton*)sender {
    UILabel *l = [sender.subviews objectAtIndex:0];
    _lastTouchedCell = [sender superview];
    

    BOOL result = [self.game select:l.text];

    if (result) {
        [self updateHeaderLabel];
        
        float progress = (float)self.game.currentIndex / (float)self.game.sequenceLength;
        [self.progressBar setProgress:progress animated:YES];
        
        
        
        if (!self.game.isDone)
        {
            self.cellItems = (NSArray*)[NCGame randomize:[self.cellItems mutableCopy]];
            [self drawBoard];
        }
        
    } else {
//        Vibarate if support, beep if not
//        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//        vibrate only if support
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    if (self.game.isDone) {
        [self endGame:YES];
    }
    
    
    UIView *v = sender.superview;
    
    CGAffineTransform transform = v.transform;
    if (result) {
        v.alpha = 0;
        v.transform = CGAffineTransformScale(transform, 0.8, 0.8);
    } else {
        // shake
        [UIView animateWithDuration:.1
         animations:^{
             v.transform = CGAffineTransformRotate(v.transform, M_PI / 10.);
             
         } completion: ^(BOOL finished) {
             [UIView animateWithDuration:.2
                  animations:^{
                      v.transform = CGAffineTransformRotate(v.transform, M_PI / -5.);
                      
                  } completion: ^(BOOL finished) {
                      [UIView animateWithDuration:.1
                                       animations:^{
                                           v.transform = CGAffineTransformRotate(v.transform, M_PI / 5.);
                                           
                                       } completion: ^(BOOL finished) {
                                           
                                       }];

                  }];

         }];
    }
    [UIView animateWithDuration:.8
                     animations:^{
                         v.alpha = 1;
                         v.transform = CGAffineTransformScale(transform, 1.0, 1.0);
                     }];


}

- (void) updateHeaderLabel
{
    NSUInteger left = self.game.timeLimit - [[self.game getDuration] floatValue];
    [self.headerCenterLabel setText:[NSString stringWithFormat:@"%lu", left]];
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

    return [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)minutes, (unsigned long)seconds];
}

- (void) restartGame {
    NSLog(@"restart game");
    
    // remove old game data if needed
//    [self endGame:NO];
    
    
    self.progressBar.progress = 0.0;
    // Do any additional setup after loading the view, typically from a nib.

    
    [[PiwikTracker sharedInstance] sendViews: @"game", @"start", self.sequenceId, nil];

    
    
    [self updateHeaderLabel];
    
    
    self.cols = self.game.cols;
    self.rows = self.game.rows;

    self.cellItems = self.game.items;
    
    [self drawBoard];
    
    
    [self.game start];
}

- (void)drawBoard {
    
    NSInteger cellsCount = [[self.board subviews] count];
    
    if ( 0 == cellsCount) {
        [self drawNewCells];
        return;
    }
    
    
    [self clearBoard:^{
        [self drawNewCells];
    }];
    
    
}


- (void)clearBoard:(void(^)())completion {
    
    __block NSInteger cellsCount = [[self.board subviews] count];
    
    if(!_lastTouchedCell) {
        _lastTouchedCell = [self.board.subviews firstObject];
    }
    
    
    [UIView animateWithDuration:0.2 animations:^{
        _lastTouchedCell.transform = CGAffineTransformScale(_lastTouchedCell.transform, 0.9, 0.9);
    }];
    
    
    
    for (int i = 0; i < cellsCount; i++) {
        UIView *cell = (UIView*)[[self.board subviews] objectAtIndex:i];
        if (_lastTouchedCell && _lastTouchedCell == cell) {
            continue;
        }
        cell.layer.shouldRasterize = YES;
        [UIView animateWithDuration:(arc4random() % 10 * (self.game.difficultyLevel + 1)) / 20.0
                              delay:(arc4random() % 80) / 100.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             cell.alpha = 0.0;
                             
                             cell.center = _lastTouchedCell.center;
                             cell.transform = CGAffineTransformRotate(cell.transform, 720);
                             
                         } completion:^(BOOL finished){
                             [cell removeFromSuperview];
                             cellsCount--;
                             
                             [UIView animateWithDuration:0.2 animations:^{
                                 _lastTouchedCell.transform = CGAffineTransformScale(_lastTouchedCell.transform, 1.04, 1.04);
                             }];
                             
                             
                             if (1 == cellsCount) {
                                 [UIView animateWithDuration:0.4
                                                  animations:^{
                                                      _lastTouchedCell.alpha = 0.1;
                                                      _lastTouchedCell.transform = CGAffineTransformScale(_lastTouchedCell.transform, 0.01, 0.01);
                                                  }
                                                  completion:^(BOOL finished){
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [_lastTouchedCell removeFromSuperview];
                                                          _lastTouchedCell = nil;
                                                            completion();
                                                          
                                                      });
                                                  }];
                             }
                             else if (0 == cellsCount) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                    completion();
                                 });
                             }
                             
                         }];
    }
}

- (void) drawNewCells {
    
    
    float width = self.board.bounds.size.width / self.cols;
    float height = self.board.bounds.size.height / self.rows;
    
    float centerX = width / 2.0;
    float centerY = height / 2.0;

    CGPoint cellCenter = CGPointMake(centerX, centerY);
    
    
    float y = 0;
    float x = 0;
    
    float min = MIN(width, height); // + width / 10. + width;
    min = min * 0.8;
    float size = min * 0.9;
    CGFloat iconSize = min * 0.5;
    
    NSArray *colors = @[
                        
                        [self colorWithRed:255 green:212 blue:65],
                        [[self colorWithRed:255 green:212 blue:65] colorWithAlphaComponent:0.5],
    
                        [self colorWithRed:171 green:112 blue:255],
                        [[self colorWithRed:171 green:112 blue:255] colorWithAlphaComponent:0.5],
    
                        [self colorWithRed:232 green:85 blue:64],
                        [[self colorWithRed:232 green:85 blue:64] colorWithAlphaComponent:0.5],
                        
                        [self colorWithRed:90 green:221 blue:232],
                        [[self colorWithRed:90 green:221 blue:232] colorWithAlphaComponent:0.5],
            
                        
                        [self colorWithRed:184 green:255 blue:133],
                        [[self colorWithRed:184 green:255 blue:133] colorWithAlphaComponent:0.5],
                        
                        
                        
                        
//                        [UIColor redColor],
//
//                        [UIColor orangeColor],
//                        
//                        [UIColor yellowColor],
//                        [UIColor greenColor],
//                        [UIColor blueColor],
//                        [UIColor purpleColor],
//                        [UIColor brownColor],
//                        [UIColor cyanColor],
//                        [UIColor magentaColor]
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
    
    
    NSLog(@"current game sequence: %@", [self.game.sequence componentsJoinedByString:@", "]);
    
    BOOL isTextSequence =  ![self.game.sequenceId isEqualToString:@"flags"]
                        && ![self.game.sequenceId isEqualToString:@"emoji"]
                        && ![self.game.sequenceId isEqualToString:@"faces"];
    
    BOOL useCrazy = self.game.difficultyLevel > 1;
    
    
    NSArray<UIView*> *crazyCells;
    if (useCrazy) {
        crazyCells = [self.game getCrazyCellsForSize:self.board.bounds.size andCount:self.game.total];
        crazyCells = [crazyCells sortedArrayUsingComparator:^NSComparisonResult(UIView *obj1, UIView *obj2) {
            CGPoint o1 = obj1.frame.origin;
            CGPoint o2 = obj2.frame.origin;
            if ((o1.x > o2.x && o1.y >= o2.y) || o1.y > o2.y) {
                return NSOrderedDescending;
            } else if ((o1.x < o2.x && o1.y < o2.y) || o1.y < o2.y) {
                return  NSOrderedAscending;
            }
            
            return NSOrderedSame;
        }];
    }
    
    
    if (useCrazy && crazyCells && crazyCells.count != self.cellItems.count) {
        useCrazy = NO;
        
        NSLog(@"Could not use crazy because not enought cells %li/%li", crazyCells.count, self.cellItems.count);
    }
    
    NSLog(@"Use crazy %i, difficulty: %li", useCrazy, self.game.difficultyLevel);
    
    for (int i = 0; i < [self.cellItems count]; i++) {
        NCCell *cell = [self.cellItems objectAtIndex:i];
        
        if (0 == i % self.cols && i > 1) {
            y = y + height;
            x = 0;
        }

        UIView *cellView;
        if (useCrazy) {
            cellView = crazyCells[i];
            cellCenter = CGPointMake(cellView.frame.size.width / 2.0, cellView.frame.size.height / 2.0);
        } else {
            cellView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        }
        
        
        cellView.backgroundColor = [UIColor clearColor];
        
        UIButton *v = [[UIButton alloc] initWithFrame:cellView.frame];
        v.tag = ButtonTag;
        v.center = cellCenter;
        
        
        NSArray *types = @[
            NCShapeViewTypeBox,
//            NCShapeViewTypeTriangle,
            NCShapeViewTypeCircle, NCShapeViewTypePyramid, NCShapeViewTypeOcto
        ];
        
        
        NCShapeView *vbg;
        NSString *type = types[arc4random() % types.count];
        if (useCrazy) {
            min = MIN(cellView.frame.size.width, cellView.frame.size.height) * 0.8;
            size = min * 1.2;
            iconSize = min * 0.7;
            
            if (min > 52) {
                NSArray *multiply = @[@0.8, @0.9, @1.0, @1.1, @1.2, @1.4];
                size = min * [multiply[arc4random() % multiply.count] floatValue];
                NSArray *multiplyIcon = @[@0.5, @0.6, @0.7, @0.8, @0.9];
                iconSize = min * [multiplyIcon[arc4random() % multiplyIcon.count] floatValue];
            }
            
            vbg = [[NCShapeView alloc] initWithFrame:CGRectMake(0, 0, min, min) andType:type];
            vbg.drawShape = NO;
        } else {
            vbg = [[NCShapeView alloc] initWithFrame:CGRectMake(0, 0, min, min) andType:type];
        }
//        vbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, min, min)];
//        UIView *vbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, min, min)];
        vbg.center = cellCenter;
//        vbg.layer.cornerRadius = min / 2.0;
//        vbg.layer.masksToBounds = YES;
        
        
        
        [cellView addSubview:vbg];
        [cellView addSubview:v];
        
        CGRect labelFrame;
        
        labelFrame = CGRectMake(0, 0, min, min);
        
        UILabel *l = [[UILabel alloc] initWithFrame:labelFrame];
        l.center = CGPointMake(v.frame.size.width / 2.0, v.frame.size.height / 2.0);
        
        [l setTextAlignment:NSTextAlignmentCenter];
        [l setText: cell.text];
        if ([cell.text length] > 1) {
            [l setFont:[UIFont fontWithName:@"Helvetica" size: size/4]];
        } else {
            [l setFont:[UIFont fontWithName:@"Helvetica" size: size/2]];
        }
        [v addSubview:l];
        
        
//        if (self.difficultyLevel > 0)
        if(self.game.difficultyLevel > 0)
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
            
            vbg.backgroundColor = randomColor;
            if (useCrazy) {
                cellView.backgroundColor = randomColor;
            }
            if ([darkColors containsObject:v.backgroundColor]) {
                l.textColor = [UIColor whiteColor];
            }
        }
        
        
        if (!isTextSequence) {
            [l setFont:[UIFont systemFontOfSize:iconSize]];
        } else if (self.game.difficultyLevel > 0) {
                vbg.fill = 0 == arc4random() % 2;
        }
        
        if (self.difficultyLevel > 1 && isTextSequence)
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
        
        if (self.difficultyLevel > 1)
        {
            vbg.alpha = [[opacity objectAtIndex:(arc4random() % [opacity count])] floatValue];
        }
        
        if (!isTextSequence) {
            vbg.fill = NO;
        }
        
        x = x + width;
        

        [v addTarget:self action:@selector(onCellTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        
        v.tag = i;
        

        __block float alpha = cellView.alpha;
        __block CGAffineTransform transform = cellView.transform;
        
        [self.board addSubview:cellView];
        
        cellView.alpha = 0.0;
        cellView.transform = CGAffineTransformScale(transform, 0.1, 0.1);
        
        [UIView animateWithDuration:0.4 delay:(arc4random() % 20) / 50.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             cellView.transform = CGAffineTransformScale(transform, 1.0, 1.0);
                             cellView.alpha = alpha;
                             
                         } completion:^(BOOL finished){
                         
                         }];
    }
}


- (void) endGame:(BOOL) showResult{
    
    [self.timer invalidate];
    self.timer = nil;
    
    
    [self updateHeaderLabel];
    
    if (showResult) {
        [self clearBoard:^{
            [self performSegueWithIdentifier:@"nc_show_result" sender:self];
        }];
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

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIColor*) colorWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}

@end
