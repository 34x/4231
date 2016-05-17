//
//  NCShowResultViewController.m
//  attention
//
//  Created by Max on 06.02.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import "NCShowResultViewController.h"
#import "PiwikTracker.h"
#import "NCGame.h"
#import "NCSettings.h"
#import "GCHelper.h"
#import "NCPreviewViewController.h"


@implementation NCShowResultViewController {
    NCSettings *settings;
    NCGame *game;
    NCSequenceSettings *sequenceSettings;
    NSInteger errorsLimit;
    NSInteger nextBoardLimitFactor;
    float nextLevelLimit;
    float gameScore;
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    nextLevelLimit = 60.; // %
    errorsLimit = 6;
    game = [NCGame sharedInstance];
    settings = [NCSettings new];
    nextBoardLimitFactor = 12;
    
    NSArray *winMsgs = @[@"win1", @"win2", @"win3"];
    NSArray *looseMsgs = @[@"loose1", @"loose2", @"loose3", @"loose4"];
    NSString *msgTitle = NSLocalizedString(looseMsgs[arc4random() % [looseMsgs count]], nil);
    
    
    
    
    sequenceSettings = [settings getSequenceSettings:[NCGame getSequenceId:game.sequenceLevel]];
    
    
    NSDictionary *result;
    gameScore = .0;

    result = [game finish];
    
    gameScore = [[NCGame getScore:result] floatValue];
    
//    float diff = .0;
//    if (gameScore > .0 && lastResult > .0) {
//        diff = gameScore / (lastResult / 100.);
//    }
    
    [[GCHelper sharedInstance] reportScore:gameScore*100];
    
    
    
    [[PiwikTracker sharedInstance] sendViews: @"game", @"finish", game.sequenceId, nil];

    if (game.clickedWrong > 0) {
        [self processWrongClicks];
//    } else if (gameScore > 0. && (diff > nextLevelLimit || .0 == diff)) {
    } else {
        msgTitle = NSLocalizedString(winMsgs[arc4random()%[winMsgs count]], nil);
        [self processNextLevel];
    }
    

    game.sequenceLevel++;
    
    settings.sequence = game.sequenceLevel;
    
    [settings save];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"you_score", nil), gameScore ];

    
    _titleView.textAlignment = NSTextAlignmentCenter;
    _titleView.font = [UIFont systemFontOfSize:24.0];
    _titleView.selectable = YES;
    _titleView.text = msgTitle;
    _messageTextView.text = message;
    _messageTextView.textAlignment = NSTextAlignmentCenter;
    
    // show flags
    if ([@"flags" isEqualToString:game.sequenceId]) {
        
        for (int i = 0; i < [game.sequence count]; i++) {
            NSString *flag = game.sequence[i];
            NSString *country = [self getCountryByFlag:flag];
            
            if (country) {
                message = [NSString stringWithFormat:@"%@\n%@   %@",
                                message, game.sequence[i], country];
            }
            
        }
        
        _messageTextView.textAlignment = NSTextAlignmentLeft;
        _messageTextView.text = message;
    }
}


-(void)viewDidAppear:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self nextButtonHandler:nil];
    });
}


- (void) processWrongClicks {
    NSLog(@"Process wrong clicks");
    
    sequenceSettings.lastResult = 0.0;
    NSInteger errors = sequenceSettings.errorCount++;

    
    if (errors >= game.sequenceLength) {
        sequenceSettings.errorCount  = 0;
        sequenceSettings.solvedCount = 0;

        
        if (game.sequenceLength > 2) {
            
            NSUInteger boardIndex = [NCSettings getCloserBoardIndex:game.sequenceLength];
            NSUInteger currentIndex = sequenceSettings.boardIndex;
            
            // if we have not in initial board for this sequence. We decrase board size
            if (currentIndex > boardIndex) {
                boardIndex--;
                sequenceSettings.boardIndex = boardIndex;
                
                [[PiwikTracker sharedInstance] sendEventWithCategory:@"game"
                                                              action:@"decrease_board"
                                                                name:game.sequenceId
                                                               value:@1
                 ];
                
            } else { // if we at start of board for this sequence length we decrase sequence length
                game.sequenceLength--;
                //                        boardIndex--;
                boardIndex = [NCSettings getCloserBoardIndex:game.sequenceLength];
                
                sequenceSettings.boardIndex = boardIndex;
                sequenceSettings.sequenceLength = game.sequenceLength;
                
                [[PiwikTracker sharedInstance] sendEventWithCategory:@"game"
                                                              action:@"decrease_sequence"
                                                                name:game.sequenceId
                                                               value:@1
                 ];
            }
            
            
            
        } else {
            NSUInteger currentIndex = sequenceSettings.boardIndex;
            
            if (currentIndex > 0) {
                currentIndex--;
                sequenceSettings.boardIndex = currentIndex;
                
                [[PiwikTracker sharedInstance] sendEventWithCategory:@"game"
                                                              action:@"decrease_board"
                                                                name:game.sequenceId
                                                               value:@1
                 ];
            }
        }
    }
}



- (void) processNextLevel {
    NSLog(@"Process new level");
    
    sequenceSettings.lastResult = gameScore;
    sequenceSettings.solvedCount++;
    NSLog(@"game difficulty: %li", game.difficultyLevel);
    if (sequenceSettings.difficultyLevel < 2) {
        sequenceSettings.difficultyLevel++;
        NSLog(@"Difficulty up! %li", game.difficultyLevel);
    } else {
        NSLog(@"Change sequence");
        sequenceSettings.difficultyLevel = 0;
        sequenceSettings.errorCount = 0;
        // next sequence length
        if (game.total > game.sequenceLength * nextBoardLimitFactor) {
            
            sequenceSettings.solvedCount = 0;
            sequenceSettings.sequenceLength = ++game.sequenceLength;
            
            NSUInteger boardIndex = [NCSettings getCloserBoardIndex:game.sequenceLength];
            sequenceSettings.boardIndex = boardIndex;
            
            [[PiwikTracker sharedInstance] sendEventWithCategory:@"game"
                                                          action:@"increase_sequence"
                                                            name:game.sequenceId
                                                           value:@1
             ];
            
        } else { // increase the board size
            sequenceSettings.boardIndex++;

            [[PiwikTracker sharedInstance] sendEventWithCategory:@"game"
                                                          action:@"increase_board"
                                                            name:game.sequenceId
                                                           value:@1
             ];
        }
    }

}






- (NSString*) getCountryByFlag:(NSString*) flag {
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
    
    return flags[flag];

}
- (IBAction)nextButtonHandler:(id)sender {
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[NCPreviewViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}


- (BOOL)shouldAutorotate {
    return NO;
}

@end

