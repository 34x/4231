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
    }
    return self;
}

-(void)save {
    NSDictionary *settings = @{
                               @"cols" : [NSNumber numberWithInt:self.cols],
                               @"rows" : [NSNumber numberWithInt:self.rows],
                               @"sequence" : [NSNumber numberWithInt:self.sequence],
                            };
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] init];
    
    [defaults setObject:settings forKey:self.key];
    [defaults synchronize];
}

@end
