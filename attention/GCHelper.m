//
//  GCHelper.m
//  HowManyC
//
//  Created by Max on 06/07/15.
//  Copyright (c) 2015 Max. All rights reserved.
//

#import "GCHelper.h"


@interface GCHelper ()

@end

@implementation GCHelper

@synthesize gameCenterAvailable;
@synthesize userAuthenticated;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;

+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        self.leaderboardId = @"me.34x.attention.leaderboard.default";
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
        self.localPlayerId = [GKLocalPlayer localPlayer].playerID;
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}

#pragma mark User functions

- (void)authenticateLocalUser {
    
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    GKLocalPlayer *player = [GKLocalPlayer localPlayer];

    if (player.authenticated == NO) {
        player.authenticateHandler = ^(UIViewController *viewController, NSError *error){
            NSLog(@"error: %@", error);
            NSLog(@"show to player: %@", viewController);

            NSLog(@"authentication complete");
            NSLog(@"authenticated: %i", [GKLocalPlayer localPlayer].authenticated);
        };
        

    } else {
        NSLog(@"Already authenticated!");
    }
}

- (void)reportScore:(NSInteger)scoreValue {
    if (gameCenterAvailable && userAuthenticated) {

        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:self.leaderboardId];
        
        score.value = scoreValue;
        
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error){
            if (nil != error) {
                NSLog(@"reporting scores error: %@", error);
            }
        }];
    } else {
//        NSLog(@"GC is not available or player not authenticated");
    }
}

- (void) getLeaderboardWithCompletionHandler:(void(^)(NSArray* scores))handler {
    if (gameCenterAvailable && userAuthenticated) {
        GKLeaderboard *board = [[GKLeaderboard alloc] init];

        board.identifier = self.leaderboardId;
        board.timeScope = GKLeaderboardTimeScopeAllTime;
        board.playerScope = GKLeaderboardPlayerScopeGlobal;
        
        board.range = NSMakeRange(1, 100);
        [board loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
            if (nil == error) {
                self.localPlayerRank = [board localPlayerScore].rank;
                handler(scores);
            } else {
                NSLog(@"load scores error: %@", error);
            }
            
        }];
    }
}

@end
