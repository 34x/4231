//
//  Game.h
//  attention
//
//  Created by Max on 18/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCGame : NSObject
@property (readonly, nonatomic) NSUInteger cols;
@property (readonly, nonatomic) NSUInteger rows;
@property (readonly, nonatomic) NSUInteger duration;
@property (readonly, nonatomic) NSMutableArray *items;
@property (readonly, nonatomic) NSUInteger currentIndex;
@property (readonly, nonatomic) NSUInteger currentNumber;
@property (readonly, nonatomic) NSUInteger colorsCount;
@property (readonly, nonatomic) BOOL isComplete;

- (instancetype) initWithTotal:(NSUInteger)total;
- (BOOL)select:(NSUInteger)index;
- (void)start;
- (void)finish;
- (float)getSpeed;
+ (NSMutableArray*)log;
+ (NSMutableDictionary*)stats;
+ (NSMutableDictionary*)statsForDay;

@end
