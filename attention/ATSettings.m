//
//  ATSettings.m
//  attention
//
//  Created by Max on 24.01.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import "ATSettings.h"

@implementation ATSettings
{
    NSDictionary *settings;
}


static ATSettings *sharedInstance;

- (instancetype) init {
    self = [super init];
    if (self) {
        NSString *settingsFilename = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        settings = [NSDictionary dictionaryWithContentsOfFile:settingsFilename];
    }

    return self;
}

+(instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ATSettings alloc] init];
    });
    return sharedInstance;
}


- (NSString*) get:(NSString *)key {
    return [settings objectForKey:key];
}
@end
