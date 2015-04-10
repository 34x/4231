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
@property (readonly, nonatomic) NSNumber *duration;
@property (readonly, nonatomic) NSMutableArray *items;
@property (readonly, nonatomic) NSUInteger currentIndex;
@property (readonly, nonatomic) NSUInteger currentNumber;
@property (readonly, nonatomic) NSUInteger colorsCount;
@property (readonly, nonatomic) BOOL isComplete;
@property (readonly, nonatomic) BOOL isDone;
@property (readonly, nonatomic) BOOL isStarted;
@property (nonatomic, readonly) NSUInteger clicked;
@property (readwrite, nonatomic) NSUInteger timeLimit;
@property (nonatomic, readwrite) NSUInteger difficultyLevel;
@property (nonatomic, readwrite) NSUInteger sequenceLevel;
@property (nonatomic, readwrite) NSMutableArray *sequence;


- (instancetype) initWithTotal:(NSUInteger)total;
- (BOOL)select:(NSUInteger)index value:(NSString*)value;
- (void)start;
- (void)finish;
- (float)getSpeed;
- (NSNumber*)getDuration;
- (BOOL)getIsDone;
+ (NSMutableArray*)log;
+ (NSMutableDictionary*)stats:(NSString*)keyFormat;
+ (NSMutableDictionary*)statsForDay;
+ (NSMutableArray*)createLimitSequence:(NSUInteger)total symbols:(NSArray*)symbols;
+ (NSMutableArray*)randomize:(NSMutableArray*)itemsOriginal;
+ (NSArray*)getSequencesParams;
+ (NSArray*)getSymbols:(NSString*)key;
- (NSArray*)getRandomizedSequence:(NSArray*)sequenceOriginal;
- (NSArray*)getItems;

@end
