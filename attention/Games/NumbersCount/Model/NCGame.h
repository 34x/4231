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
@property (readonly, nonatomic) NSUInteger total;
@property (readwrite, nonatomic) NSUInteger sequenceLength;
@property (readonly, nonatomic) NSNumber *duration;
@property (readonly, nonatomic) NSMutableArray *items;
@property (readonly, nonatomic) NSUInteger currentIndex;
@property (readonly, nonatomic) NSUInteger currentNumber;
@property (readonly, nonatomic) NSUInteger colorsCount;
@property (readonly, nonatomic) BOOL isComplete;
@property (readonly, nonatomic) BOOL isDone;
@property (readonly, nonatomic) BOOL isStarted;
@property (nonatomic, readonly) NSUInteger clicked;
@property (nonatomic, readonly) NSUInteger clickedWrong;
@property (readwrite, nonatomic) NSUInteger timeLimit;
@property (nonatomic, readwrite) NSUInteger difficultyLevel;
@property (nonatomic, readwrite) NSUInteger sequenceLevel;
@property (nonatomic, readwrite) NSMutableArray *sequence;


- (instancetype) initWithTotal:(NSUInteger)total;
- (BOOL)select:(NSUInteger)index value:(NSString*)value;
- (void)start;
- (NSDictionary*)finish;
- (float)getSpeed;
- (NSNumber*)getDuration;
- (BOOL)getIsDone;
- (NSMutableArray*)getSequence:(NSUInteger)sequenceLevel difficultyLevel:(NSUInteger)difficultyLevel;
+ (NSMutableArray*)log;
+ (NSMutableDictionary*)stats:(NSString*)keyFormat fromDate:(NSDate*)fromDate;
+ (NSMutableArray*)createLimitSequence:(NSUInteger)total symbols:(NSArray*)symbols;
+ (NSMutableArray*)randomize:(NSMutableArray*)itemsOriginal;
+ (NSArray*)getSequencesParams;
+ (NSDictionary*)getSequenceParams:(NSUInteger)level;
+ (NSUInteger)checkSequenceLevel:(NSUInteger)level;
+ (NSString*)getSequenceId:(NSUInteger)level;
+ (NSArray*)getSymbols:(NSString*)key;
+ (NSNumber*)getScore:(NSDictionary*)data;
- (NSArray*)getRandomizedSequence:(NSArray*)sequenceOriginal;
- (NSArray*)getItems;

@end
