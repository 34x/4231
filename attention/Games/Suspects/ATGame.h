//
//  ATGame.h
//  attention
//
//  Created by Max on 19/09/15.
//  Copyright © 2015 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATShape.h"


@class ATGame;
@protocol ATGameDelegate;


@protocol ATGameDelegate <NSObject>
- (void) addShape:(ATShape*)shape;
- (void) removeShape:(ATShape*)shape;
- (void) atGameFinish:(ATGame *)game;
@end


@interface ATGame : NSObject

@property (nonatomic) NSInteger rows;
@property (nonatomic) NSInteger cols;
@property (nonatomic)NSInteger margin;
@property (nonatomic) NSMutableDictionary *boardCells;
@property (nonatomic) NSMutableArray *shapesOnBoard;
@property (nonatomic) NSMutableArray *shapesHidden;
@property (nonatomic) NSInteger cellSize;
@property (nonatomic) NSInteger totalCount;
@property NSInteger suspectCount;
@property (nonatomic) id <ATGameDelegate> delegate;

- (instancetype) initWithCols:(NSInteger)inCols rows:(NSInteger)inRows;
- (ATShape*)addShapeToRandom:(ATShape*)shape;
- (void) start;
- (void) finish;
- (void) shapeDidRemove:(ATShape*)shape;
- (void) shapeDidAdd:(ATShape*)shape;
- (NSArray*)getShapes;
- (NSArray*)getSymbols;
- (void) increaseDifficulty;
- (void) decreaseDifficulty;

@end



