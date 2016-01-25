//
//  ATGame.m
//  attention
//
//  Created by Max on 19/09/15.
//  Copyright © 2015 Max. All rights reserved.
//

#import "ATGame.h"
#import "NCGame.h"
#import "Utils.h"

@interface ATGame()
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger shapesCount;
@property NSTimer *gameTimer;
@property float gameTimeLimit;
@property NSArray *shapes;
@end

@implementation ATGame
{
    NSUserDefaults *defaults;
    NSArray *currentSymbols;
    BOOL gameIsRunning;
    NSMutableArray *suspectsShowed;
    CFAbsoluteTime gameTimerStarted;
}

@synthesize queue;
@synthesize rows;
@synthesize cols;
@synthesize boardCells;
@synthesize margin;
@synthesize shapesOnBoard;
@synthesize shapesHidden;
@synthesize cellSize;
@synthesize delegate;
@synthesize timer;
@synthesize shapesCount;
@synthesize totalCount;
@synthesize suspectCount;
@synthesize gameTimer;
@synthesize gameTimeLimit;
@synthesize shapes;

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        
        cols = 16;
        rows = 16;
        margin = 1;
        cellSize = 4;
        shapesCount = 32;
        
        gameTimeLimit = 5.0;
        
        
        defaults = [[NSUserDefaults alloc] init];
        
        if ([defaults objectForKey:@"suspects"]) {
            totalCount = [[defaults objectForKey:@"suspects"] integerValue];
        } else {
            totalCount = 2;
        }
        
        suspectCount = totalCount / 3;
        
        if (suspectCount < 1) {
            suspectCount = 1;
        }
    }
    
    return self;
}

- (instancetype) initWithCols:(NSInteger)inCols rows:(NSInteger)inRows {
    self = [self init];

    if (self) {
        cols = inCols;
        rows = inRows;
    }
    
    return self;
}

- (NSArray*)getSymbols {
    if (!currentSymbols) {
        NSArray *symbolsNames = @[@"emoji", @"faces", @"flags"];
        currentSymbols = [NCGame getSymbols:symbolsNames[arc4random() % symbolsNames.count]];
    }
    
    return currentSymbols;
}

- (void) start {
    
    [self.queue addOperationWithBlock:^{
        gameIsRunning = YES;
        currentSymbols = nil;
        suspectsShowed = [NSMutableArray new];
        
        NSArray *symbols = [self getSymbols];
        
        NSArray *randomized = [Utils getRandomizedSequence:symbols];
        

        NSIndexSet *is = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, totalCount)];
        
        symbols = [randomized objectsAtIndexes:is];
        
        
        NSInteger maxShapesCount = shapesCount;

        if (maxShapesCount > [symbols count]) {
            maxShapesCount = [symbols count];
        }
        
        shapesHidden = [[NSMutableArray alloc] init];
        shapesOnBoard = [[NSMutableArray alloc] init];
        boardCells = [[NSMutableDictionary alloc] init];
        NSInteger rightShapesMarked = 0;
        
        cellSize = cols / maxShapesCount;
        
        for (int i = 0; i < maxShapesCount; i++) {
            
            ATShape *shape = [[ATShape alloc] initWithPosition:CGPointMake(0, 0) size:cellSize];
            
            if (rightShapesMarked < suspectCount) {
                shape.isRight = true;
                rightShapesMarked++;
            }
            
            shape.text = [NSString stringWithFormat:@"%@", [symbols objectAtIndex:i]];
            [shapesHidden addObject:shape];
            
        }
        
        // for sure!
        shapesHidden = [[Utils getRandomizedSequence:shapesHidden] mutableCopy];
        shapes = [[NSArray alloc] initWithArray:shapesHidden];
    }];
    
    if (timer) {
        [timer invalidate];
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
    if (gameTimer) {
        [gameTimer invalidate];
    }
    
    gameTimeLimit = totalCount * 2.0;
    gameTimerStarted = CFAbsoluteTimeGetCurrent();
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:gameTimeLimit target:self selector:@selector(finish) userInfo:nil repeats:NO];
}

- (void) finish {
    [queue addOperationWithBlock:^{
        [gameTimer invalidate];
//        if (suspectCount != suspectsShowed.count) {
//            gameTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(finish) userInfo:nil repeats:NO];
//        } else {
            gameIsRunning = NO;
//        }
    }];
}

- (ATShape*)addShapeToRandom:(ATShape *)shape {

    for (int i = 0; i < 10; i++) {
        NSInteger x = arc4random() % cols;
        NSInteger y = arc4random() % rows;

        CGPoint point = CGPointMake(x, y);
        if ([self isPositionFree: point size:shape.size]) {
            shape.position = point;
            [self addShape:shape];
            
            break;
        }
        
    }

    return shape;
}

- (void) tick {

    [self.queue addOperationWithBlock:^{

        for (NSInteger i = 0; i < [shapesOnBoard count]; i++) {
            ATShape *shape = [shapesOnBoard objectAtIndex:i];
            if (0 == shapesHidden.count) {
                [self removeShape:shape];
                break;
            } else {
                NSInteger chance;
                if (gameIsRunning) {
                    chance = 8;
                } else {
                    chance = 2;
                }
                
                if (0 == arc4random() % chance) {
                    [self removeShape:shape];
                }
            }
        }
        
        if (gameIsRunning) {
            for(NSInteger i = 0; i < [shapesHidden count]; i++) {
                ATShape *shape = [shapesHidden objectAtIndex:i];
                if (0 == shapesOnBoard.count) {
                    [self addShapeToRandom:shape];
                    break;
                } else {
                    NSInteger chance = 2;
                    // this point to be sure that all suspects will be showed at least once before game will be over
                    if (shape.isRight && NSNotFound == [suspectsShowed indexOfObject:shape]) {
                        CFAbsoluteTime timeSpent = CFAbsoluteTimeGetCurrent() - gameTimerStarted;
                        CFAbsoluteTime timeLeft = gameTimeLimit - timeSpent;
                        if (timeLeft < gameTimeLimit / 2.0) {
                            chance = 1;
                        }
                    }

                    if (0 == arc4random() % chance) {
                        [self addShapeToRandom:shape];
                    }
                }
            }
        }
    }];
}


- (BOOL) isPositionFree:(CGPoint)position size:(NSInteger)size {

    if (position.x - margin < 0 || position.y - margin < 0 || position.x + size + margin > cols || position.y + size + margin > rows) {
        return false;
    }
    
    for (NSInteger ix = position.x - margin; ix < position.x + size + margin; ix++) {
        for (NSInteger iy = position.y - margin; iy < position.y + size + margin; iy++) {
            NSString *key = [NSString stringWithFormat:@"%lix%li", ix, iy];
            id e = [boardCells objectForKey: key];
            if (e) {
                return false;
            }
        }
    }
    
    return true;
}

- (void) addShape:(ATShape*)shape {
    

        [shapesHidden removeObject:shape];
        
        for (NSInteger ix = shape.position.x; ix < shape.position.x + shape.size; ix++) {
            
            for (NSInteger iy = shape.position.y; iy < shape.position.y + shape.size; iy++) {
                
                NSString *key = [NSString stringWithFormat:@"%lix%li", ix, iy];
                
                [boardCells setObject:@1 forKey:key];
            }
        }
        
     
        [delegate addShape:shape];

}

- (void) removeShape:(ATShape*)shape {
    
    [shapesOnBoard removeObject:shape];
    
    [delegate removeShape:shape];
    
}

- (void)shapeDidRemove:(ATShape*)shape {
    [queue addOperationWithBlock:^{
        for (NSInteger ix = shape.position.x; ix < shape.position.x + shape.size; ix++) {
            for (NSInteger iy = shape.position.y; iy < shape.position.y + shape.size; iy++) {
                NSString *key =[NSString stringWithFormat:@"%lix%li", ix, iy];
                [boardCells removeObjectForKey:key];
            }
        }
        
        [shapesHidden addObject:shape];
        

        if (!gameIsRunning && 0 == shapesOnBoard.count && totalCount == shapesHidden.count) {
            [timer invalidate];
            [delegate atGameFinish:self];
        }
    }];
    
    
}

- (void) shapeDidAdd:(ATShape *)shape {
    [queue addOperationWithBlock:^{
        [shapesOnBoard addObject:shape];
        // to be sure that all suspects was showed
        if (shape.isRight && NSNotFound == [suspectsShowed indexOfObject:shape]) {
            [suspectsShowed addObject:shape];
        }
    }];
}

- (NSArray*)getShapes {
    return shapes;
}


- (void) increaseDifficulty {
    totalCount++;
    suspectCount = totalCount / 3;
    
    [defaults setObject:[NSNumber numberWithInteger:totalCount] forKey:@"suspects"];
}


- (void) decreaseDifficulty {
    if (totalCount > 2) {
        totalCount--;
        suspectCount = totalCount / 3;
    }
    
    [defaults setObject:[NSNumber numberWithInteger:totalCount] forKey:@"suspects"];

}

@end
