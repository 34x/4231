//
//  ATSettings.h
//  attention
//
//  Created by Max on 24.01.16.
//  Copyright © 2016 Max. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATSettings : NSObject
+(instancetype) sharedInstance;
-(NSString*) get:(NSString*)key;
@end
