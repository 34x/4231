//
//  NumbersCountSettings.m
//  attention
//
//  Created by Max on 29/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "NCSettings.h"

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
            self.sequencesSettings = [[NSMutableDictionary alloc] init];
        } else {
            self.sequencesSettings = [sequencesSettings mutableCopy];
        }
        
    }
    return self;
}

- (NSMutableDictionary*)getSequenceSettings:(NSString*)sid {
    id obj = [self.sequencesSettings objectForKey:sid];
    NSMutableDictionary *settings;
    
    if (!obj) {
        settings = [[NSMutableDictionary alloc] initWithDictionary: @{
                     @"currentBoard" : @0,
                     @"maximumBoard" : @0,
                     @"solved": @0,
                     @"lastResult" : @0.0
                     }];
    } else {
        settings = [obj mutableCopy];
    }
    
    [self.sequencesSettings setObject:settings forKey:sid];
    
    return settings;
}

-(void)save {
    NSDictionary *settings = @{
                               @"cols" : [NSNumber numberWithInt:self.cols],
                               @"rows" : [NSNumber numberWithInt:self.rows],
                               @"sequence" : [NSNumber numberWithInt:self.sequence],
                               @"sequencesSettings" : self.sequencesSettings
                            };
//    NSLog(@"%@", self.sequencesSettings);
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    
    [defaults setObject:settings forKey:self.key];
    [defaults synchronize];
}

+(NSArray*)getBoardSizes {
    return @[@[@2, @1],
                            @[@2, @2], @[@2, @3], @[@2, @4], @[@3, @3], @[@3, @4], @[@3, @5], @[@4, @4], @[@4, @5], @[@5, @5], @[@6, @7]
                            ];
}

@end
