//
//  NCSequenceSettings.m
//  attention
//
//  Created by Max on 15.02.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import "NCSequenceSettings.h"

@implementation NCSequenceSettings

-(instancetype) init {
    self = [super init];
    if (self) {
        self.boardIndex = 0;
        self.solvedCount = 0;
        self.errorCount = 0;
        self.sequenceLength = 2;
        self.lastResult = 0.0;
    }
    return self;
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        self.boardIndex      = [[aDecoder decodeObjectForKey:@"boardIndex"] integerValue];
        self.solvedCount     = [[aDecoder decodeObjectForKey:@"solvedCount"] integerValue];
        self.errorCount      = [[aDecoder decodeObjectForKey:@"errorCount"] integerValue];
        self.sequenceLength  = [[aDecoder decodeObjectForKey:@"sequenceLength"] integerValue];
        self.lastResult      = [[aDecoder decodeObjectForKey:@"lastResult"] floatValue];
        self.difficultyLevel = [[aDecoder decodeObjectForKey:@"difficultyLevel"] floatValue];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.boardIndex) forKey:@"boardIndex"];
    [aCoder encodeObject:@(self.solvedCount) forKey:@"solvedCount"];
    [aCoder encodeObject:@(self.errorCount) forKey:@"errorCount"];
    [aCoder encodeObject:@(self.sequenceLength) forKey:@"sequenceLength"];
    [aCoder encodeObject:@(self.lastResult) forKey:@"lastResult"];
    [aCoder encodeObject:@(self.difficultyLevel) forKey:@"difficultyLevel"];
}


- (NSString*)description {
    return [NSString stringWithFormat:@"<SequenceSettings board: %li, solved: %li, errors: %li, length: %li, last result: %f, difficulty: %li>",
            self.boardIndex, self.solvedCount, self.errorCount, self.sequenceLength, self.lastResult, self.difficultyLevel];
}
@end
