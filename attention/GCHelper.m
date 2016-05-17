//
//  GCHelper.m
//  HowManyC
//
//  Created by Max on 06/07/15.
//  Copyright (c) 2015 Max. All rights reserved.
//

#import "GCHelper.h"
#import "AppDelegate.h"

@interface GCHelper ()
@property BOOL gcIsCanceled;
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
    NSLog(@"GC available: %i", !_gcIsCanceled);
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (!_gcIsCanceled && gcClass && osVersionSupported);
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
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated && nil == self.gcController) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
        self.localPlayerId = [GKLocalPlayer localPlayer].playerID;
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}

- (void) showAuthControllerFrom:(UIViewController *)caller {
    BOOL gcDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GCdisabled"];
    
    if (self.gcController && !userAuthenticated && !gcDisabled) {
        [caller presentViewController:self.gcController animated:YES completion:^{
            NSLog(@"gchost completion");
            self.gcController = nil;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GCdisabled"];
        }];
    }
}

#pragma mark User functions

-(void) authenicateLocalUserForce:(void (^)(BOOL, NSError *))completion {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GCdisabled"];
    [self authenticateLocalUser:completion];
}

- (void)authenticateLocalUser:(void (^)(BOOL, NSError *))completion {
    
    BOOL gcDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"GCdisabled"];
    
    if (!gameCenterAvailable || gcDisabled) {
        completion(NO, [NSError errorWithDomain:@"GC" code:1 userInfo:nil]);
        return;   
    }
    
    NSLog(@"Authenticating local user...");
    GKLocalPlayer *player = [GKLocalPlayer localPlayer];

    if (!player.isAuthenticated) {
        NSLog(@"Setting auth handler");
        player.authenticateHandler = ^(UIViewController *viewController, NSError *error){
            NSLog(@"auth handler called: vc: %@, err: %@", viewController, error);
            if (nil != error) {
                NSLog(@"GCHelper error: %@", error);
                if (2 == error.code) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GCdisabled"];
                    _gcIsCanceled = YES;
                }
                completion(NO, error);
                return;
            }
            
            if (nil != viewController) {
                userAuthenticated = NO;
                self.gcController = viewController;
                NSLog(@"Asking user for auth");
                completion(YES, nil);
            } else if ([GKLocalPlayer localPlayer].isAuthenticated) {
                userAuthenticated = YES;
                NSLog(@"User authenticated");
                completion(NO, nil);
            }
        };
    } else {
        NSLog(@"Already authenticated!");
        completion(NO, nil);
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
