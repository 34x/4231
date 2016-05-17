//
//  GCHelper.h
//  HowManyC
//
//  Created by Max on 06/07/15.
//  Copyright (c) 2015 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GCHelper : NSObject {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL userAuthenticated;
@property (nonatomic) UIViewController *gcController;

@property UIViewController *controller;
@property NSString *localPlayerId;
@property NSInteger localPlayerRank;
@property NSString *leaderboardId;

+ (GCHelper *)sharedInstance;
- (BOOL) isGameCenterAvailable;
- (void) authenicateLocalUserForce:(void(^)(BOOL askForAuth, NSError *error))completion;
- (void) authenticateLocalUser:(void(^)(BOOL askForAuth, NSError *error))completion;
- (void) reportScore:(NSInteger)scoreValue;
- (void) getLeaderboardWithCompletionHandler:(void(^)(NSArray* scores))handler;
- (void) showAuthControllerFrom:(UIViewController*)caller;
@end
