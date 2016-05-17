//
//  NCSequenceSettings.h
//  attention
//
//  Created by Max on 15.02.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCSequenceSettings : NSObject <NSCoding>
@property (nonatomic) NSInteger boardIndex;
@property (nonatomic) NSInteger solvedCount;
@property (nonatomic) float lastResult;
@property (nonatomic) NSInteger sequenceLength;
@property (nonatomic) NSInteger errorCount;
@property (nonatomic) NSInteger difficultyLevel;
@end
