//
//  ATSettings.m
//  attention
//
//  Created by Max on 24.01.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import "ATSettings.h"

NSString *const ATSettingsKeyUserID = @"ATSettingsKeyUserID";

@interface ATSettings()
@property (nonatomic, readwrite) NSString *userID;
@end

@implementation ATSettings
{
    NSDictionary *settings;
    NSArray *defaults;
}


static ATSettings *sharedInstance;

- (instancetype) init {
    self = [super init];
    if (self) {
        NSString *settingsFilename = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        settings = [NSDictionary dictionaryWithContentsOfFile:settingsFilename];
        defaults = @[
                     @"feedback_draft",
                     @(ATSettingsKeyBannerMain), @(ATSettingsKeyBannerSequence), @(ATSettingsKeyBannerStatistics),
                     @(ATSettingsKeyBannerSettings), ATSettingsKeyUserID
                     ];
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

- (NSString*) keyString:(id)key {
    return [NSString stringWithFormat:@"%@", key];
}

- (id) get:(id)key {
    if (NSNotFound != [defaults indexOfObject:key]) {
        NSUserDefaults *def = [[NSUserDefaults alloc] init];
        
        id value = [def objectForKey:[self keyString:key]];
        
        return value;
    }
    
    return [settings objectForKey:key];
}

- (void) setSettingValue:(id)obj forKey:(id)key {
    if (NSNotFound != [defaults indexOfObject:key]) {
        NSUserDefaults *def = [[NSUserDefaults alloc] init];
        [def setObject:obj forKey:[self keyString:key]];
        [def synchronize];
    }
}

- (NSString*)userID {
    _userID = [self get:[self keyString:ATSettingsKeyUserID]];
    
    if (!_userID) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        _userID = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
        CFRelease(uuid);
        
        [self setSettingValue:_userID forKey:ATSettingsKeyUserID];
    }
    
    return _userID;
}

@end
