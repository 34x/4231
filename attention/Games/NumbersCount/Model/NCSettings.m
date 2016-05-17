//
//  NumbersCountSettings.m
//  attention
//
//  Created by Max on 29/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "NCSettings.h"
#import "NCSequenceSettings.h"

@interface NCSettings()
@property (nonatomic) NSString *key;
@end

@implementation NCSettings

-(id)init {
    self = [super init];
    
    if (self) {
        self.key = @"numbers_count_settings";
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
        id obj = [defaults objectForKey:self.key];
        
        NSMutableDictionary *settings;
        if (nil == obj) {
            settings = [[NSMutableDictionary alloc] init];
        } else {
            settings = [obj mutableCopy];
        }
        
        id cols = [settings objectForKey:@"cols"];
        
        if (nil == cols) {
            self.cols = 4;
        } else {
            self.cols = [cols intValue];
        }
        
        id rows = [settings objectForKey:@"rows"];
        
        if (nil == rows) {
            self.rows = 5;
        } else {
            self.rows = [rows intValue];
        }

        id sequence = [settings objectForKey:@"sequence"];
        
        if (nil == sequence) {
            self.sequence = 0;
        } else {
            self.sequence = [sequence intValue];
        }
        
        id sequencesSettings = [settings objectForKey:@"sequencesSettings"];
        
        if (nil == sequencesSettings) {
            self.sequencesSettings = [NSMutableDictionary new];
        } else {
            self.sequencesSettings = [sequencesSettings mutableCopy];
        }
    }
    return self;
}

- (NCSequenceSettings*)getSequenceSettings:(NSString*)sid {
    id obj = [self.sequencesSettings objectForKey:sid];
    
    NCSequenceSettings *settings;
    if (!obj) {
        settings = [[NCSequenceSettings alloc] init];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        settings = [[NCSequenceSettings alloc] init];
        settings.boardIndex = [[obj valueForKey:@"currentBoard"] integerValue];
        settings.solvedCount = [[obj valueForKey:@"solved"] integerValue];
        settings.lastResult = [[obj valueForKey:@"lastResult"] floatValue];
        settings.sequenceLength = [[obj valueForKey:@"sequenceLength"] integerValue];
        settings.errorCount = [[obj valueForKey:@"errors"] integerValue];
    } else if ([obj isKindOfClass:[NSData class]]) {
        settings = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
    } else {
        NSLog(@"Wrong setting object");
    }
    
    [self.sequencesSettings setObject:settings forKey:sid];
    
    NSLog(@"SequenceSettings[%@]: %@", sid, settings);
    return settings;
}

-(void)save {
    
    __block NSDictionary *ssa = [NSMutableDictionary new];
    
    [self.sequencesSettings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        if ([obj isKindOfClass:[NCSequenceSettings class]]) {
            obj = [NSKeyedArchiver archivedDataWithRootObject:obj];
        }
        
        [ssa setValue:obj forKey:key];
    }];
    
    NSDictionary *settings = @{
                               @"cols" : [NSNumber numberWithInt:self.cols],
                               @"rows" : [NSNumber numberWithInt:self.rows],
                               @"sequence" : [NSNumber numberWithInteger:self.sequence],
                               @"sequencesSettings" : ssa
                               };
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    
    [defaults setObject:settings forKey:self.key];
    
    [defaults synchronize];
}

+(NSArray*)getBoardSizes {
    return @[
             @[@2, @1], @[@2, @2], @[@2, @3],
             @[@2, @4], @[@3, @3], @[@3, @4],
             @[@3, @5], @[@4, @4], @[@4, @5],
             @[@4, @6], @[@5, @5], @[@5, @6],
             @[@5, @7], @[@6, @6], @[@5, @8],
             @[@6, @7], @[@6, @8], @[@7, @7],
             @[@7, @8], @[@7, @9], @[@7, @10],
             @[@7, @11], @[@7, @12], @[@8, @11],
             @[@8, @12], @[@8, @13], @[@8, @14],
             @[@9, @13], @[@9, @14], @[@9, @15],
             @[@10, @14], @[@10, @15], @[@10, @16],
             @[@10, @17], @[@10, @18]
    ];
}

+(NSUInteger)getCloserBoardIndex:(NSInteger)size {
    NSArray *sizes = [NCSettings getBoardSizes];
    NSUInteger closer = 0;
    
    long diff = 99999;
    
    for (int i = 0; i < [sizes count]; i++) {
        int total = [sizes[i][0] intValue] * [sizes[i][1] intValue];
        long cdiff = labs(total - size);
        
        if (total >= size) {
            if (cdiff < diff) {
                diff = cdiff;
                closer = i;
            } else {
                break;
            }
        }
    }
    
    
    return closer;
}


@end
