//
//  ATSettings.h
//  attention
//
//  Created by Max on 24.01.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const ATSettingsKeyUserID;

typedef enum {
    ATSettingsKeyBannerMain       = 0,
    ATSettingsKeyBannerStatistics = 1,
    ATSettingsKeyBannerSequence   = 2,
    ATSettingsKeyBannerSettings   = 3,
} ATSettingsKey;

@interface ATSettings : NSObject
@property (nonatomic, readonly) NSString *userID;

+(instancetype) sharedInstance;
-(id) get:(id)key;
- (void) setSettingValue:(id)obj forKey:(id)key;

@end
