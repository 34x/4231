//
//  Game.m
//  attention
//
//  Created by Max on 18/10/14.
//  Copyright (c) 2014 Max. All rights reserved.
//

#import "NCGame.h"
#import "NCCell.h"
@interface NCGame()
@property (readwrite, nonatomic) NSUInteger total;
@property (strong, nonatomic) NSMutableArray *items;
@property (nonatomic, readwrite) NSUInteger currentNumber;
@property (nonatomic, readwrite) NSUInteger currentIndex;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, readwrite) NSNumber *duration;
@property (nonatomic, readwrite) NSUInteger colorsCount;
@property (nonatomic, readwrite) NSUInteger fontsCount;
@property (nonatomic, readwrite) BOOL isDone;
@property (nonatomic, readwrite) BOOL isComplete;
@property (nonatomic, readwrite) BOOL isStarted;
@property (nonatomic, readwrite) NSUInteger clicked;
@property (nonatomic, readwrite) NSUInteger clickedWrong;
@property (nonatomic, readwrite) NSMutableArray *randomizedSequence;
@property (nonatomic, readwrite) NSDate *startTime;
@property (nonatomic, readwrite) NSDictionary *result;
@end

@implementation NCGame

- (instancetype) initWithTotal:(NSUInteger)total
{
    self = [super init];
    
    if (self) {
        self.total = total;
        self.sequenceLength = total;
        self.timeLimit = 30;
        self.difficultyLevel = 0;
        self.sequenceLevel = 0;
        self.clicked = 0;
        self.clickedWrong = 0;
        self.currentIndex = 0;
        
        self.isStarted = NO;
        self.isDone = NO;
        self.isComplete = NO;
        self.duration = [NSNumber numberWithFloat:.0];
    }

    return self;
}

- (NSMutableArray*)items
{
    if (!_items) _items = [[NSMutableArray alloc] init];
    return _items;
}

- (BOOL)select:(NSUInteger)index value:(NSString*)value
{
    NSString *current = self.sequence[self.currentIndex];
    
    if ([current isEqualToString:value]) {
        self.currentIndex++;
        self.clicked++;
        
        if (self.currentIndex >= [self.sequence count]) {
            self.isComplete = YES;
            [self finish];
        }

        return YES;
    } else {
        self.clickedWrong++;
        
        if (self.clickedWrong >= self.sequenceLength) {
            [self finish];
        }
        
        return NO;
    }
}

- (NSNumber*)getDuration {

    if (self.isStarted && !self.isDone) {
        NSDate *currentTime = [NSDate date];
        NSTimeInterval timeDifference =  [currentTime timeIntervalSinceDate:self.startTime];
        self.duration = [NSNumber numberWithDouble:timeDifference];
    }
    
    return self.duration;
}

- (BOOL)getIsDone {
    if ([[self getDuration] floatValue] >= [[NSNumber numberWithInteger:self.timeLimit] floatValue]) {
        self.isDone = YES;
    }
    
    return self.isDone;
}

+ (NSArray*)getSymbols:(NSString*)key {
    //    @[@"А", @"Б", @"В", @"Г", @"Д", @"Е", @"Ж", @"З", @"И", @"К", @"Л", @"М", @"Н", @"О", @"П", @"Р", @"С", @"Т", @"У", @"Ф", @"Х", @"Ц", @"Ч", @"Ш", @"Щ", @"Ъ", @"Ы", @"Ь", @"Э", @"Ю", @"Я"];
    
    NSMutableArray *numbersFrom1 = [[NSMutableArray alloc] init];
    for (NSUInteger i = 1; i < 100; i++) {
        [numbersFrom1 addObject:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    
    NSMutableArray *numbersFrom0 = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 100; i++) {
        [numbersFrom0 addObject:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    
    NSDictionary *symbols = @{
                              @"numbersFrom1" : numbersFrom1,
                              @"numbers" : numbersFrom0,
                              @"numbers09": @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"],
                              @"numbersLetters" : @[
                                                    @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N",
                                                    @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z",
                                                    @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
                                                    @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
                                                    ],
                              
                              @"letters" : @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I",
                                             @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W",
                                             @"X", @"Y", @"Z"],
                              @"emoji" : @[@"🌳", @"🎄", @"🎼", @"🎭", @"🏁", @"🍄", @"🍀", @"🌍", @"🌚", @"🍍", @"🍒", @"🍴", @"🎃", @"🚲", @"🚧", @"🚀", @"📖", @"👣", @"👻", @"👽", @"🌴", @"🐲", @"🐬", @"☔️", @"🎸", @"⚽️", @"😱", @"🌻", @"⛅️", @"❄️", @"🍉", @"🎁", @"🎯", @"🚜", @"🏠", @"📱", @"⌚️", @"🎥", @"💾", @"💿", @"📡", @"💰", @"🔑"],
                              @"katakana" : @[@"ア",@"イ",@"ウ",@"エ",@"オ",@"カ",@"キ",@"ク",@"ケ",@"コ",@"サ",@"シ",@"ス",@"セ",@"ソ"],
                              @"flags" : @[@"🇦🇺", @"🇦🇹", @"🇧🇪", @"🇧🇷", @"🇨🇦", @"🇨🇱", @"🇨🇳", @"🇨🇴", @"🇩🇰", @"🇫🇮", @"🇫🇷", @"🇩🇪", @"🇭🇰", @"🇮🇳", @"🇮🇩", @"🇮🇪", @"🇮🇱", @"🇮🇹", @"🇯🇵", @"🇰🇷", @"🇲🇴", @"🇲🇾", @"🇲🇽", @"🇳🇱", @"🇳🇿", @"🇳🇴", @"🇵🇭", @"🇵🇱", @"🇵🇹", @"🇵🇷", @"🇷🇺", @"🇸🇦", @"🇸🇬", @"🇿🇦", @"🇪🇸", @"🇸🇪", @"🇨🇭", @"🇹🇷", @"🇬🇧", @"🇺🇸", @"🇦🇪", @"🇻🇳"]
                              };

    return symbols[key];
}

+ (NSArray*)getSequencesParams {

    NSArray *sequencesSettings = @[
                   @{
                       @"id" : @"randomNumbers",
                       @"symbols" : @"numbers09",
                       @"label"   : @"Random numbers",
                       @"generator" : @"getRandomizedSequence:"
                       },
//                     @{
//                         @"id" : @"numbers",
//                         @"symbols" : @"numbersFrom1",
//                         @"label" : @"Numbers",
//                         @"generator" : @"getSlicedSequence:"
//                         },
//                     @{
//                         @"id" : @"letters",
//                         @"symbols" : @"letters",
//                         @"label" : @"Letters",
//                         @"generator" : @"getSlicedSequence:"
//                         },
                     @{
                         @"id" : @"randomNumbersLetters",
                         @"symbols" : @"numbersLetters",
                         @"label"   : @"Random numbers & letters",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     @{
                         @"id" : @"emoji",
                         @"symbols" : @"emoji",
                         @"label" : @"Random emoji",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     @{
                         @"id" : @"randomFlags",
                         @"symbols" : @"flags",
                         @"label"   : @"Random flags",
                         @"generator" : @"getRandomizedSequence:"
                         },
//                     @{
//                         @"id" : @"katakana",
//                         @"symbols" : @"katakana",
//                         @"label" : @"Katakana",
//                         @"generator" : @"getSlicedSequence:"
//                         },
                     @{
                         @"id" : @"randomKatakana",
                         @"symbols" : @"katakana",
                         @"label"   : @"Random katakana",
                         @"generator" : @"getRandomizedSequence:"
                         },
                     ];
    
    return sequencesSettings;
}

+ (NSUInteger)checkSequenceLevel:(NSUInteger)level {
    NSArray *sequencesSettings = [NCGame getSequencesParams];
    if (level > [sequencesSettings count] - 1) {
        level = 0;
    }
    
    return level;
}

+ (NSDictionary*)getSequenceParams:(NSUInteger)level {
    NSArray *sequencesSettings = [NCGame getSequencesParams];
    
    if (level > [sequencesSettings count] - 1) {
        level = 0;
    }
    
    NSDictionary *settings = [sequencesSettings objectAtIndex:level];
    
    return settings;
}

+ (NSString*)getSequenceId:(NSUInteger)level {
    NSDictionary *settings = [NCGame getSequenceParams:level];
    
    return [settings objectForKey:@"id"];
}

- (NSMutableArray*)getSequence:(NSUInteger)sequenceLevel difficultyLevel:(NSUInteger)difficultyLevel {
    NSMutableArray *sequence;

    NSDictionary *settings = [NCGame getSequenceParams:sequenceLevel];
    
    NSArray *symbols = [NCGame getSymbols:[settings objectForKey:@"symbols"]];
    
    if (nil == [settings objectForKey:@"generator"]) {
        sequence = [NCGame createLimitSequence:self.sequenceLength symbols:symbols];
    } else {
        SEL selector = NSSelectorFromString([settings objectForKey:@"generator"]);
        sequence = [self performSelector:selector withObject:symbols];
        sequence = [NCGame createLimitSequence:self.sequenceLength symbols:sequence];
    }
    
    return sequence;
}

+ (NSMutableArray*)createLimitSequence:(NSUInteger)total symbols:(NSArray*)symbols {
    NSMutableArray *sequence = [[NSMutableArray alloc] init];
    
    NSString *val;
    NSUInteger symbolsCount = [symbols count];
    
    NSUInteger idx = 0;
    while ([sequence count] < total) {
        val = [NSString stringWithFormat:@"%@", [symbols objectAtIndex:idx]];
    
        [sequence addObject:[NSString stringWithFormat:@"%@", val]];
        if (++idx >= [symbols count]) {
            idx = 0;
        }
    }

    return sequence;
}

- (void)generateItems:(BOOL)reverse {

    NSDictionary *settings = [NCGame getSequenceParams:self.sequenceLevel];
    
    NSArray *symbols = [NCGame getSymbols:[settings objectForKey:@"symbols"]];

    
    for (int i = 0; i < [self.sequence count]; i++) {
        NCCell *cell = [[NCCell alloc] init];
        
        cell.value = i;
        cell.text = self.sequence[i];
        [self.items addObject:cell];
    }

    int idx = 0;
    
    while ([self.items count] < self.total) {
        if (idx >= [symbols count]) {
            idx = 0;
        }
        
        NSString *symbol = symbols[idx];
        
        if (NSNotFound == [self.sequence indexOfObject:symbol]) {
            NCCell *cell = [[NCCell alloc] init];
            
            cell.value = idx;
            cell.text = symbols[idx];
            [self.items addObject:cell];
        }
        
        idx++;
    }
    
    
//    [self.sequence enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
//        NCCell *cell = [[NCCell alloc] init];
//        
//        cell.value = idx;
//        cell.text = obj;
//        [self.items addObject:cell];
//    }];
}

+ (NSMutableArray*)randomize:(NSMutableArray*)itemsOriginal {
    NSMutableArray *items = itemsOriginal.mutableCopy;
    
    for (int i = 0; i < [items count]; i++) {
        NCCell *cell = [items objectAtIndex:i];
        int newIndex = arc4random() % [items count];
        
        if (newIndex != i) {
            items[i] = items[newIndex];
            items[newIndex] = cell;
        }
    }
    
    return items;
}

- (NSArray*)getRandomizedSequence:(NSArray*)sequenceOriginal {
    NSMutableArray *items = sequenceOriginal.mutableCopy;
    
    for (int i = 0; i < [items count]; i++) {
        NCCell *cell = [items objectAtIndex:i];
        int newIndex = arc4random() % [items count];
        
        if (newIndex != i) {
            items[i] = items[newIndex];
            items[newIndex] = cell;
        }
    }
    
    return items;
}

- (NSArray*)getSlicedSequence:(NSArray*)sequenceOriginal {
    NSMutableArray *items = sequenceOriginal.mutableCopy;
    if (self.total > [items count]) {
        return items;
    }
    
    int offset = arc4random() % ([items count] - self.total);
    
    for (int i = 0; i < offset; i++) {
        [items removeObjectAtIndex:0];
    }
    
    return items;
}

- (NSArray*)getItems {

    // filling up
    self.sequence = [self getSequence:self.sequenceLevel difficultyLevel:self.difficultyLevel];

    [self generateItems:NO];
    
    //randomizing few times
    for (int i = 0; i < 5; i++) {
        self.items = [NCGame randomize:self.items];
    }
    
    return self.items;
}

- (void) start
{
    self.startTime = [NSDate date];
    self.isStarted = YES;
}
- (NSDictionary*) finish
{
    if (self.isDone) {
        return self.result;
    }
    self.isDone = YES;
    
    if (self.isComplete) {
        NSLog(@"GAME IS DONE!");

        NSDate *date = [NSDate date];
        
        NSUserDefaults *def = [[NSUserDefaults alloc] init];
        // seems like a hack
        id obj = [def objectForKey:@"log"];
        NSMutableArray *log;
        if (nil == obj) {
            log = [[NSMutableArray alloc] init];
        } else {
            log = [obj mutableCopy];
            for (NSUInteger i = 0; i < [log count]; i++) {
                id obj = [log objectAtIndex:i];
                if (![obj isKindOfClass:[NSDictionary class]]) {
                    [log removeObjectAtIndex:i];
                }
            }
        }
        
        NSDictionary *settings = [NCGame getSequenceParams:self.sequenceLevel];

        self.result = @{
                                @"date" : date,
                                @"total" : [NSString stringWithFormat:@"%lu", self.total],
                                @"id" : [settings objectForKey:@"id"],
                                @"difficulty" : [NSString stringWithFormat:@"%lu", self.difficultyLevel],
                                @"duration" : self.duration,
                                @"clicked" : [NSString stringWithFormat:@"%lu", self.clicked + 100],
                                @"clickedWrong" : [NSString stringWithFormat:@"%lu", self.clickedWrong],
                             };
        
        [log addObject:self.result];
        
        [def setObject:log forKey:@"log"];
        [def synchronize];

    } else {
        NSLog(@"game not done :(");
    }

    return self.result;
}

- (float)getSpeed {
    return (float)self.clicked / ([[self getDuration] floatValue]);
}

+ (NSMutableArray*)log {
    NSUserDefaults *def = [[NSUserDefaults alloc] init];
    NSMutableArray *log = [def objectForKey:@"log"];

    if (!log) {
        log = [[NSMutableArray alloc] init];
    }
    return log;
}

+ (NSNumber*)getScore:(NSDictionary*)data {
    NSNumber *score = [NSNumber numberWithFloat:0.0];
    
    NSArray *sparams = [NCGame getSequencesParams];
    NSString *skey = [data objectForKey:@"id"];
    
    NSNumber *sequenceIndex = [NSNumber numberWithInt:0];
    for (int i = 0; i < [sparams count]; i++) {
        NSDictionary *param = [sparams objectAtIndex:i];
        if ([skey isEqualToString:[param objectForKey:@"id"]]) {
            sequenceIndex = [NSNumber numberWithInt:i];
            break;
        }
    }
    
    float total = [[data objectForKey:@"total"] floatValue];
    float sequenceCount = [[data objectForKey:@"sequenceCount"] floatValue];
    if (sequenceCount < 2.) {
        sequenceCount = 2.;
    }
    
    float duration = [[data objectForKey:@"duration"] floatValue];
    float speed = sequenceCount / duration;
//    NSLog(@"%f / %f = %f", sequenceCount, duration, speed);
    score = [NSNumber numberWithFloat:speed * sequenceCount];
    
    score = [NSNumber numberWithFloat:[score floatValue] * total ];
    
    float percent = [score floatValue] / 100.;
    float difficulty = [[data objectForKey:@"difficulty"] floatValue];
    
    float difficultyBonus = (percent*difficulty*10.) * difficulty;
    
    
//    NSLog(@"SCORE base (speed, total) %@, difbonus %.2f", score, difficultyBonus);
    
    score = [NSNumber numberWithFloat:[score floatValue] + difficultyBonus ];
//    NSLog(@"SCORE difficult %@", score);
    
    percent = [score floatValue] / 100.;
    
    float sequenceBonus = (percent*20.) * [sequenceIndex floatValue];
    
    score = [NSNumber numberWithFloat:[score floatValue] + sequenceBonus ];
//    NSLog(@"SCORE sequence %@, sbonus %.2f", score, sequenceBonus);

    percent = [score floatValue] / 100.;
    
    score = [NSNumber numberWithFloat:[score floatValue] - (percent*10) * [[data objectForKey:@"clickedWrong"] floatValue] ];
//    NSLog(@"SCORE wrong %@", score);
    
//    NSLog(@"SCORE: %@", score);
    
    if (nil == score || isnan([score floatValue])) {
        score = [NSNumber numberWithFloat:0.0];
    }
    
    return score;
}

+ (NSMutableDictionary*)stats:(NSString*)keyFormat {
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *days = [[NSMutableDictionary alloc] init];
    NSMutableArray *log = [self log];

    if (0 == [log count]) {
        return stats;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:keyFormat];
    
    NSNumber *totalMax;
    NSNumber *totalAvg;
    NSNumber *totalMin;

    for (id obj in log) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        NSDictionary *item = obj;
        float gameScore = [[NCGame getScore:item] floatValue];
        
        NSDate *date = [item objectForKey:@"date"];
        // calculate item value
        float time  = [[item objectForKey:@"duration"] floatValue];
        
        if (!time || time > 1000000) {
            continue;
        }
        
        NSString *dayKey = [formatter stringFromDate:date];
        
        /*
         
         dayLog [
            date = [
                avg   = ...
                max   = ...
                min   = ...
            ],
            avg = ...
            max = ...
            min = ...
         ]
         
         */
        
        NSMutableDictionary *dayLog = [days objectForKey:dayKey];
        if (nil == dayLog) {
            dayLog = [[NSMutableDictionary alloc] init];
            days[dayKey] = dayLog;
        }

        
        NSNumber *dayAvg = [dayLog objectForKey:@"avg"];
        NSNumber *dayMax = [dayLog objectForKey:@"max"];
        NSNumber *dayMin = [dayLog objectForKey:@"min"];
        NSNumber *daySum = [dayLog objectForKey:@"sum"];
        
        if (nil == dayAvg) {
            dayAvg = [NSNumber numberWithFloat:gameScore];
        } else {
            dayAvg = [NSNumber numberWithFloat:([dayAvg floatValue] + gameScore) / 2.];
        }
        
        if (nil == dayMax || [dayMax floatValue] < gameScore) {
            dayMax = [NSNumber numberWithFloat:gameScore];
        }

        if (nil == dayMin || [dayMin floatValue] > gameScore) {
            dayMin = [NSNumber numberWithFloat:gameScore];
        }
        
        if (nil == daySum) {
            daySum = [NSNumber numberWithFloat:gameScore];
        } else {
            daySum = [NSNumber numberWithFloat:([daySum floatValue] + gameScore)];
        }
        
        [dayLog setObject:dayAvg forKey:@"avg"];
        [dayLog setObject:dayMax forKey:@"max"];
        [dayLog setObject:dayMin forKey:@"min"];
        [dayLog setObject:daySum forKey:@"sum"];

        if (nil == totalAvg) {
            totalAvg = [NSNumber numberWithFloat:gameScore];
        } else {
            totalAvg = [NSNumber numberWithFloat:([totalAvg floatValue] + gameScore) / 2.];
        }
        
        if (nil == totalMax || [totalMax floatValue] < gameScore) {
            totalMax = [NSNumber numberWithFloat:gameScore];
        }
        
        if (nil == totalMin || [totalMin floatValue] > gameScore) {
            totalMin = [NSNumber numberWithFloat:gameScore];
        }
    }
    
    [stats setObject:totalMax forKey:@"max"];
    [stats setObject:totalAvg forKey:@"avg"];
    [stats setObject:totalMin forKey:@"min"];
    [stats setObject:days forKey:@"days"];
    
    return stats;
}

+ (NSMutableDictionary*)statsForDay {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    return result;
    // TODO: не делить на totalsб среднее считать из всех записей за час, только данное количество есть в каждом часу
    // напрмиер, если в каждом часу считали 15 и 42, а в одном или в нескольких, но не во всех, 24, то среднее берется только
    // из 15 и 42,  24 исключается
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
    NSMutableArray *log = [self log];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH"];
    
    for (id obj in log) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *item = obj;
            int total = [item[1] intValue];
            int time  = [item[2] intValue];
            float speed = (float)total / (float)time;
            
            speed = speed * total;

            NSDate *date = item[0];
            
            //            NSLog(@"%d", total);
            
            NSMutableDictionary *dayLog = [stats objectForKey:[NSString stringWithFormat:@"%d", total]];
            NSString *dayKey;
            if (nil == dayLog) {
                dayLog = [[NSMutableDictionary alloc] init];
                dayKey = [NSString stringWithFormat:@"%d", 42];
                stats[dayKey] = dayLog;
            }
            
            dayKey = [formatter stringFromDate:date];
            NSNumber *val = [dayLog objectForKey:dayKey];
            if (nil == val) {
                //                NSLog(@"%f", speed);
                [dayLog setObject:[NSNumber numberWithFloat:speed] forKey:dayKey];
            } else {
                [dayLog setObject:[NSNumber numberWithFloat:(([val floatValue] + speed) / 2.)] forKey:dayKey];
            }
            
        }
    }

    return stats;
}
@end
